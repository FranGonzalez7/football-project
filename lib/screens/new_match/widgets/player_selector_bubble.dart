import 'package:flutter/material.dart';

class PlayerSelectorBubble extends StatelessWidget {
  final String number;
  final Color color;

  const PlayerSelectorBubble({
    super.key,
    required this.number,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
