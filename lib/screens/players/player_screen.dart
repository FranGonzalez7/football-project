import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:football_picker/screens/new_player/new_player_screen.dart';
import 'package:football_picker/screens/players/helpers/sort_players_helper.dart';
import 'package:football_picker/services/player_services.dart';
import 'package:football_picker/screens/players/widgets/player_tile.dart';
import 'package:football_picker/theme/app_colors.dart';
import '../../models/player_model.dart';
import 'package:football_picker/screens/players/widgets/player_sort_menu.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final PlayerService _playerService = PlayerService();

  List<Player> _players = [];
  bool _isLoading = true;
  String? _currentUserId;

  PlayerSortOption _currentSort = PlayerSortOption.nameAsc;

  @override
  void initState() {
    super.initState();
    _initUserAndLoadPlayers();
  }

  void _goToAddPlayerScreen() async {
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

  Future<void> _initUserAndLoadPlayers() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      _currentUserId = user?.uid;

      final players = await _playerService.getPlayers();
      setState(() {
        _players = players;
        _isLoading = false;
      });
      _sortPlayers();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando jugadores: $e')));
    }
  }

  // ✅ Helper para ordenar jugadores y puntuaciones:
  void _sortPlayers() {
    setState(() {
      _players = sortPlayers(_players, _currentSort);
    });
  }

  Future<void> _deletePlayer(String playerId) async {
    try {
      await _playerService.deletePlayer(playerId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jugador eliminado')));
      await _initUserAndLoadPlayers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Screen'),
        actions: [
          // ✅ Botón en AppBar para ordenar:
          PlayerSortMenu(
            currentOption: _currentSort,
            onSelected: (option) {
              setState(() => _currentSort = option);
              _sortPlayers();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _players.isEmpty
              ? const Center(child: Text('No hay jugadores aún.'))
              : ListView.builder(
                itemCount:
                    _players.length + 1, // Añadimos uno más para el espacio
                itemBuilder: (context, index) {
                  if (index == _players.length) {
                    // ✅ Espacio al final del listado de jugadores:
                    return const SizedBox(height: 75);
                  }

                  final player = _players[index];
                  return PlayerTile(
                    player: player,
                    currentUserId: _currentUserId ?? '',
                    onDelete: () => _deletePlayer(player.id),
                  );
                },
              ),

      // ✅ Botón para añadir nuevos jugadores:
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddPlayerScreen,
        icon: const Icon(Icons.person_add),
        label: const Text(
          'New Player',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.accentButton,
        foregroundColor: Colors.black,
        elevation: 8,
      ),
    );
  }
}
