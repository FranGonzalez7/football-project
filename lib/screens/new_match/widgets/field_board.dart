import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/slot_bubble.dart';

// Coordenadas normalizadas (x,y) respecto al ancho/alto del campo (0..1)
const Map<String, Offset> _slotPos = {
  // UPPER (rojo)
  'U1': Offset(0.50, 0.08), // Portero
  'U2': Offset(0.50, 0.24), // Defensa
  'U3': Offset(0.50, 0.40), // Delantero
  'U4': Offset(0.20, 0.32), // Lat Izq
  'U5': Offset(0.80, 0.32), // Lat Der

  // LOWER (azul)
  'D10': Offset(0.50, 0.92), // Portero
  'D9' : Offset(0.50, 0.75), // Defensa
  'D8' : Offset(0.50, 0.59), // Delantero
  'D7' : Offset(0.20, 0.68), // Lat Izq
  'D6' : Offset(0.80, 0.68), // Lat Der
};

class FieldBoard extends StatelessWidget {
  final Map<String, Player> playersById;
  final Map<String, String?> liveAssignments;
  final bool highlightAll;
  final VoidCallback onU1;
  final VoidCallback onU2;
  final VoidCallback onU3;
  final VoidCallback onU4;
  final VoidCallback onU5;
  final VoidCallback onD6;
  final VoidCallback onD7;
  final VoidCallback onD8;
  final VoidCallback onD9;
  final VoidCallback onD10;
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

  Player? _p(String? id) => id != null ? playersById[id] : null;

  @override
  Widget build(BuildContext context) {
    const upperTeam = Colors.red;
    const lowerTeam = Colors.blue;

    // Helper: crea un slot posicionado por porcentaje reservando altura para etiqueta
    Widget _slot({
      required String id,
      required Color color,
      required String number,
      required double bubbleSize,
      required double w,
      required double h,
      required VoidCallback onTap,
      required VoidCallback onLong,
    }) {
      const double labelExtra = 30.0;               // espacio para gap + etiqueta
      final double containerHeight = bubbleSize + labelExtra;

      final pos = _slotPos[id]!;
      final cx = pos.dx * w;
      final cy = pos.dy * h;

      // Centro del círculo en (cx, cy); ajustamos para que quepa etiqueta sin salirse
      double left = cx - bubbleSize / 2;
      double top  = cy - bubbleSize / 2;

      // Clamps contra bordes (contando etiqueta por abajo)
      left = left.clamp(0.0, w - bubbleSize);
      top  = top.clamp(0.0, h - containerHeight);

      return Positioned(
        left: left,                     // ✅ usa los valores clampados
        top: top,
        child: SizedBox(
          width: bubbleSize,
          height: containerHeight,      // ✅ círculo + etiqueta
          child: SlotBubble(
            id: id,
            teamColor: color,
            number: number,
            assigned: _p(liveAssignments[id]),
            highlighted: highlightAll,
            onTap: onTap,
            onLongPress: onLong,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: AspectRatio(
        aspectRatio: 16 / 9, // mantén 16:9 como pediste
        child: LayoutBuilder(
          builder: (_, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // Tamaño de burbuja proporcional (ajusta factor si quieres)
            final bubbleSize = (w * 0.16).clamp(40.0, 72.0);

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/green_vertical.png',
                    fit: BoxFit.cover, // 16:9 puede recortar: esperado
                  ),
                ),

                // ------- UPPER (rojo)
                _slot(id: 'U1', color: upperTeam, number: '1',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU1, onLong: clearU1),
                _slot(id: 'U2', color: upperTeam, number: '2',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU2, onLong: clearU2),
                _slot(id: 'U3', color: upperTeam, number: '3',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU3, onLong: clearU3),
                _slot(id: 'U4', color: upperTeam, number: '4',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU4, onLong: clearU4),
                _slot(id: 'U5', color: upperTeam, number: '5',  bubbleSize: bubbleSize, w: w, h: h, onTap: onU5, onLong: clearU5),

                // ------- LOWER (azul)
                _slot(id: 'D10', color: lowerTeam, number: '10', bubbleSize: bubbleSize, w: w, h: h, onTap: onD10, onLong: clearD10),
                _slot(id: 'D9',  color: lowerTeam, number: '9',  bubbleSize: bubbleSize, w: w, h: h, onTap: onD9,  onLong: clearD9),
                _slot(id: 'D8',  color: lowerTeam, number: '8',  bubbleSize: bubbleSize, w: w, h: h, onTap: onD8,  onLong: clearD8),
                _slot(id: 'D7',  color: lowerTeam, number: '7',  bubbleSize: bubbleSize, w: w, h: h, onTap: onD7,  onLong: clearD7),
                _slot(id: 'D6',  color: lowerTeam, number: '6',  bubbleSize: bubbleSize, w: w, h: h, onTap: onD6,  onLong: clearD6),
              ],
            );
          },
        ),
      ),
    );
  }
}
