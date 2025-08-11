import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:football_picker/screens/home/widgets/container1_groupInfoCard.dart';
import 'package:football_picker/screens/home/widgets/container2_nextMatchCard.dart';
import 'package:football_picker/screens/home/widgets/container3_playerStatsCard.dart';
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
  int _selectedIndex = 2; // 🏠 Home por defecto

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadGroupName();
  }

  // 📱 Manejo de navegación inferior
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/players');
        break;
      case 1:
        // 📝 Implementar navegación a matches
        break;
      case 2:
        // 🧭 Ya estamos en Home
        break;
      case 3:
        // 📝 Implementar navegación a ranking
        break;
      case 4:
        // 📝 Implementar navegación a ajustes
        break;
    }
  }

  // 🔐 Cerrar sesión
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
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // 🔄 Cargar información del grupo del usuario actual
  Future<void> _loadGroupName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final groupId = userDoc.data()?['groupId'];

    if (groupId != null) {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
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
        title: const Text('Home'),
        actions: [
          const AppBarMenuButton(),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🌿 Fondo de césped
          Positioned.fill(
            child: Image.asset('assets/images/cesped.jpg', fit: BoxFit.cover),
          ),
          // 🌑 Capa oscura para legibilidad
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
          // 📦 Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: GroupInfoCard(
                      groupName: groupName ?? 'desconocido',
                      groupCode: groupCode ?? 'desconocido',
                    ),
                  ),
                  const SizedBox(height: 18),
                  // 📅 Próximo partido
                  const Expanded(flex: 3, child: NextMatchCard()),
                  const SizedBox(height: 18),
                  // 📊 Estadísticas jugadores
                  const Expanded(flex: 2, child: PlayerStatsCard()),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
