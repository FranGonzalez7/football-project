import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/theme/app_colors.dart';

class SlotBubble extends StatelessWidget {
  final String id;
  final Color teamColor;
  final String number;
  final Player? assigned;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const SlotBubble({
    required this.id,
    required this.teamColor,
    required this.number,
    required this.assigned,
    required this.highlighted,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final filled = assigned != null;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Container(
            //padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: teamColor, width: highlighted ? 5 : 4),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.textFieldBackground,
              backgroundImage:
                  filled &&
                          (assigned!.photoUrl != null &&
                              assigned!.photoUrl!.isNotEmpty)
                      ? NetworkImage(assigned!.photoUrl!)
                      : null,
              child:
                  !filled
                      ? Text(number)
                      : null, // si no hay asignación, muestra el número
            ),
          ),
          if (filled && (assigned!.name.trim().isNotEmpty)) ...[
            //const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.textFieldBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                assigned!.name.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
