import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_bubble.dart';

class PlayerSelectorList extends StatefulWidget {
  final List<Player> players;
  final Map<String, Color> playerColors; // map id jugador a color equipo

  const PlayerSelectorList({
    super.key,
    required this.players,
    required this.playerColors,
  });

  @override
  State<PlayerSelectorList> createState() => _PlayerSelectorListState();
}

class _PlayerSelectorListState extends State<PlayerSelectorList> {
  String? selectedPlayerId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.players.length,
        itemBuilder: (context, index) {
          final player = widget.players[index];
          final color = widget.playerColors[player.id] ?? Colors.grey;
          final isSelected = selectedPlayerId == player.id;

          return PlayerSelectorBubble(
            player: player,
            color: color,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                selectedPlayerId = player.id;
              });
            },
          );
        },
      ),
    );
  }
}
