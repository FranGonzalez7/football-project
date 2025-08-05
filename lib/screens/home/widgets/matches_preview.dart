import 'package:flutter/material.dart';
import 'package:football_picker/models/match_model.dart';
import 'package:football_picker/services/auth_service.dart';
import 'package:football_picker/services/match_services.dart';
import 'package:football_picker/theme/app_colors.dart';

/// 👀 Muestra una vista previa de los partidos sin comenzar dentro del grupo del usuario
class MatchesPreview extends StatelessWidget {
  const MatchesPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final user = snapshot.data!;
        final groupId = user.groupId;

        return StreamBuilder<List<Match>>(
          stream: MatchService().getOngoingMatches(groupId),
          builder: (context, matchSnapshot) {
            if (matchSnapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error al cargar los partidos 😢'),
              );
            }

            if (!matchSnapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final allMatches = matchSnapshot.data ?? [];
            final unstartedMatches =
                allMatches.where((match) => match.hasStarted == false).toList();

            if (unstartedMatches.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay partidos pendientes por empezar ⚽'),
              );
            }

            // 📝 Lista de partidos sin empezar
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: unstartedMatches.length,
              itemBuilder: (context, index) {
                final match = unstartedMatches[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/newMatch5',
                      arguments: {
                        'matchId': match.id,
                        'groupId': match.groupId,
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryButton),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Image.asset(
                            'assets/images/field_white.png',
                            width: 200,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
