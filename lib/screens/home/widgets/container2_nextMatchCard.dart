import 'package:flutter/material.dart';
import 'package:football_picker/screens/home/widgets/matches_preview.dart';
import 'package:football_picker/services/auth_service.dart';
import 'package:football_picker/services/match_service.dart';
import 'package:football_picker/theme/app_colors.dart';

/// 📅 Widget que muestra el próximo partido y opciones para crear uno nuevo
class NextMatchCard extends StatelessWidget {
  const NextMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 📦 Contenedor principal
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
              // 👀 Vista previa del partido
              Flexible(flex: 3, child: const MatchesPreview()),
              const SizedBox(width: 16),
              const VerticalDivider(
                width: 20,
                thickness: 0.5,
                color: Colors.grey,
              ),
              // ⚽ Botones para crear partidos según formato
              Flexible(
                flex: 2,
                child: Center(
                  child: Column(
                    children: [
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sports_soccer),
                        label: const Text('5 vs 5'),
                        onPressed: () async {
                          final appUser = await AuthService().getCurrentUser();
                          if (appUser == null) return;

                          // Usa la fecha seleccionada por el usuario si ya tienes selector; de momento, ahora:
                          final matchId = await MatchService().createMatch(
                            createdBy: appUser.uid,
                            groupId: appUser.groupId,
                            scheduledDate: DateTime.now(),
                          );

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
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sports_soccer),
                        label: const Text('6 vs 6'),
                        onPressed: () {
                          // 📝 Implementar lógica de partido 6 vs 6
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sports_soccer),
                        label: const Text('7 vs 7'),
                        onPressed: () {
                          // 📝 Implementar lógica de partido 7 vs 7
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 🏷️ Etiqueta superior "Siguiente Partido"
        Positioned(
          top: -12,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: AppColors.background,
            child: const Text(
              'Siguientes Partidos',
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
