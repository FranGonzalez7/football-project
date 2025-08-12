import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_list.dart';
import 'package:football_picker/theme/app_colors.dart';
import 'package:football_picker/widgets/custom_primary_button.dart';

class PlayerSelectorPanel extends StatelessWidget {
  final Map<String, Player> playersById;
  final Set<String> assignedIds;
  final String? selectedPlayerId;
  final ValueChanged<Player> onPlayerTap;
  final VoidCallback onStartMatch;

  const PlayerSelectorPanel({
    super.key,
    required this.playersById,
    required this.assignedIds,
    required this.selectedPlayerId,
    required this.onPlayerTap,
    required this.onStartMatch,
  });

  @override
  Widget build(BuildContext context) {
    final availablePlayers =
        playersById.values.where((p) => !assignedIds.contains(p.id)).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Seleccionar jugadores',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          PlayerSelectorList(
            players: availablePlayers,
            playerColors: {for (var p in availablePlayers) p.id: Colors.blue},
            selectedPlayerId: selectedPlayerId,
            onPlayerTap: onPlayerTap,
          ),
          const Spacer(),
          CustomPrimaryButton(
            text: 'Comenzar Partido',
            onPressed: onStartMatch,
          ),
        ],
      ),
    );
  }
}
