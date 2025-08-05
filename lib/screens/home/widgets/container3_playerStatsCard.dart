import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

/// 📊 Widget de estadísticas de jugadores (en construcción)
class PlayerStatsCard extends StatelessWidget {
  const PlayerStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🧱 Contenedor principal
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.primaryButton),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16.0),
          child: const Center(
            child: Text(
              'Tercer Bloque',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        // 🏷️ Etiqueta superior "Player Stats"
        Positioned(
          top: -12,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: AppColors.background,
            child: const Text(
              'Player Stats',
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
