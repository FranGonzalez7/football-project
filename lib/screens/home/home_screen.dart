import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:football_picker/services/auth_service.dart';
import 'package:football_picker/widgets/appbar_menu_button.dart';
import 'package:football_picker/widgets/appbottom_navigationbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? groupName;
  String? groupCode;
  bool isLoading = true;
  int _selectedIndex = 2; // Home por defecto

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadGroupName();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/players');
        break;
      case 1:
        //Navigator.pushNamed(context, '/matches');
        break;
      case 2:
        // Ya estás en Home, quizás no haces nada
        break;
      case 3:
        //Navigator.pushNamed(context, '/ranking');
        break;
      case 4:
        //Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
      Navigator.of(context).pushReplacementNamed(
        '/login',
      ); // ⚠️ Asegúrate de tener esta ruta definida
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

            const SizedBox(height: 36),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
