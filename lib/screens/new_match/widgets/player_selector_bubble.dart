import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/players/widgets/player_card.dart';
import 'package:football_picker/theme/app_colors.dart';

/// 👤 Burbuja del selector (panel inferior, sin equipo).
/// - Aro neutro cuando NO está seleccionada.
/// - Aro de énfasis al estar seleccionada.
/// - Doble toque: selecciona y abre la ficha (`PlayerCard`).
class PlayerSelectorBubble extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final VoidCallback onTap;

  const PlayerSelectorBubble({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onTap,
  });

  // ⚙️ UI
  static const _kAnim = Duration(milliseconds: 180);
  static const double _sizeUnselected = 60;
  static const double _sizeSelected = 70;
  static const double _borderUnselected = 2;
  static const double _borderSelected = 3;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto =
        (player.photoUrl != null && player.photoUrl!.trim().isNotEmpty);
    final String numberText = player.number.toString();

    // 🎨 Neutro por defecto para no-asignados
    const Color neutralBorder = Colors.white70;

    return Semantics(
      label: isSelected ? 'Jugador seleccionado: ${player.name}' : 'Jugador: ${player.name}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: () {
          onTap.call();
          showDialog(context: context, builder: (_) => PlayerCard(player: player));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: _kAnim,
              width: isSelected ? _sizeSelected : _sizeUnselected,
              height: isSelected ? _sizeSelected : _sizeUnselected,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryButton : neutralBorder, // ✅ neutro hasta seleccionar
                  width: isSelected ? _borderSelected : _borderUnselected,
                ),
                image: hasPhoto
                    ? DecorationImage(image: NetworkImage(player.photoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              alignment: Alignment.center,
              child: hasPhoto
                  ? null
                  : Text(
                      numberText,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _sizeSelected),
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
      ),
    );
  }
}
