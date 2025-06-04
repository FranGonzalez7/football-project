// widgets/position_selector.dart
import 'package:flutter/material.dart';
import 'package:football_picker/models/position_type.dart';
import 'package:football_picker/theme/app_colors.dart';

class PositionSelector extends StatelessWidget {
  final List<PositionType> selectedPositions;
  final Function(PositionType) onToggle;

  const PositionSelector({
    super.key,
    required this.selectedPositions,
    required this.onToggle,
  });


  // ❓PTE centrar casillas en cuadrícula
  @override
  Widget build(BuildContext context) {
    return Wrap(  //
      spacing: 30,
      runSpacing: 20,
      children: PositionType.values.map((position) {
        final selected = selectedPositions.contains(position);
        return GestureDetector(
          onTap: () => onToggle(position),
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? AppColors.accentButton : AppColors.textField,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? Colors.white : Colors.grey.shade700,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(positionIcons[position], color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  positionLabels[position]!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
