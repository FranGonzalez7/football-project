import 'package:flutter/material.dart';
import 'package:football_picker/models/match_model.dart';
import 'package:football_picker/services/auth_service.dart';
import 'package:football_picker/services/match_services.dart';
import 'package:football_picker/theme/app_colors.dart';

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
            if (matchSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!matchSnapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error al cargar los partidos 😢'),
              );
            }

            final allMatches = matchSnapshot.data!;
            final unstartedMatches =
                allMatches.where((match) => match.hasStarted == false).toList();

            if (unstartedMatches.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay partidos pendientes por empezar ⚽'),
              );
            }

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
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryButton),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_soccer, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Partido pendiente',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Creado el ${match.createdAt.toLocal()}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
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
