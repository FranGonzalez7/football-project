import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/players/widgets/player_card.dart';

class PlayerSelectorBubble extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color; // color externo que puedes asignar por equipo

  const PlayerSelectorBubble({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: () {
        showDialog(
          context: context,
          builder: (_) => PlayerCard(player: player),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 80 : 70,
            height: isSelected ? 80 : 70,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 3 : 2,
              ),
              image:
                  player.photoUrl != null
                      ? DecorationImage(
                        image: NetworkImage(player.photoUrl!),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            alignment: Alignment.center,
            child:
                player.photoUrl == null
                    ? Text(
                      player.number.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                player.name,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
