import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchHeader extends StatelessWidget {
  final DateTime? selectedDate;
  final String location;

  const MatchHeader({
    super.key,
    required this.selectedDate,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          selectedDate != null
              ? '📅 ${DateFormat('dd/MM/yyyy – HH:mm').format(selectedDate!)}'
              : '📅 Fecha no seleccionada',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.white70),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                location.trim().isNotEmpty ? location : 'Lugar por confirmar',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
