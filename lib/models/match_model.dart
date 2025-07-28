import 'package:cloud_firestore/cloud_firestore.dart';


//TODO afinar este model con los datos necesarios
/// Representa un partido de fútbol creado en la app.
class MatchModel {
  final String id;            // ID único del partido (igual al ID del documento en Firestore)
  final DateTime date;        // Fecha del partido
  final int playersPerTeam;   // Número de jugadores por equipo (por ejemplo, 5 para 5 vs 5)
  final List<String> teamAPlayers;  // Lista de IDs de jugadores del equipo A
  final List<String> teamBPlayers;  // Lista de IDs de jugadores del equipo B
  final String createdBy;     // UID del usuario que creó el partido
  final String groupId;       // ID del grupo al que pertenece este partido

  /// Constructor del modelo
  MatchModel({
    required this.id,
    required this.date,
    required this.playersPerTeam,
    required this.teamAPlayers,
    required this.teamBPlayers,
    required this.createdBy,
    required this.groupId,
  });

  /// Crea un objeto MatchModel desde un mapa (por ejemplo, desde Firestore)
  factory MatchModel.fromMap(String id, Map<String, dynamic> data) {
    return MatchModel(
      id: id,
      date: (data['date'] as Timestamp).toDate(), // Convierte Timestamp a DateTime
      playersPerTeam: data['playersPerTeam'],
      teamAPlayers: List<String>.from(data['teamAPlayers']),
      teamBPlayers: List<String>.from(data['teamBPlayers']),
      createdBy: data['createdBy'],
      groupId: data['groupId'],
    );
  }

  /// Convierte el objeto en un mapa para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': date, // Firestore lo convierte automáticamente a Timestamp
      'playersPerTeam': playersPerTeam,
      'teamAPlayers': teamAPlayers,
      'teamBPlayers': teamBPlayers,
      'createdBy': createdBy,
      'groupId': groupId,
    };
  }
}
