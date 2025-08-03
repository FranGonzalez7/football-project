import 'package:flutter/material.dart';
import 'package:football_picker/screens/new_match/widgets/matches_preview.dart';
import 'package:football_picker/services/auth_service.dart';
import 'package:football_picker/services/match_services.dart';
import 'package:football_picker/theme/app_colors.dart';

class NextMatchCard extends StatelessWidget {
  const NextMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.primaryButton),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(flex: 3, child: MatchesPreview()),
              const SizedBox(width: 16),
              const VerticalDivider(
                width: 20,
                thickness: 0.5,
                color: Colors.grey,
              ),
              Flexible(
                flex: 2,
                child: Center(
                  child: Column(
                    children: [
                      Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sports_soccer),
                        label: const Text('5 vs 5'),
                        onPressed: () async {
                          final appUser = await AuthService().getCurrentUser();
                          if (appUser == null) return;

                          final existingMatch = await MatchService()
                              .getUnstartedMatch(appUser.groupId);

                          String matchId;

                          if (existingMatch != null) {
                            matchId = existingMatch.id;
                          } else {
                            matchId = await MatchService().createMatch(
                              createdBy: appUser.uid,
                              groupId: appUser.groupId,
                            );
                          }

                          if (context.mounted) {
                            Navigator.pushNamed(
                              context,
                              '/newMatch5',
                              arguments: {
                                'matchId': matchId,
                                'groupId': appUser.groupId,
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),

                      Spacer(),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.sports_soccer),
                        label: const Text('6 vs 6'),
                        onPressed: () {},

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),

                      Spacer(),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.sports_soccer),
                        label: const Text('7 vs 7'),
                        onPressed: () {},

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),

                      Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -12,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: AppColors.background,
            child: const Text(
              'Siguiente Partido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
