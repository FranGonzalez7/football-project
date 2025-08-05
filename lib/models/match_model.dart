// 📁 match_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 📝 Modelo que representa un partido de fútbol.
///
/// Cada partido tiene un creador, una fecha, dos equipos de jugadores,
/// una marca si ha finalizado o no, y un grupo al que pertenece.
class Match {
  /// 🆔 ID único del partido (usado como ID del documento en Firestore).
  final String id;

  /// 👤 UID del usuario que ha creado el partido.
  final String createdBy;

  /// 🕒 Fecha y hora de creación del partido.
  final DateTime createdAt;

  /// 🔴 Lista de IDs de jugadores del equipo A (por ejemplo, rojo).
  final List<String> playersTeamA;

  /// 🔵 Lista de IDs de jugadores del equipo B (por ejemplo, azul).
  final List<String> playersTeamB;

  /// ✅ Indican si el partido ha terminado o ha empezado.
  final bool isFinished;
  final bool hasStarted;

  /// 👥 ID del grupo al que pertenece este partido.
  final String groupId;

  Match({
    required this.id,
    required this.createdBy,
    required this.createdAt,
    required this.playersTeamA,
    required this.playersTeamB,
    required this.isFinished,
    required this.hasStarted,
    required this.groupId,
  });

  /// 🔁 Crea una instancia de `Match` desde un documento de Firestore.
  factory Match.fromMap(String id, Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw == null) {
      throw Exception('Match sin createdAt: $id');
    }
    final timestamp = createdAtRaw as Timestamp;

    return Match(
      id: id,
      createdBy: map['createdBy'] ?? '',
      createdAt: timestamp.toDate(),
      playersTeamA:
          map['playersTeamA'] != null
              ? List<String>.from(map['playersTeamA'])
              : <String>[],
      playersTeamB:
          map['playersTeamB'] != null
              ? List<String>.from(map['playersTeamB'])
              : <String>[],
      isFinished: map['isFinished'] ?? false,
      hasStarted: map['hasStarted'] ?? false,
      groupId: map['groupId'] ?? '',
    );
  }

  /// 🧭 Convierte el objeto `Match` en un mapa para guardarlo en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdAt': createdAt,
      'playersTeamA': playersTeamA,
      'playersTeamB': playersTeamB,
      'isFinished': isFinished,
      'hasStarted': hasStarted,
      'groupId': groupId,
    };
  }
}
