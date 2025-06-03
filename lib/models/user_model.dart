class AppUser {
  final String uid;
  final String email;
  final String groupId;

  AppUser({
    required this.uid,
    required this.email,
    required this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'groupId': groupId,
    };
  }
}
