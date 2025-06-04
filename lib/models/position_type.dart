import 'package:flutter/material.dart';


enum PositionType { portero, defensa, centrocampista, delantero, lateralIzq, lateralDer }

const positionLabels = {
  PositionType.portero: 'Portero',
  PositionType.defensa: 'Defensa',
  PositionType.centrocampista: 'Centro',
  PositionType.delantero: 'Delantero',
  PositionType.lateralIzq: 'Lateral Izq',
  PositionType.lateralDer: 'Lateral Der',
};

//TODO buscar nuevos iconos
const positionIcons = {
  PositionType.portero: Icons.sports_handball_outlined,
  PositionType.defensa: Icons.shield,
  PositionType.centrocampista: Icons.directions_run,
  PositionType.delantero: Icons.sports_soccer,
  PositionType.lateralIzq: Icons.arrow_back,
  PositionType.lateralDer: Icons.arrow_forward,
};
