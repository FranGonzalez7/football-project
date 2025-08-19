import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_list.dart';
import 'package:football_picker/theme/app_colors.dart';

/// 👥 Panel inferior que muestra los jugadores disponibles
/// (no asignados a slots).
class PlayerSelectorPanel extends StatelessWidget {
  final Map<String, Player> playersById;     // 🔎 todos los jugadores (por id)
  final Set<String> assignedIds;             // 🚫 ids ya asignados en slots
  final String? selectedPlayerId;            // ✅ id del jugador seleccionado
  final ValueChanged<Player> onPlayerTap;    // 👆 callback al tocar un jugador

  const PlayerSelectorPanel({
    super.key,
    required this.playersById,
    required this.assignedIds,
    required this.selectedPlayerId,
    required this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    // 📋 Filtra solo los jugadores libres
    final availablePlayers =
        playersById.values.where((p) => !assignedIds.contains(p.id)).toList();

    return Container(
      height: 140,
      padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jugadores:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: PlayerSelectorList(
              players: availablePlayers,
              selectedPlayerId: selectedPlayerId,
              onPlayerTap: onPlayerTap,
            ),
          ),
        ],
      ),
    );
  }
}
