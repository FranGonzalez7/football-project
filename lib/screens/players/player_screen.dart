import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:football_picker/services/player_services.dart';
import 'package:football_picker/screens/players/widgets/player_tile.dart';
import '../../models/player_model.dart';

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

  @override
  void initState() {
    super.initState();
    _initUserAndLoadPlayers();
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
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando jugadores: $e')));
    }
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
      appBar: AppBar(title: const Text('Player Screen')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _players.isEmpty
              ? const Center(child: Text('No hay jugadores aún.'))
              : ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];

                  return PlayerTile(
                    player: player,
                    currentUserId: _currentUserId ?? '',
                    onDelete: () => _deletePlayer(player.id),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: const Icon(Icons.add),
      ),
    );
  }
}
