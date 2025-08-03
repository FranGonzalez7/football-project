import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:football_picker/models/user_model.dart';

/// 🔐 Servicio de autenticación y gestión de usuarios/grupos.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ────────────────────────────────────────────────────────────────
  /// 🛠️ Registro de usuario creando un grupo nuevo (rol: admin)
  ///
  /// Retorna `null` si el registro fue exitoso,
  /// o un `String` con el mensaje de error.
  Future<String?> registerWithNewGroup({
    required String email,
    required String password,
    required String groupName,
    required String groupCode,
  }) async {
    try {
      // 🔍 Verificar si ya existe un grupo con ese nombre
      final existingName =
          await _firestore
              .collection('groups')
              .where('name', isEqualTo: groupName)
              .get();

      // 🔍 Verificar si el código de grupo ya está en uso
      final existingCode =
          await _firestore
              .collection('groups')
              .where('code', isEqualTo: groupCode)
              .get();

      if (existingName.docs.isNotEmpty)
        return 'Ya existe un grupo con ese nombre';
      if (existingCode.docs.isNotEmpty)
        return 'El código ya está en uso, elige otro';

      // 🔐 Crear usuario en Firebase Authentication
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      // 🏗️ Crear documento del grupo
      final groupDoc = await _firestore.collection('groups').add({
        'name': groupName,
        'code': groupCode.toUpperCase(),
        'members': [uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 👤 Crear objeto AppUser con rol 'admin'
      final user = AppUser(
        uid: uid,
        email: email,
        groupId: groupDoc.id,
        role: 'admin',
      );

      // 💾 Guardar usuario en Firestore
      await _firestore.collection('users').doc(uid).set(user.toMap());

      return null; // ✅ Registro exitoso
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ────────────────────────────────────────────────────────────────
  /// 🧩 Registro de usuario uniéndose a un grupo existente (rol: user)
  ///
  /// Retorna `null` si el registro fue exitoso,
  /// o un `String` con el mensaje de error.
  Future<String?> registerWithExistingGroup({
    required String email,
    required String password,
    required String groupCode,
  }) async {
    try {
      // 🔍 Buscar grupo por código (normalizado a mayúsculas)
      final query =
          await _firestore
              .collection('groups')
              .where('code', isEqualTo: groupCode.toUpperCase())
              .limit(1)
              .get();

      if (query.docs.isEmpty) return 'El código no corresponde a ningún grupo';

      // 🔐 Crear el usuario
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      // 📎 Obtener ID del grupo y su lista de miembros
      final groupDoc = query.docs.first;
      final groupId = groupDoc.id;
      final members = List<String>.from(groupDoc.get('members') ?? []);

      // ➕ Añadir nuevo usuario si no está
      if (!members.contains(uid)) {
        members.add(uid);
        await _firestore.collection('groups').doc(groupId).update({
          'members': members,
        });
      }

      // 👤 Crear objeto AppUser con rol 'user'
      final user = AppUser(
        uid: uid,
        email: email,
        groupId: groupId,
        role: 'user',
      );

      // 💾 Guardar usuario en Firestore
      await _firestore.collection('users').doc(uid).set(user.toMap());

      return null; // ✅ Registro exitoso
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ────────────────────────────────────────────────────────────────
  /// 🔑 Iniciar sesión con email y contraseña.
  ///
  /// Retorna `null` si el login fue exitoso,
  /// o un `String` con el mensaje de error.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // ✅ Login exitoso
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ────────────────────────────────────────────────────────────────
  /// 🔓 Cerrar sesión del usuario actual.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// 📥 Obtiene el AppUser actual a partir del UID logueado.
  ///
  /// Retorna `null` si no hay sesión iniciada o no encuentra los datos en Firestore.
  Future<AppUser?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    if (!userDoc.exists) return null;

    return AppUser.fromMap(currentUser.uid, userDoc.data()!);
  }
}
