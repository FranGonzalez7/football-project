import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_player/widgets/position_icons.dart';
import 'package:football_picker/theme/app_colors.dart';

class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          width: 380,
          height: 560,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2B2B2B), Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                //color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.white, width: 6),
          ),
          child: Stack(
            children: [
              // ✅ Número o avatar
              Positioned(
                top: 32,
                left: 32,
                right: 32,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    player.number.toString(),
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // ✅ Nombre del jugador
              Positioned(
                top: 210,
                left: 16,
                right: 16,
                child: Center(
                  child: Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // ✅ Posiciones
              Positioned(
                top: 260,
                left: 0,
                right: 0,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children:
                      player.position
                          .split(',')
                          .map(
                            (pos) => CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.background,
                              child: Icon(
                                getPositionIcon(pos.trim()),
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),

              // ✅ Puntos
              Positioned(
                bottom: 90,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '${player.points} puntos',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ✅ Botón de cerrar
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text("Cerrar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
