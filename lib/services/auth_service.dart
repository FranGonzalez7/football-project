import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:football_picker/models/user_model.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Registro creando grupo
  Future<String?> registerWithNewGroup({
    required String email,
    required String password,
    required String groupName,
    required String groupCode,
  }) async {
    try {
      // Verificar que el nombre y código del grupo no existan
      final existingName = await _firestore
          .collection('groups')
          .where('name', isEqualTo: groupName)
          .get();

      final existingCode = await _firestore
          .collection('groups')
          .where('code', isEqualTo: groupCode)
          .get();

      if (existingName.docs.isNotEmpty) return 'Ya existe un grupo con ese nombre';
      if (existingCode.docs.isNotEmpty) return 'El código ya está en uso, elige otro';

      // Crear usuario
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      // Crear grupo
      final groupDoc = await _firestore.collection('groups').add({
        'name': groupName,
        'code': groupCode.toUpperCase(),
        'members': [uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Crear usuario en Firestore
      final user = AppUser(uid: uid, email: email, groupId: groupDoc.id);
      await _firestore.collection('users').doc(uid).set(user.toMap());

      return null; // sin error
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// ✅ Registro uniéndose a grupo
  Future<String?> registerWithExistingGroup({
    required String email,
    required String password,
    required String groupCode,
  }) async {
    try {
      final query = await _firestore
          .collection('groups')
          .where('code', isEqualTo: groupCode.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return 'El código no corresponde a ningún grupo';

      // Crear usuario
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;
      final groupDoc = query.docs.first;
      final groupId = groupDoc.id;

      // Añadir a la lista de miembros si no está
      final members = List<String>.from(groupDoc.get('members') ?? []);
      if (!members.contains(uid)) {
        members.add(uid);
        await _firestore.collection('groups').doc(groupId).update({
          'members': members,
        });
      }

      // Crear usuario en Firestore
      final user = AppUser(uid: uid, email: email, groupId: groupId);
      await _firestore.collection('users').doc(uid).set(user.toMap());

      return null; // sin error
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error: $e';
    }
  }
}
