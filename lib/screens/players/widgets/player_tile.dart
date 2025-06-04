import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_player/widgets/position_icons.dart';
import 'package:football_picker/theme/app_colors.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final String currentUserId;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PlayerTile({
    Key? key,
    required this.player,
    required this.currentUserId,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isOwner = player.createdBy == currentUserId;

    // ✅ Formato de la Card:
    final tile = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: AppColors.textField,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        onTap: () {},

        // ✅ Formato del círculo:
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.lightBlue,
          child: Text(
            player.number.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // ✅ Formato del nombre del jugador (título):
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                if (isOwner)
                  const Icon(Icons.edit, color: Colors.amber, size: 20),
              ],
            ),
            const SizedBox(height: 6),

            // ✅ Formato de posiciones:
            Wrap(
              spacing: 8,
              runSpacing: 2,
              children:
                  player.position
                      .split(',')
                      .map(
                        (pos) => Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(getPositionIcon(pos), size: 25, color: AppColors.accentButton,),
                              const SizedBox(width: 4),
                              Text(pos.trim()),
                            ],
                          ),
                          backgroundColor: AppColors.background,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${player.points} pts',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );

    // ✅ Lógica y formato para el desplegable para borrar jugador:
    if (isOwner && onDelete != null) {
      return Dismissible(
        key: Key(player.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),

        // ✅ Lógica y formato del cuadro de texto para confirmar el borrado:
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Confirmar borrado'),
                  content: Text('¿Eliminar jugador ${player.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
          );
        },
        onDismissed: (direction) => onDelete!(),
        child: tile,
      );
    } else {
      return tile;
    }
  }
}
