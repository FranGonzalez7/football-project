import 'package:flutter/material.dart';
import 'package:football_picker/models/match_model.dart';
import 'package:football_picker/services/auth_service.dart'; // ojo al nombre
import 'package:football_picker/services/match_service.dart';
import 'package:football_picker/theme/app_colors.dart';
import 'package:intl/intl.dart';

class MatchesPreview extends StatelessWidget {
  const MatchesPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final user = snapshot.data!;
        final groupId = user.groupId;

        return StreamBuilder<List<Match>>(
          stream: MatchService().getUpcomingMatches(
            groupId,
            onlyUnstarted: true,
          ),
          builder: (context, matchSnapshot) {
            if (matchSnapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error al cargar los partidos 😢'),
              );
            }
            if (!matchSnapshot.hasData)
              return const CircularProgressIndicator();

            final matches = matchSnapshot.data!;
            if (matches.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay partidos próximos ⚽'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
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
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryButton),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '📅 ${DateFormat('dd/MM/yyyy – HH:mm').format(match.scheduledDate)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Image.asset(
                                'assets/images/field_white.png',
                                width: 200,
                                height: 100,
                                fit: BoxFit.contain,
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
