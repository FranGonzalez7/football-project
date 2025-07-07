import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/player_model.dart';

class PlayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el groupId del usuario actual desde la colección 'users'
  Future<String?> _getGroupId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.data()?['groupId'] as String?;
  }

  // Obtener todos los jugadores del grupo del usuario actual
  Future<List<Player>> getPlayers() async {
    final groupId = await _getGroupId();
    if (groupId == null) return [];

    final snapshot =
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('players')
            .get();

    return snapshot.docs
        .map((doc) => Player.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Añadir un nuevo jugador al grupo del usuario actual
  Future<void> addPlayer(Player player) async {
    final uid = _auth.currentUser?.uid;
    final groupId = await _getGroupId();

    if (uid == null || groupId == null) {
      throw Exception('Usuario no autenticado o grupo no encontrado');
    }

    // Preparamos los datos para Firestore, añadiendo el UID del creador
    final playerData = player.toMap();
    playerData['createdBy'] = uid;

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('players')
        .add(playerData);
  }

  Future<void> deletePlayer(String playerId) async {
    final uid = _auth.currentUser?.uid;
    final groupId = await _getGroupId();

    if (uid == null || groupId == null) {
      throw Exception('Usuario no autenticado o grupo no encontrado');
    }

    // Obtener el rol del usuario actual
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final role = userDoc.data()?['role'];

    final isAdmin = role == 'admin';
    if (!isAdmin) {
      throw Exception('Solo el administrador puede eliminar jugadores.');
    }

    // Proceder a eliminar el jugador
    final docRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('players')
        .doc(playerId);

    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('Jugador no encontrado.');
    }

    await docRef.delete();
  }
}
