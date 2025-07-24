class Player {
  final String id;           
  final String name;         
  final String position;     
  final int number;          
  final int points;          
  final String createdBy;    
  final String? photoUrl;

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.number,
    this.points = 100,
    required this.createdBy,
    this.photoUrl,
  });

  factory Player.fromMap(String id, Map<String, dynamic> data) {
    return Player(
      id: id,
      name: data['name'] ?? '',
      position: data['position'] ?? '',
      number: data['number'] ?? 0,
      points: data['points'] ?? 100,
      createdBy: data['createdBy'] ?? '',
      photoUrl: data['photoUrl'], // puede ser null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'number': number,
      'points': points,
      'createdBy': createdBy,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}
