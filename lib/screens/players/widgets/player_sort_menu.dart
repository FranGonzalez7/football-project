import 'package:flutter/material.dart';

enum PlayerSortOption {
  nameAsc,
  nameDesc,
  scoreDesc,
  scoreAsc,
  
}

class PlayerSortMenu extends StatelessWidget {
  final PlayerSortOption currentOption;
  final ValueChanged<PlayerSortOption> onSelected;

  const PlayerSortMenu({
    Key? key,
    required this.currentOption,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PlayerSortOption>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => const [
        PopupMenuItem(
          value: PlayerSortOption.nameAsc,
          child: Row(
            children: [
              Icon(Icons.arrow_upward, size: 18),
              SizedBox(width: 8),
              Text('Nombre (A–Z)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: PlayerSortOption.nameDesc,
          child: Row(
            children: [
              Icon(Icons.arrow_downward, size: 18),
              SizedBox(width: 8),
              Text('Nombre (Z–A)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: PlayerSortOption.scoreDesc,
          child: Row(
            children: [
              Icon(Icons.arrow_upward, size: 18),
              SizedBox(width: 8),
              Text('Puntos (Mayor a menor)'),
            ],
          ),
        ),
        PopupMenuItem(
          value: PlayerSortOption.scoreAsc,
          child: Row(
            children: [
              Icon(Icons.arrow_downward, size: 18),
              SizedBox(width: 8),
              Text('Puntos (Menor a mayor)'),
            ],
          ),
        ),
        
      ],
      icon: const Icon(Icons.sort),
    );
  }
}
