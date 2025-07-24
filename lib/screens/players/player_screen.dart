import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/models/user_model.dart';

import 'package:football_picker/services/player_services.dart';

import 'package:football_picker/screens/new_player/new_player_screen.dart';
import 'package:football_picker/screens/players/helpers/sort_players_helper.dart';
import 'package:football_picker/screens/players/widgets/player_sort_menu.dart';
import 'package:football_picker/screens/players/widgets/player_tile.dart';

import 'package:football_picker/theme/app_colors.dart';

/// 🎮 Pantalla principal para mostrar y gestionar los jugadores.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final PlayerService _playerService = PlayerService();

  AppUser? _currentUser;
  String? _currentUserId;
  List<Player> _players = [];
  bool _isLoading = true;

  PlayerSortOption _currentSort = PlayerSortOption.nameAsc;

  @override
  void initState() {
    super.initState();
    _initUserAndLoadPlayers();
  }

  /// 🔁 Carga usuario actual y jugadores del grupo.
  Future<void> _initUserAndLoadPlayers() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      _currentUserId = user?.uid;

      // 👤 Obtener datos del usuario desde Firestore
      if (_currentUserId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUserId)
            .get();

        if (userDoc.exists) {
          _currentUser = AppUser.fromMap(_currentUserId!, userDoc.data()!);
        }
      }

      // 🧍 Cargar todos los jugadores del grupo
      final players = await _playerService.getPlayers();

      setState(() {
        _players = players;
        _isLoading = false;
      });

      _sortPlayers();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando jugadores: $e')),
      );
    }
  }

  /// 🔀 Ordenar jugadores según la opción actual
  void _sortPlayers() {
    setState(() {
      _players = sortPlayers(_players, _currentSort);
    });
  }

  /// ➕ Navegar a la pantalla para añadir jugador
  void _goToAddPlayerScreen() async {
    final isAdmin = _currentUser?.role == 'admin';
    final hasCreatedPlayer =
        _players.any((p) => p.createdBy == _currentUserId);

    // ❌ Si es user y ya creó un jugador → bloquear
    if (!isAdmin && hasCreatedPlayer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes añadir tu jugador.')),
      );
      return;
    }

    // ✅ Permitir si es admin o aún no ha creado ninguno
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPlayerScreen(playerService: _playerService),
      ),
    );

    if (result == true) {
      await _initUserAndLoadPlayers();
    }
  }

  /// ❌ Eliminar jugador (solo si es admin)
  Future<void> _deletePlayer(String playerId) async {
    if (_currentUser?.role != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo el administrador puede eliminar jugadores')),
      );
      return;
    }

    try {
      await _playerService.deletePlayer(playerId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jugador eliminado')),
      );
      await _initUserAndLoadPlayers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  // ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Screen'),
        actions: [
          /// 📋 Menú desplegable para ordenar jugadores
          PlayerSortMenu(
            currentOption: _currentSort,
            onSelected: (option) {
              setState(() => _currentSort = option);
              _sortPlayers();
            },
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
              ? const Center(child: Text('No hay jugadores aún.'))
              : ListView.builder(
                  itemCount: _players.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _players.length) {
                      // 🧱 Espacio al final para el FAB
                      return const SizedBox(height: 75);
                    }

                    final player = _players[index];
                    return PlayerTile(
                      player: player,
                      currentUserId: _currentUserId ?? '',
                      isAdmin: _currentUser?.role == 'admin',
                      onDelete: () => _deletePlayer(player.id),
                    );
                  },
                ),

      /// 🧍 Botón flotante para añadir jugador
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddPlayerScreen,
        icon: const Icon(Icons.person_add),
        label: const Text(
          'New Player',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryButton,
        foregroundColor: Colors.black,
        elevation: 8,
      ),
    );
  }
}
