// 📁 match_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 📝 Modelo que representa un partido de fútbol.
///
/// Cada partido tiene un creador, una fecha de creación,
/// una fecha programada para jugarse, dos equipos de jugadores,
/// una marca si ha finalizado o no, y un grupo al que pertenece.
/// Ahora también incluye:
///  - goles por jugador (goalsByPlayer)
///  - marcador en vivo (scoreTeamA / scoreTeamB)
///  - timestamps de inicio/fin (startedAt / endedAt)
class Match {
  /// 🆔 ID único del partido (usado como ID del documento en Firestore).
  final String id;

  /// 👤 UID del usuario que ha creado el partido.
  final String createdBy;

  /// 🕒 Fecha y hora de creación del partido.
  final DateTime createdAt;

  /// 📅 Fecha, hora y lugar programadas para disputar el partido.
  final DateTime scheduledDate;
  final String location;

  /// 🔴 Lista de IDs de jugadores del equipo A (por ejemplo, rojo).
  final List<String> playersTeamA;

  /// 🔵 Lista de IDs de jugadores del equipo B (por ejemplo, azul).
  final List<String> playersTeamB;

  /// ✅ Indican si el partido ha terminado o ha empezado.
  final bool isFinished;
  final bool hasStarted;

  /// 👥 ID del grupo al que pertenece este partido.
  final String groupId;

  /// ⚽ Goles por jugador en este partido (runtime).
  /// Clave: playerId, Valor: número de goles.
  final Map<String, int> goalsByPlayer;

  /// 🧮 Marcador en vivo por equipo.
  final int scoreTeamA;
  final int scoreTeamB;

  /// ⏱️ Tiempos de inicio y fin del partido (opcionales).
  final DateTime? startedAt;
  final DateTime? endedAt;

  Match({
    required this.id,
    required this.createdBy,
    required this.createdAt,
    required this.scheduledDate,
    required this.location,
    required this.playersTeamA,
    required this.playersTeamB,
    required this.isFinished,
    required this.hasStarted,
    required this.groupId,
    this.goalsByPlayer = const {},
    this.scoreTeamA = 0,
    this.scoreTeamB = 0,
    this.startedAt,
    this.endedAt,
  });

  /// 🔁 Crea una instancia de `Match` desde un documento de Firestore.
  factory Match.fromMap(String id, Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    final scheduledDateRaw = map['scheduledDate'];

    // ✅ En lugar de lanzar excepción, usamos fallback
    final DateTime createdAt =
        (createdAtRaw is Timestamp)
            ? createdAtRaw.toDate()
            : DateTime.now(); // o DateTime.fromMillisecondsSinceEpoch(0)

    final DateTime scheduledDate =
        (scheduledDateRaw is Timestamp)
            ? scheduledDateRaw.toDate()
            : createdAt; // si no hay scheduledDate, usa createdAt (o now)

    // goalsByPlayer puede venir nulo o con valores no-int: normalizamos.
    final Map<String, int> parsedGoals = {};
    final dynamic rawGoals = map['goalsByPlayer'];
    if (rawGoals is Map) {
      rawGoals.forEach((key, value) {
        if (key is String) {
          final intVal =
              (value is int)
                  ? value
                  : (value is num)
                  ? value.toInt()
                  : 0;
          parsedGoals[key] = intVal;
        }
      });
    }

    // startedAt / endedAt pueden no existir aún.
    final startedAtRaw = map['startedAt'];
    final endedAtRaw = map['endedAt'];

    return Match(
      id: id,
      createdBy: map['createdBy'] ?? '',
      createdAt: createdAt,
      scheduledDate: scheduledDate,
      location: (map['location'] as String?) ?? '',
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
      goalsByPlayer: parsedGoals,
      scoreTeamA:
          (map['scoreTeamA'] is int)
              ? map['scoreTeamA'] as int
              : ((map['scoreTeamA'] is num)
                  ? (map['scoreTeamA'] as num).toInt()
                  : 0),
      scoreTeamB:
          (map['scoreTeamB'] is int)
              ? map['scoreTeamB'] as int
              : ((map['scoreTeamB'] is num)
                  ? (map['scoreTeamB'] as num).toInt()
                  : 0),
      startedAt: startedAtRaw is Timestamp ? startedAtRaw.toDate() : null,
      endedAt: endedAtRaw is Timestamp ? endedAtRaw.toDate() : null,
    );
  }

  /// 🧭 Convierte el objeto `Match` en un mapa para guardarlo en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdAt': createdAt,
      'scheduledDate': scheduledDate,
      'location': location,
      'playersTeamA': playersTeamA,
      'playersTeamB': playersTeamB,
      'isFinished': isFinished,
      'hasStarted': hasStarted,
      'groupId': groupId,
      'goalsByPlayer': goalsByPlayer,
      'scoreTeamA': scoreTeamA,
      'scoreTeamB': scoreTeamB,
      if (startedAt != null) 'startedAt': startedAt,
      if (endedAt != null) 'endedAt': endedAt,
    };
  }

  /// 🧱 Helper para crear una copia con cambios.
  Match copyWith({
    String? id,
    String? createdBy,
    DateTime? createdAt,
    DateTime? scheduledDate,
    String? location,
    List<String>? playersTeamA,
    List<String>? playersTeamB,
    bool? isFinished,
    bool? hasStarted,
    String? groupId,
    Map<String, int>? goalsByPlayer,
    int? scoreTeamA,
    int? scoreTeamB,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return Match(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      location: location ?? this.location,
      playersTeamA: playersTeamA ?? this.playersTeamA,
      playersTeamB: playersTeamB ?? this.playersTeamB,
      isFinished: isFinished ?? this.isFinished,
      hasStarted: hasStarted ?? this.hasStarted,
      groupId: groupId ?? this.groupId,
      goalsByPlayer: goalsByPlayer ?? this.goalsByPlayer,
      scoreTeamA: scoreTeamA ?? this.scoreTeamA,
      scoreTeamB: scoreTeamB ?? this.scoreTeamB,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
