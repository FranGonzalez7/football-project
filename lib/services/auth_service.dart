import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:football_picker/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Registro creando grupo (admin)

  Future<String?> registerWithNewGroup({
  required String email,
  required String password,
  required String groupName,
  required String groupCode,
}) async {
  try {
    print('🟡 Paso 1: Comprobando si el nombre del grupo ya existe');
    final existingName = await _firestore
        .collection('groups')
        .where('name', isEqualTo: groupName)
        .get();
    print('✅ Nombre consultado correctamente');

    print('🟡 Paso 2: Comprobando si el código ya existe');
    final existingCode = await _firestore
        .collection('groups')
        .where('code', isEqualTo: groupCode)
        .get();
    print('✅ Código consultado correctamente');

    if (existingName.docs.isNotEmpty) return 'Ya existe un grupo con ese nombre';
    if (existingCode.docs.isNotEmpty) return 'El código ya está en uso, elige otro';

    print('🟡 Paso 3: Creando usuario en Firebase Auth');
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = userCred.user!.uid;
    print('✅ Usuario creado correctamente: $uid');

    print('🟡 Paso 4: Creando grupo en Firestore');
    final groupDoc = await _firestore.collection('groups').add({
      'name': groupName,
      'code': groupCode.toUpperCase(),
      'members': [uid],
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('✅ Grupo creado correctamente con ID: ${groupDoc.id}');

    print('🟡 Paso 5: Creando documento del usuario');
    final user = AppUser(
      uid: uid,
      email: email,
      groupId: groupDoc.id,
      role: 'admin',
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());
    print('✅ Usuario guardado en la colección users');

    return null; // todo salió bien
  } on FirebaseAuthException catch (e) {
    print('❌ FirebaseAuth error: ${e.message}');
    return e.message;
  } catch (e) {
    print('❌ Otro error: $e');
    return 'Error: $e';
  }
}


  /// ✅ Registro uniéndose a un grupo existente (user)
  Future<String?> registerWithExistingGroup({
    required String email,
    required String password,
    required String groupCode,
  }) async {
    try {
      // 🔍 Buscar grupo por código (asegurando mayúsculas)
      final query =
          await _firestore
              .collection('groups')
              .where('code', isEqualTo: groupCode.toUpperCase())
              .limit(1)
              .get();

      // ❌ Si no se encuentra ningún grupo con ese código
      if (query.docs.isEmpty) return 'El código no corresponde a ningún grupo';

      // 🔐 Crear el usuario en Firebase Authentication
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      // 📎 Obtener referencia del grupo y su ID
      final groupDoc = query.docs.first;
      final groupId = groupDoc.id;

      // ➕ Añadir el nuevo miembro a la lista (si aún no está)
      final members = List<String>.from(groupDoc.get('members') ?? []);
      if (!members.contains(uid)) {
        members.add(uid);
        await _firestore.collection('groups').doc(groupId).update({
          'members': members,
        });
      }

      // 👤 Crear el documento del usuario con rol "user"
      final user = AppUser(
        uid: uid,
        email: email,
        groupId: groupId,
        role: 'user', // 🟡 Rol normal (no admin)
      );

      // 💾 Guardar el usuario en la colección 'users'
      await _firestore.collection('users').doc(uid).set(user.toMap());

      return null; // ✅ Registro exitoso
    } on FirebaseAuthException catch (e) {
      // ⚠️ Errores comunes de autenticación (correo duplicado, contraseña débil, etc.)
      return e.message;
    } catch (e) {
      // ⚠️ Otros errores inesperados
      return 'Error: $e';
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
