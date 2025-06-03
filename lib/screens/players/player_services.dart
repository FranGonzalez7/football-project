import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'player_model.dart';

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

    final snapshot = await _firestore
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

  // Eliminar un jugador solo si fue creado por el usuario actual
  Future<void> deletePlayer(String playerId) async {
    final uid = _auth.currentUser?.uid;
    final groupId = await _getGroupId();

    if (uid == null || groupId == null) {
      throw Exception('Usuario no autenticado o grupo no encontrado');
    }

    final docRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('players')
        .doc(playerId);

    final doc = await docRef.get();

    // Comprobar que el jugador existe y que el usuario es el creador
    if (doc.exists && doc.data()?['createdBy'] == uid) {
      await docRef.delete();
    } else {
      throw Exception('No tienes permiso para eliminar este jugador.');
    }
  }
}
