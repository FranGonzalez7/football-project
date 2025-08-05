// 📁 services/match_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';

/// 🛠️ Servicio encargado de manejar las operaciones relacionadas con los partidos.
///
/// Guarda los partidos dentro de la subcolección:
/// `groups/{groupId}/matches`
class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🧾 Crea un nuevo partido dentro del grupo correspondiente.
  ///
  /// [createdBy] → UID del usuario creador.
  /// [groupId] → ID del grupo donde se crea el partido.
  ///
  /// Retorna el ID del nuevo partido.
  Future<String> createMatch({
  required String createdBy,
  required String groupId,
  required DateTime scheduledDate,
}) async {
  final matchData = {
    'createdBy': createdBy,
    'createdAt': FieldValue.serverTimestamp(),
    'scheduledDate': Timestamp.fromDate(scheduledDate),
    'playersTeamA': [],
    'playersTeamB': [],
    'isFinished': false,
    'hasStarted': false,
    'groupId': groupId,
  };

  final docRef = await _firestore
      .collection('groups')
      .doc(groupId)
      .collection('matches')
      .add(matchData);

  return docRef.id;
}


  /// 🔄 Devuelve un stream en tiempo real de los partidos del grupo.
  ///
  /// Se usa para mostrar la lista de partidos (por ejemplo en la home).
  Stream<List<Match>> getMatchesForGroup(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('matches')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Match.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  /// 📄 Obtiene un partido específico por su ID dentro de un grupo.
  Future<Match?> getMatchById({
    required String groupId,
    required String matchId,
  }) async {
    final doc =
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('matches')
            .doc(matchId)
            .get();

    if (!doc.exists) return null;

    return Match.fromMap(doc.id, doc.data()!);
  }

  /// ✔️ Marca un partido como finalizado.
  Future<void> finishMatch({
    required String groupId,
    required String matchId,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('matches')
        .doc(matchId)
        .update({'isFinished': true});
  }

  /// 🧩 Actualiza los equipos A y B del partido.
  ///
  /// Se utiliza al terminar de seleccionar los jugadores para cada equipo.
  Future<void> updateTeams({
    required String groupId,
    required String matchId,
    required List<String> teamA,
    required List<String> teamB,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('matches')
        .doc(matchId)
        .update({'playersTeamA': teamA, 'playersTeamB': teamB});
  }

  /// ➕ Añade un jugador a uno de los equipos del partido.
  ///
  /// [toTeamA] indica si debe añadirse al equipo A (`true`) o al B (`false`).
  Future<void> addPlayerToTeam({
    required String groupId,
    required String matchId,
    required String playerId,
    required bool toTeamA,
  }) async {
    final teamField = toTeamA ? 'playersTeamA' : 'playersTeamB';

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('matches')
        .doc(matchId)
        .update({
          teamField: FieldValue.arrayUnion([playerId]),
        });
  }

  /// ➖ Elimina un jugador de uno de los equipos del partido.
  ///
  /// [fromTeamA] indica si debe eliminarse del equipo A (`true`) o del B (`false`).
  Future<void> removePlayerFromTeam({
    required String groupId,
    required String matchId,
    required String playerId,
    required bool fromTeamA,
  }) async {
    final teamField = fromTeamA ? 'playersTeamA' : 'playersTeamB';

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('matches')
        .doc(matchId)
        .update({
          teamField: FieldValue.arrayRemove([playerId]),
        });
  }

  /// 🔍 Devuelve solo los partidos no finalizados (en curso) de un grupo.
///
/// Útil para mostrar la lista de partidos activos en la `home_screen`.
Stream<List<Match>> getOngoingMatches(String groupId) {
  return _firestore
      .collection('groups')
      .doc(groupId)
      .collection('matches')
      .where('isFinished', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            final data = doc.data();
            // 🔒 Evita errores por createdAt nulo
            if (data['createdAt'] == null) {
              print('⚠️ Match con createdAt nulo: ${doc.id}');
              return null;
            }
            return Match.fromMap(doc.id, data);
          } catch (e) {
            print('❌ Error al convertir match: ${doc.id} → $e');
            return null;
          }
        }).whereType<Match>().toList(); // 🔍 filtra los nulos
      });
}



  /// 🗑️ Elimina un partido completo (por ejemplo, si se cancela).
  Future<void> deleteMatch({
    required String groupId,
    required String matchId,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('matches')
        .doc(matchId)
        .delete();
  }

  /// 🔍 Este método buscará si ya existe un partido no iniciado ni finalizado:
  Future<Match?> getUnstartedMatch(String groupId) async {
    final snapshot =
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('matches')
            .where('isFinished', isEqualTo: false)
            .where('hasStarted', isEqualTo: false)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return Match.fromMap(doc.id, doc.data());
  }

  /// 🟢 Marca el partido como iniciado (hasStarted = true)
  Future<void> markMatchAsStarted(String groupId, String matchId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('matches')
        .doc(matchId)
        .update({'hasStarted': true});
  }

  // 📆 Actualiza fecha del partido:
  Future<void> updateScheduledDate({
  required String groupId,
  required String matchId,
  required DateTime scheduledDate,
}) async {
  await _firestore
      .collection('groups')
      .doc(groupId)
      .collection('matches')
      .doc(matchId)
      .update({
        'scheduledDate': Timestamp.fromDate(scheduledDate),
      });
}

}
