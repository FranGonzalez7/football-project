import 'package:flutter/material.dart';

class PlayerBubbleDown extends StatelessWidget {
  final Color color;
  final String number;

  const PlayerBubbleDown({
    super.key,
    required this.color,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Text(
            'Nombre',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 60,
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
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
