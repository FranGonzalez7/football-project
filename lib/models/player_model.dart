class Player {
  // 🆔 Identificador único del jugador (Firebase)
  final String id;

  // 🧍 Nombre del jugador
  final String name;

  // 🧭 Posición en el campo
  final String position;

  // 🔢 Número de camiseta
  final int number;

  // 👤 ID del usuario que creó el jugador
  final String createdBy;

  // 🖼️ URL de la foto del jugador (opcional)
  final String? photoUrl;

  // 📊 Estadísticas
  // 🏆 Puntos totales (valoración general)
  final int points;
  final int matchesPlayed; // 🕹️ Partidos jugados
  final int matchesWon; // ✅ Partidos ganados
  final int goals; // ⚽ Goles marcados

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.number,
    this.points = 100,
    required this.createdBy,
    this.photoUrl,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.goals = 0,
  });

  // 🏗️ Crear jugador desde un Map (Firebase)
  factory Player.fromMap(String id, Map<String, dynamic> data) {
    return Player(
      id: id,
      name: data['name'] ?? '',
      position: data['position'] ?? '',
      number: data['number'] ?? 0,
      points: data['points'] ?? 100,
      createdBy: data['createdBy'] ?? '',
      photoUrl: data['photoUrl'],
      matchesPlayed: data['matchesPlayed'] ?? 0,
      matchesWon: data['matchesWon'] ?? 0,
      goals: data['goals'] ?? 0,
    );
  }

  // 🧾 Convertir jugador a Map para guardar en Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'number': number,
      'points': points,
      'createdBy': createdBy,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'matchesPlayed': matchesPlayed,
      'matchesWon': matchesWon,
      'goals': goals,
    };
  }
}
