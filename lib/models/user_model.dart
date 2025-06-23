class AppUser {
  final String uid;
  final String email;
  final String groupId;
  final String role; // 🔥 Nuevo campo

  AppUser({
    required this.uid,
    required this.email,
    required this.groupId,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'groupId': groupId,
      'role': role,
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      groupId: data['groupId'] ?? '',
      role: data['role'] ?? 'user', // 🔧 'user' por defecto si no existe
    );
  }
}
