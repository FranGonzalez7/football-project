import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_player/widgets/position_icons.dart';
import 'package:football_picker/screens/players/widgets/player_card.dart';
import 'package:football_picker/theme/app_colors.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final String currentUserId;
  final bool isAdmin;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PlayerTile({
    Key? key,
    required this.player,
    required this.currentUserId,
    required this.isAdmin,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isOwner = player.createdBy == currentUserId;

    // ✅ Formato de la Card:
    final tile = Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      color: AppColors.textFieldBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "Cerrar",
            barrierColor: Colors.black54, // fondo semitransparente
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, anim1, anim2) {
              return Center(child: PlayerCard(player: player));
            },
            transitionBuilder: (context, anim1, anim2, child) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim1,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar cuadrado redondeado
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                  size: 35,
                ),
              ),
              const SizedBox(width: 16),

              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        if (isOwner && !isAdmin)
                          const Icon(Icons.star_border, color: Colors.amber, size: 20),
                        if (!isOwner && isAdmin)
                          const Icon(Icons.person, color: Colors.amber, size: 20),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children:
                          player.position
                              .split(',')
                              .map(
                                (pos) => CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.background,
                                  child: Icon(
                                    getPositionIcon(pos.trim()),
                                    size: 25,
                                    color: AppColors.primaryButton,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),

              // Puntos centrados verticalmente
              SizedBox(
                height: 75,
                child: Center(
                  child: Text(
                    '${player.points} pts',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // ✅ Lógica y formato para el desplegable para borrar jugador:
    if (isAdmin && onDelete != null) {
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
