// 📁 lib/screens/score/score_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:football_picker/models/match_model.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/services/score_service.dart';

class ScoreScreen extends StatefulWidget {
  final String groupId;
  final String matchId;

  // Opcionales (por si quieres pintar nombres/colores custom sin tocar Firestore)
  final String teamAName;
  final String teamBName;
  final Color teamAColor;
  final Color teamBColor;

  const ScoreScreen({
    super.key,
    required this.groupId,
    required this.matchId,
    this.teamAName = 'Equipo A',
    this.teamBName = 'Equipo B',
    this.teamAColor = Colors.red,
    this.teamBColor = Colors.blue,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final _db = FirebaseFirestore.instance;
  final _score = ScoreService();

  // Cache local de jugadores por id (para evitar relanzar lecturas)
  final Map<String, Player> _playersCache = {};

  // Carga jugadores en lotes de 10 (límite de whereIn)
  Future<Map<String, Player>> _loadPlayersForIds(Set<String> ids) async {
    // Filtra los que ya tenemos en cache
    final toFetch = ids.where((id) => !_playersCache.containsKey(id)).toList();
    const chunkSize = 10;

    for (var i = 0; i < toFetch.length; i += chunkSize) {
      final chunk = toFetch.sublist(
        i,
        (i + chunkSize > toFetch.length) ? toFetch.length : i + chunkSize,
      );

      // Consulta por whereIn
      final snap =
          await _db
              .collection('groups')
              .doc(widget.groupId)
              .collection('players')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final p = Player.fromMap(doc.id, data);
        _playersCache[doc.id] = p;
      }
    }

    // Devuelve un mapa con lo pedido (incluye cache previa)
    return {
      for (final id in ids)
        if (_playersCache.containsKey(id)) id: _playersCache[id]!,
    };
  }

  // Widget chip de equipo
  Widget _teamChip(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('matches')
        .doc(widget.matchId);

    return Scaffold(
      appBar: AppBar(title: const Text('Marcador en vivo')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: matchRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Partido no encontrado'));
          }

          final data = snap.data!.data()!;
          final match = Match.fromMap(snap.data!.id, data);

          final isFinished = match.isFinished;
          final teamAIds = match.playersTeamA.toSet();
          final teamBIds = match.playersTeamB.toSet();
          final allIds = {...teamAIds, ...teamBIds};

          // Cargamos los jugadores (una vez por set de ids)
          return FutureBuilder<Map<String, Player>>(
            future: _loadPlayersForIds(allIds),
            builder: (context, playersSnap) {
              if (playersSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final playersMap = playersSnap.data ?? {};
              // Montamos lista con etiqueta de equipo
              final List<({Player p, String team})> allPlayers = [
                ...teamAIds
                    .where(playersMap.containsKey)
                    .map((id) => (p: playersMap[id]!, team: 'A')),
                ...teamBIds
                    .where(playersMap.containsKey)
                    .map((id) => (p: playersMap[id]!, team: 'B')),
              ];

              // Orden opcional: primero A, luego B; dentro por dorsal
              allPlayers.sort((a, b) {
                if (a.team != b.team) return a.team.compareTo(b.team);
                return a.p.number.compareTo(b.p.number);
              });

              return Column(
                children: [
                  if (isFinished)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: const Text(
                        'Partido terminado — los cambios están bloqueados.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      itemCount: allPlayers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final player = allPlayers[i].p;
                        final team = allPlayers[i].team;
                        final isA = team == 'A';
                        final teamName =
                            isA ? widget.teamAName : widget.teamBName;
                        final teamColor =
                            isA ? widget.teamAColor : widget.teamBColor;

                        final goals = match.goalsByPlayer[player.id] ?? 0;

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  (player.photoUrl != null &&
                                          player.photoUrl!.isNotEmpty)
                                      ? NetworkImage(player.photoUrl!)
                                      : null,
                              child:
                                  (player.photoUrl == null ||
                                          player.photoUrl!.isEmpty)
                                      ? Text(
                                        player.number.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                      : null,
                            ),
                            title: Text(player.name),
                            subtitle: Row(
                              children: [
                                _teamChip(teamName, teamColor),
                                if (player.position.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    player.position,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Quitar gol',
                                  onPressed:
                                      isFinished
                                          ? null
                                          : () => _score.adjustGoal(
                                            groupId: widget.groupId,
                                            matchId: widget.matchId,
                                            playerId: player.id,
                                            delta: -1,
                                          ),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(
                                  goals.toString(),
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                IconButton(
                                  tooltip: 'Añadir gol',
                                  onPressed:
                                      isFinished
                                          ? null
                                          : () => _score.adjustGoal(
                                            groupId: widget.groupId,
                                            matchId: widget.matchId,
                                            playerId: player.id,
                                            delta: 1,
                                          ),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Si quieres abrir PlayerCard al tocar:
                              // showDialog(context: context, builder: (_) => PlayerCard(player: player));
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Marcador + botón Terminar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: Column(
                      children: [
                        _ScoreBoard(
                          teamAName: widget.teamAName,
                          teamBName: widget.teamBName,
                          teamAColor: widget.teamAColor,
                          teamBColor: widget.teamBColor,
                          scoreA: match.scoreTeamA,
                          scoreB: match.scoreTeamB,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.flag),
                            label: Text(
                              isFinished
                                  ? 'Partido terminado'
                                  : 'Terminar partido',
                            ),
                            onPressed:
                                isFinished
                                    ? null
                                    : () async {
                                      await _score.finishMatch(
                                        groupId: widget.groupId,
                                        matchId: widget.matchId,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Partido cerrado y estadísticas actualizadas',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Marcador
// ────────────────────────────────────────────────────────────────────────────

class _ScoreBoard extends StatelessWidget {
  final String teamAName;
  final String teamBName;
  final Color teamAColor;
  final Color teamBColor;
  final int scoreA;
  final int scoreB;

  const _ScoreBoard({
    required this.teamAName,
    required this.teamBName,
    required this.teamAColor,
    required this.teamBColor,
    required this.scoreA,
    required this.scoreB,
  });

  @override
  Widget build(BuildContext context) {
    final textStyleTeam = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final textStyleScore = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: teamAColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    teamAName,
                    style: textStyleTeam,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Text('$scoreA  -  $scoreB', style: textStyleScore),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    teamBName,
                    style: textStyleTeam,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: teamBColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
