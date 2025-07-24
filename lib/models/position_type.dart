import 'package:flutter/material.dart';

/// ⚽ Enum que representa las posiciones posibles de un jugador en el campo.
enum PositionType {
  portero,        // 🧤 Portero
  defensa,        // 🛡 Defensa
  centrocampista, // 🏃 Centrocampista
  delantero,      // ⚽ Delantero
  lateralIzq,     // ◀️ Lateral Izquierdo
  lateralDer,     // ▶️ Lateral Derecho
}

/// 🏷️ Etiquetas de texto para mostrar en la UI según la posición.
const positionLabels = {
  PositionType.portero: 'Portero',
  PositionType.defensa: 'Defensa',
  PositionType.centrocampista: 'Centro',
  PositionType.delantero: 'Delantero',
  PositionType.lateralIzq: 'Lateral Izq',
  PositionType.lateralDer: 'Lateral Der',
};

/// 🎨 Iconos asociados a cada posición para mostrar en la UI.
// TODO: buscar nuevos iconos más representativos
const positionIcons = {
  PositionType.portero: Icons.sports_handball_outlined,   // 🧤
  PositionType.defensa: Icons.shield,                     // 🛡
  PositionType.centrocampista: Icons.directions_run,      // 🏃
  PositionType.delantero: Icons.sports_soccer,            // ⚽
  PositionType.lateralIzq: Icons.arrow_back,              // ◀️
  PositionType.lateralDer: Icons.arrow_forward,           // ▶️
};

/// 🔄 Convierte un [String] con el nombre de la posición en un [PositionType].
/// Retorna `null` si no se reconoce la posición.
/// 
/// Útil para transformar cadenas recibidas desde la base de datos o UI.
PositionType? positionFromString(String pos) {
  switch (pos.toLowerCase().trim()) {
    case 'portero':
      return PositionType.portero;
    case 'defensa':
      return PositionType.defensa;
    case 'centro':
    case 'centrocampista':
      return PositionType.centrocampista;
    case 'delantero':
      return PositionType.delantero;
    case 'lateral izq':
    case 'lateralizq':
      return PositionType.lateralIzq;
    case 'lateral der':
    case 'lateralder':
      return PositionType.lateralDer;
    default:
      return null;
  }
}
