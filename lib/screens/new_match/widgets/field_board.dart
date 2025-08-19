import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/slot_bubble.dart';

/// 📍 Coordenadas normalizadas (x,y) de cada slot.
/// Se expresan en proporción al ancho/alto del campo (0..1).
const Map<String, Offset> _slotPos = {
  // 🔴 UPPER team (rojo)
  'U1': Offset(0.50, 0.08), // Portero
  'U2': Offset(0.50, 0.24), // Defensa
  'U3': Offset(0.50, 0.40), // Delantero
  'U4': Offset(0.20, 0.32), // Lateral Izq
  'U5': Offset(0.80, 0.32), // Lateral Der

  // 🔵 LOWER team (azul)
  'D10': Offset(0.50, 0.92), // Portero
  'D9' : Offset(0.50, 0.72), // Defensa
  'D8' : Offset(0.50, 0.56), // Delantero
  'D7' : Offset(0.20, 0.65), // Lateral Izq
  'D6' : Offset(0.80, 0.65), // Lateral Der
};

/// 🏟️ Widget principal del campo.
/// Pinta el **fondo del campo** y coloca las burbujas (`SlotBubble`) en las
/// posiciones calculadas a partir de [_slotPos].
class FieldBoard extends StatelessWidget {
  final Map<String, Player> playersById;
  final Map<String, String?> liveAssignments;
  final bool highlightAll;

  // 🔴 Callbacks UPPER (rojo)
  final VoidCallback onU1;
  final VoidCallback onU2;
  final VoidCallback onU3;
  final VoidCallback onU4;
  final VoidCallback onU5;

  // 🔵 Callbacks LOWER (azul)
  final VoidCallback onD6;
  final VoidCallback onD7;
  final VoidCallback onD8;
  final VoidCallback onD9;
  final VoidCallback onD10;

  // ❌ Clear callbacks
  final VoidCallback clearU1;
  final VoidCallback clearU2;
  final VoidCallback clearU3;
  final VoidCallback clearU4;
  final VoidCallback clearU5;
  final VoidCallback clearD6;
  final VoidCallback clearD7;
  final VoidCallback clearD8;
  final VoidCallback clearD9;
  final VoidCallback clearD10;

  const FieldBoard({
    super.key,
    required this.playersById,
    required this.liveAssignments,
    required this.highlightAll,
    required this.onU1,
    required this.onU2,
    required this.onU3,
    required this.onU4,
    required this.onU5,
    required this.onD6,
    required this.onD7,
    required this.onD8,
    required this.onD9,
    required this.onD10,
    required this.clearU1,
    required this.clearU2,
    required this.clearU3,
    required this.clearU4,
    required this.clearU5,
    required this.clearD6,
    required this.clearD7,
    required this.clearD8,
    required this.clearD9,
    required this.clearD10,
  });

  /// 🔎 Helper: obtiene el Player por id o null si no existe.
  Player? _p(String? id) => id != null ? playersById[id] : null;

  @override
  Widget build(BuildContext context) {
    const upperTeam = Colors.red;
    const lowerTeam = Colors.blue;

    /// 🎯 Helper interno: crea un slot posicionado en el campo.
    Widget _slot({
      required String id,
      required Color color,
      required String number,
      required double bubbleSize,
      required double w,
      required double h,
      required VoidCallback onTap,
      required VoidCallback onLong,
      required bool labelAbove,
    }) {
      const double labelExtra = 30.0; // 📏 Espacio reservado para etiqueta
      final double containerHeight = bubbleSize + labelExtra;

      final pos = _slotPos[id]!;
      final cx = pos.dx * w;
      final cy = pos.dy * h;

      // 📐 Calculamos posición inicial
      double left = cx - bubbleSize / 2;
      double top = cy - bubbleSize / 2;

      // 🛑 Clamp para evitar que se salga de los bordes
      left = left.clamp(0.0, w - bubbleSize);
      top = top.clamp(0.0, h - containerHeight);

      return Positioned(
        left: left,
        top: top,
        child: SizedBox(
          width: bubbleSize,
          height: containerHeight, // 🟢 espacio círculo + etiqueta
          child: SlotBubble(
            id: id,
            teamColor: color,
            number: number,
            assigned: _p(liveAssignments[id]),
            highlighted: highlightAll,
            onTap: onTap,
            onLongPress: onLong,
            radius: bubbleSize / 2,
            labelAbove: labelAbove,
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: AspectRatio(
          aspectRatio: 16 / 9, // 📺 Relación de aspecto fija
          child: LayoutBuilder(
            builder: (_, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              // ⚖️ Tamaño de la burbuja proporcional al ancho
              final bubbleSize = (w * 0.17).clamp(40.0, 72.0);

              return Stack(
                children: [
                  // 🌱 Fondo del campo
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/green_vertical.png',
                      fit: BoxFit.contain, // mantiene proporción
                    ),
                  ),

                  // 🔴 UPPER team
                  _slot(id: 'U1', color: upperTeam, number: '1',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU1,  onLong: clearU1, labelAbove: false),
                  _slot(id: 'U2', color: upperTeam, number: '2',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU2,  onLong: clearU2, labelAbove: false),
                  _slot(id: 'U3', color: upperTeam, number: '3',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU3,  onLong: clearU3, labelAbove: false),
                  _slot(id: 'U4', color: upperTeam, number: '4',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU4,  onLong: clearU4, labelAbove: false),
                  _slot(id: 'U5', color: upperTeam, number: '5',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU5,  onLong: clearU5, labelAbove: false),

                  // 🔵 LOWER team
                  _slot(id: 'D10', color: lowerTeam, number: '10', bubbleSize: bubbleSize, w: w, h: h, onTap: onD10, onLong: clearD10, labelAbove: true),
                  _slot(id: 'D9',  color: lowerTeam, number: '9',  bubbleSize: bubbleSize, w: w, h: h, onTap: onD9,  onLong: clearD9,  labelAbove: true),
                  _slot(id: 'D8',  color: lowerTeam, number: '8',  bubbleSize: bubbleSize, w: w, h: h, onTap: onD8,  onLong: clearD8,  labelAbove: true),
                  _slot(id: 'D7',  color: lowerTeam, number: '7',  bubbleSize: bubbleSize, w: w, h: h, onTap: onD7,  onLong: clearD7,  labelAbove: true),
                  _slot(id: 'D6',  color: lowerTeam, number: '6',  bubbleSize: bubbleSize, w: w, h: h, onTap: onD6,  onLong: clearD6,  labelAbove: true),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
