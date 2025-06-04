import 'package:flutter/material.dart';


IconData getPositionIcon(String position) {
  switch (position.toLowerCase().trim()) {
    case 'portero':
      return Icons.sports_handball_outlined;
    case 'defensa':
      return Icons.shield;
    case 'centro':
      return Icons.directions_run;
    case 'delantero':
      return Icons.sports_soccer;
    case 'lateral izq':
      return Icons.arrow_back;
    case 'lateral der':
      return Icons.arrow_forward;
    default:
      return Icons.help_outline;
  }
}
