import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_bubble.dart';

/// 🎯 Lista horizontal de jugadores disponibles.
/// - Soporta selección **controlada** por `selectedPlayerId`
///   o **no controlada** (estado interno).
/// - Notifica al padre con `onPlayerTap(player)`.
class PlayerSelectorList extends StatefulWidget {
  final List<Player> players;                   // 👥 jugadores a mostrar
  final ValueChanged<Player> onPlayerTap;       // 👆 callback al tocar
  final String? selectedPlayerId;               // ✅ selección controlada (opcional)

  const PlayerSelectorList({
    super.key,
    required this.players,
    required this.onPlayerTap,
    this.selectedPlayerId,
  });

  @override
  State<PlayerSelectorList> createState() => _PlayerSelectorListState();
}

class _PlayerSelectorListState extends State<PlayerSelectorList> {
  String? selectedPlayerLocalId; // 🧠 usado solo en modo no controlado

  // ⚙️ Constantes de layout
  static const double _panelHeight = 96;
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final String? controlledSelection = widget.selectedPlayerId;

    if (widget.players.isEmpty) {
      return const SizedBox(
        height: _panelHeight,
        child: Center(
          child: Text('Sin jugadores disponibles', style: TextStyle(fontSize: 13)),
        ),
      );
    }

    return SizedBox(
      height: _panelHeight,
      child: ListView.builder(
        key: const PageStorageKey('player_selector_list'), // 🧷 recuerda scroll dentro del mismo route
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: widget.players.length,
        itemBuilder: (context, index) {
          final player = widget.players[index];

          // ✅ Si el padre controla, usamos su id; si no, usamos el local
          final bool isSelected =
              (controlledSelection ?? selectedPlayerLocalId) == player.id;

          return Padding(
            key: ValueKey('player_${player.id}'),
            padding: EdgeInsets.only(right: index == widget.players.length - 1 ? 0 : _gap),
            child: PlayerSelectorBubble(
              player: player,
              isSelected: isSelected,
              onTap: () {
                if (controlledSelection == null) {
                  setState(() {
                    selectedPlayerLocalId =
                        (selectedPlayerLocalId == player.id) ? null : player.id;
                  });
                }
                widget.onPlayerTap(player);
              },
            ),
          );
        },
      ),
    );
  }
}
