import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/slot_bubble.dart';

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

  @override
  Widget build(BuildContext context) {
    const Color upperTeam = Colors.red;
    const Color lowerTeam = Colors.blue;

    Player? _p(String? id) => id != null ? playersById[id] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/field_white_vertical.png',
                fit: BoxFit.cover,
              ),
            ),

            // ------- UPPER (rojo)
            Positioned(
              left: 192,
              top: 16,
              child: SlotBubble(
                id: 'U1',
                teamColor: upperTeam,
                number: '1',
                assigned: _p(liveAssignments['U1']),
                highlighted: highlightAll,
                onTap: onU1,
                onLongPress: clearU1,
              ),
            ),
            Positioned(
              left: 192,
              top: 116,
              child: SlotBubble(
                id: 'U2',
                teamColor: upperTeam,
                number: '2',
                assigned: _p(liveAssignments['U2']),
                highlighted: highlightAll,
                onTap: onU2,
                onLongPress: clearU2,
              ),
            ),
            Positioned(
              left: 192,
              top: 246,
              child: SlotBubble(
                id: 'U3',
                teamColor: upperTeam,
                number: '3',
                assigned: _p(liveAssignments['U3']),
                highlighted: highlightAll,
                onTap: onU3,
                onLongPress: clearU3,
              ),
            ),
            Positioned(
              left: 56,
              top: 181,
              child: SlotBubble(
                id: 'U4',
                teamColor: upperTeam,
                number: '4',
                assigned: _p(liveAssignments['U4']),
                highlighted: highlightAll,
                onTap: onU4,
                onLongPress: clearU4,
              ),
            ),
            Positioned(
              right: 56,
              top: 181,
              child: SlotBubble(
                id: 'U5',
                teamColor: upperTeam,
                number: '5',
                assigned: _p(liveAssignments['U5']),
                highlighted: highlightAll,
                onTap: onU5,
                onLongPress: clearU5,
              ),
            ),

            // ------- LOWER (azul)
            Positioned(
              left: 192,
              bottom: 16,
              child: SlotBubble(
                id: 'D10',
                teamColor: lowerTeam,
                number: '10',
                assigned: _p(liveAssignments['D10']),
                highlighted: highlightAll,
                onTap: onD10,
                onLongPress: clearD10,
              ),
            ),
            Positioned(
              left: 192,
              bottom: 116,
              child: SlotBubble(
                id: 'D9',
                teamColor: lowerTeam,
                number: '9',
                assigned: _p(liveAssignments['D9']),
                highlighted: highlightAll,
                onTap: onD9,
                onLongPress: clearD9,
              ),
            ),
            Positioned(
              left: 192,
              bottom: 246,
              child: SlotBubble(
                id: 'D8',
                teamColor: lowerTeam,
                number: '8',
                assigned: _p(liveAssignments['D8']),
                highlighted: highlightAll,
                onTap: onD8,
                onLongPress: clearD8,
              ),
            ),
            Positioned(
              left: 56,
              bottom: 181,
              child: SlotBubble(
                id: 'D7',
                teamColor: lowerTeam,
                number: '7',
                assigned: _p(liveAssignments['D7']),
                highlighted: highlightAll,
                onTap: onD7,
                onLongPress: clearD7,
              ),
            ),
            Positioned(
              right: 56,
              bottom: 181,
              child: SlotBubble(
                id: 'D6',
                teamColor: lowerTeam,
                number: '6',
                assigned: _p(liveAssignments['D6']),
                highlighted: highlightAll,
                onTap: onD6,
                onLongPress: clearD6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
