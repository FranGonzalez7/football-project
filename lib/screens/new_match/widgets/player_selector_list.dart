import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_bubble.dart';

class PlayerSelectorList extends StatefulWidget {
  final List<Player> players;
  final Map<String, Color> playerColors;
  final ValueChanged<Player> onPlayerTap;     // 👈 NUEVO: notifica al padre
  final String? selectedPlayerId;             // 👈 NUEVO: selección controlada opcional

  const PlayerSelectorList({
    super.key,
    required this.players,
    required this.playerColors,
    required this.onPlayerTap,
    this.selectedPlayerId,
  });

  @override
  State<PlayerSelectorList> createState() => _PlayerSelectorListState();
}

class _PlayerSelectorListState extends State<PlayerSelectorList> {
  String? selectedPlayerLocalId; // usado sólo si el padre no controla

  @override
  Widget build(BuildContext context) {
    final controlledSelection = widget.selectedPlayerId; // puede ser null

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.players.length,
        itemBuilder: (context, index) {
          final player = widget.players[index];
          final color = widget.playerColors[player.id] ?? Colors.grey;

          // Si el padre pasa selectedPlayerId, usamos esa; si no, usamos la local
          final isSelected = (controlledSelection ?? selectedPlayerLocalId) == player.id;

          return PlayerSelectorBubble(
            player: player,
            color: color,
            isSelected: isSelected,
            onTap: () {
              // actualizar local SOLO si no está controlado desde fuera
              if (controlledSelection == null) {
                setState(() {
                  selectedPlayerLocalId =
                      (selectedPlayerLocalId == player.id) ? null : player.id;
                });
              }
              widget.onPlayerTap(player); // notificar al padre
            },
          );
        },
      ),
    );
  }
}
