import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/models/position_type.dart';

import 'package:football_picker/screens/players/widgets/player_card.dart';
import 'package:football_picker/theme/app_colors.dart';

/// 🎯 Widget que representa la tarjeta individual de un jugador en la lista.
/// Incluye avatar, nombre, posición, puntos y opciones de borrado (si eres admin).
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

    /// 🎴 Tarjeta principal con diseño estilizado y acción al pulsar
    final tile = Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      color: AppColors.textFieldBackground,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // 🔍 Mostrar diálogo con información detallada del jugador
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
              // 🔁 Avatar cuadrado que muestra imagen si existe, si no, icono de cámara
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  image:
                      player.photoUrl != null && player.photoUrl!.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(player.photoUrl!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                alignment: Alignment.center,
                child:
                    (player.photoUrl == null || player.photoUrl!.isEmpty)
                        ? const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black,
                          size: 35,
                        )
                        : null,
              ),

              const SizedBox(width: 16),

              // 📝 Información principal: nombre, iconos de rol y posiciones
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

                        // ⭐ Iconos según si es propietario o admin
                        if (isOwner && !isAdmin)
                          const Icon(
                            Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        if (!isOwner && isAdmin)
                          const Icon(
                            Icons.person,
                            color: Colors.amber,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // ⚽ Iconos circulares para posiciones (separadas por coma)
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children:
                          player.position.split(',').map((pos) {
                            final positionEnum = positionFromString(pos);
                            return CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.background,
                              child: Icon(
                                positionEnum != null
                                    ? positionIcons[positionEnum] ??
                                        Icons.help_outline
                                    : Icons.help_outline,
                                size: 25,
                                color: AppColors.primaryButton,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),

              // 🎯 Puntuación del jugador, centrada verticalmente
              SizedBox(
                height: 75,
                child: Center(
                  child: Text(
                    '${player.points} pts',
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    /// 🗑️ Si es admin y hay callback para borrar, envolver en Dismissible para swipe-to-delete
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

        // 🔒 Confirmar borrado con diálogo antes de eliminar
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
