import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // o usa Icons si prefieres

IconData getPositionIcon(String position) {
  switch (position.toLowerCase().trim()) {
    case 'portero':
      return LucideIcons.goal;
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
