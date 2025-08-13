import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/players/widgets/player_card.dart';
import 'package:football_picker/theme/app_colors.dart';

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
        onTap.call();
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
            width: isSelected ? 70 : 60,
            height: isSelected ? 70 : 60,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primaryButton : Colors.white70,
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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isSelected ? 70 : 60, // igual que la burbuja
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
