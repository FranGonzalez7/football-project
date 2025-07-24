import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:football_picker/prueba/upload_avatar_test.dart';
import 'package:football_picker/services/auth_service.dart';
import 'package:football_picker/widgets/appbar_menu_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? groupName;
  String? groupCode;
  bool isLoading = true;
  
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadGroupName();
  }

  void _logout() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Seguro que quieres cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Salir'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await _authService.logout(); // ✅ uso del servicio
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login'); // ⚠️ Asegúrate de tener esta ruta definida
  }
}


  Future<void> _loadGroupName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final groupId = userDoc.data()?['groupId'];

    if (groupId != null) {
      final groupDoc =
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .get();
      final name = groupDoc.data()?['name'];
      final code = groupDoc.data()?['code'];
      setState(() {
        groupName = name;
        groupCode = code;
        isLoading = false;
      });
    } else {
      setState(() {
        groupName = 'Sin grupo';
        groupCode = 'Sin código';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          AppBarMenuButton(),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Welcome to ${groupName ?? 'desconocido'}',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            Text(
              'Group Code: ${groupCode ?? 'desconocido'}',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),

            const SizedBox(height: 36,),

            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Probar subida de avatar'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadAvatarTest(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.sports_soccer_outlined),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/players');
                },
                icon: Icon(Icons.people),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.space_dashboard_outlined),
              ),
            ),
            Expanded(
              child: IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
            ),
          ],
        ),
      ),
    );
  }
}
