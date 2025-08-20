// services/score_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreService {
  ScoreService._();
  static final ScoreService _instance = ScoreService._();
  factory ScoreService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _matchRef(String groupId, String matchId) {
    return _db.collection('groups').doc(groupId).collection('matches').doc(matchId);
  }

  /// Inicializa marcador y mapa de goles dentro del match ANIDADO al grupo
  Future<void> startMatch({
    required String groupId,
    required String matchId,
    required List<String> teamAPlayerIds,
    required List<String> teamBPlayerIds,
  }) async {
    final matchRef = _matchRef(groupId, matchId);
    final zeroGoals = {
      for (final id in [...teamAPlayerIds, ...teamBPlayerIds]) id: 0,
    };
    await matchRef.set({
      'hasStarted': true,
      'isFinished': false,
      'startedAt': FieldValue.serverTimestamp(),
      'goalsByPlayer': zeroGoals,
      'scoreTeamA': 0,
      'scoreTeamB': 0,
    }, SetOptions(merge: true));
  }

  /// +1 / -1 gol a un jugador (transacción) en ruta anidada
  Future<void> adjustGoal({
    required String groupId,
    required String matchId,
    required String playerId,
    required int delta, // +1 o -1
  }) async {
    assert(delta == 1 || delta == -1);
    final matchRef = _matchRef(groupId, matchId);

    await _db.runTransaction((txn) async {
      final snap = await txn.get(matchRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;

      if ((data['isFinished'] as bool?) ?? false) return;

      final List<dynamic> rawA = (data['playersTeamA'] as List?) ?? const [];
      final List<dynamic> rawB = (data['playersTeamB'] as List?) ?? const [];
      final isA = rawA.map((e) => e.toString()).contains(playerId);
      final isB = rawB.map((e) => e.toString()).contains(playerId);
      if (!isA && !isB) return;

      final goalsByPlayer = Map<String, dynamic>.from((data['goalsByPlayer'] as Map?) ?? {});
      final int current = _asInt(goalsByPlayer[playerId]);
      final int next = delta == -1 ? (current > 0 ? current - 1 : 0) : current + 1;
      if (next == current) return;

      goalsByPlayer[playerId] = next;

      int scoreA = _asInt(data['scoreTeamA']);
      int scoreB = _asInt(data['scoreTeamB']);
      if (delta == 1) {
        if (isA) scoreA++;
        if (isB) scoreB++;
      } else {
        if (isA && scoreA > 0) scoreA--;
        if (isB && scoreB > 0) scoreB--;
      }

      txn.update(matchRef, {
        'goalsByPlayer': goalsByPlayer,
        'scoreTeamA': scoreA,
        'scoreTeamB': scoreB,
      });
    });
  }

  /// Termina partido y actualiza stats globales de jugadores (en raíz o donde los tengas)
  Future<void> finishMatch({
    required String groupId,
    required String matchId,
  }) async {
    final matchRef = _matchRef(groupId, matchId);
    final snap = await matchRef.get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    if ((data['isFinished'] as bool?) ?? false) return;

    final teamA = ((data['playersTeamA'] as List?) ?? const []).map((e) => e.toString()).toSet();
    final teamB = ((data['playersTeamB'] as List?) ?? const []).map((e) => e.toString()).toSet();
    final goalsByPlayer = Map<String, dynamic>.from((data['goalsByPlayer'] as Map?) ?? {});
    final scoreA = _asInt(data['scoreTeamA']);
    final scoreB = _asInt(data['scoreTeamB']);
    final winnerTeam = scoreA > scoreB ? 'A' : scoreB > scoreA ? 'B' : 'draw';

    final batch = _db.batch();

    // Cerrar match
    batch.update(matchRef, {
      'isFinished': true,
      'hasStarted': false,
      'endedAt': FieldValue.serverTimestamp(),
      'winnerTeam': winnerTeam,
    });

    // Actualizar stats de jugadores (ajusta la ruta si tus players están en otro sitio)
    void _upd(String pid) {
      final g = _asInt(goalsByPlayer[pid]);
      final pref = _db.collection('players').doc(pid); // <-- si tus players están en groups/{gid}/players, cámbialo
      final upd = <String, dynamic>{'matchesPlayed': FieldValue.increment(1)};
      if (g > 0) upd['goals'] = FieldValue.increment(g);
      if (winnerTeam == 'A' && teamA.contains(pid)) upd['matchesWon'] = FieldValue.increment(1);
      if (winnerTeam == 'B' && teamB.contains(pid)) upd['matchesWon'] = FieldValue.increment(1);
      batch.set(pref, upd, SetOptions(merge: true));
    }

    for (final id in teamA) _upd(id);
    for (final id in teamB) if (!teamA.contains(id)) _upd(id);

    await batch.commit();
  }

  static int _asInt(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
}
