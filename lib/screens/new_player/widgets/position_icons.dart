import 'package:flutter/material.dart';


IconData getPositionIcon(String position) {
  switch (position.toLowerCase().trim()) {
    case 'portero':
      return Icons.sports_handball_outlined;
    case 'defensa':
      return Icons.shield;
    case 'centrocampista':
      return Icons.compare_arrows;
    case 'delantero':
      return Icons.sports;
    default:
      return Icons.help_outline;
  }
}
