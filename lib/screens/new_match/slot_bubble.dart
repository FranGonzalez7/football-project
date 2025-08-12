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
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: teamColor, width: highlighted ? 3 : 2),
            ),
            child: CircleAvatar(
              radius: 30,
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
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textFieldBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              filled ? assigned!.name.split(' ').first : 'Nombre',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
