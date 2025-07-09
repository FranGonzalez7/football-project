/// 📦 Modelo de usuario para la aplicación Football Picker.
class AppUser {
  
  /// 🔑 UID único del usuario en Firebase Authentication.
  final String uid;
  /// 📧 Email del usuario.
  final String email;
  /// 🧩 ID del grupo al que pertenece el usuario.
  final String groupId;
  /// 🛡️ Rol del usuario dentro del grupo ('admin', 'user', etc.).
  final String role;

  /// 🏗️ Constructor del modelo.
  const AppUser({
    required this.uid,
    required this.email,
    required this.groupId,
    required this.role,
  });

  /// 🗺️ Convierte la instancia en un mapa para guardar en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'groupId': groupId,
      'role': role,
    };
  }

  /// 🔄 Crea un [AppUser] a partir de un [Map] recuperado de Firestore.
  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      groupId: data['groupId'] ?? '',
      role: data['role'] ?? 'user', // 🔧 Rol por defecto
    );
  }
}
