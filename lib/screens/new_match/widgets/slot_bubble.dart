import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/theme/app_colors.dart';
// 🧩 NUEVO: import para la ficha de jugador
import 'package:football_picker/screens/players/widgets/player_card.dart';

/// 🫧 Burbuja de slot sobre el campo.
/// - Tap: asigna o limpia (lo gestiona el padre vía callback).
/// - Long-press: limpiar (callback).
/// - Double-tap: si hay jugador asignado, abre su `PlayerCard`.
class SlotBubble extends StatelessWidget {
  final String id;
  final Color teamColor;
  final String number;
  final Player? assigned;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  // 🧩 Layout
  final double radius;        // tamaño de la burbuja
  final bool labelAbove;      // true para colocar etiqueta arriba (slots bajos)

  const SlotBubble({
    super.key,
    required this.id,
    required this.teamColor,
    required this.number,
    required this.assigned,
    required this.highlighted,
    required this.onTap,
    required this.onLongPress,
    this.radius = 28,
    this.labelAbove = false,
  });

  @override
  Widget build(BuildContext context) {
    // 📌 Estado derivado
    final bool filled = assigned != null;
    final bool hasName = (assigned?.name.trim().isNotEmpty ?? false);
    final String firstName = hasName ? assigned!.name.trim().split(' ').first : '';
    final bool hasPhoto = (assigned?.photoUrl != null && assigned!.photoUrl!.isNotEmpty);
    final double borderW = highlighted ? 5.0 : 4.0;

    // 🏷️ Etiqueta de nombre
    Widget _nameLabel(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.textFieldBackground,
          borderRadius: BorderRadius.circular(6),
        ),
        child: SizedBox(
          height: 12,
          width: (radius * 2) + 8,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    // 🖼️ Avatar
    final Widget avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: teamColor, width: borderW),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.textFieldBackground,
        backgroundImage: (filled && hasPhoto) ? NetworkImage(assigned!.photoUrl!) : null,
        child: !filled
            ? Text(
                number,
                style: const TextStyle(fontWeight: FontWeight.w600),
              )
            : null,
      ),
    );

    return Semantics(
      label: filled ? 'Posición $id, ${assigned!.name}' : 'Posición $id vacía, número $number',
      button: true,
      child: GestureDetector(
        onTap: onTap,             // 👆 asignar/limpiar (según lógica del padre)
        onLongPress: onLongPress, // ✋ limpiar (alternativa)
        // 🖱️ NUEVO: doble-tap abre la ficha si hay jugador
        onDoubleTap: () {
          if (assigned != null) {
            showDialog(
              context: context,
              builder: (_) => PlayerCard(player: assigned!),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: labelAbove
              ? [
                  if (hasName) _nameLabel(firstName),
                  if (hasName) const SizedBox(height: 2),
                  avatar,
                ]
              : [
                  avatar,
                  if (hasName) const SizedBox(height: 2),
                  if (hasName) _nameLabel(firstName),
                ],
        ),
      ),
    );
  }
}
