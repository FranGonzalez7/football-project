class Player {
  final String id;           // ID del documento en Firestore
  final String name;         // Nombre del jugador
  final String position;     // Posición (como String)
  final int number;          // Número de camiseta
  final int points;          // Stats o puntos, inicializados a 150 por defecto
  final String createdBy;    // UserId del creador del jugador

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.number,
    this.points = 100,
    required this.createdBy,
  });

  // Constructor para crear un Player desde un Map (documento Firestore)
  factory Player.fromMap(String id, Map<String, dynamic> data) {
    return Player(
      id: id,
      name: data['name'] ?? '',
      position: data['position'] ?? '',
      number: data['number'] ?? 0,
      points: data['points'] ?? 100,
      createdBy: data['createdBy'] ?? '',
    );
  }

  // Convertir Player a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'number': number,
      'points': points,
      'createdBy': createdBy,
    };
  }
}
