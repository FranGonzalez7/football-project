import 'package:flutter/material.dart';

import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/services/player_services.dart';
import 'package:football_picker/services/match_service.dart';
import 'package:football_picker/theme/app_colors.dart';

import 'package:football_picker/screens/new_match/widgets/match_header.dart';
import 'package:football_picker/screens/new_match/widgets/field_board.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_panel.dart';
import 'package:football_picker/screens/new_match/widgets/new_match_FABs.dart';
import 'package:football_picker/screens/new_match/utils/edit_location_dialog.dart';

/// Pantalla principal para configurar un partido 5v5:
/// - Cabecera con fecha/lugar
/// - Tablero con slots (U1..U5 y D6..D10)
/// - Selector inferior de jugadores
class NewMatchScreen extends StatefulWidget {
  final String groupId;
  final String matchId;

  const NewMatchScreen({
    super.key,
    required this.groupId,
    required this.matchId,
  });

  @override
  State<NewMatchScreen> createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends State<NewMatchScreen> {
  // --- Datos base
  late final Future<List<Player>> _playersFuture;
  final PlayerService _playerService = PlayerService();

  // --- Estado de configuración
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _matchLocation = '';

  // --- Selección actual en el panel inferior
  String? _selectedPlayerId;

  // --- Asignaciones locales de slots -> playerId (se actualizan con el stream)
  Map<String, String?> _slotAssignments = _defaultSlots();

  // --- Índice rápido por id
  Map<String, Player> _playersById = {};

  // Helpers para no repetir literales
  static const List<String> _upperSlots = ['U1', 'U2', 'U3', 'U4', 'U5'];
  static const List<String> _lowerSlots = ['D6', 'D7', 'D8', 'D9', 'D10'];
  static const List<String> _allSlots = [..._upperSlots, ..._lowerSlots];

  static Map<String, String?> _defaultSlots() => {
    for (final s in _allSlots) s: null,
  };

  @override
  void initState() {
    super.initState();
    _playersFuture = _playerService.getPlayers();

    // Carga inicial de fecha y lugar desde el match
    MatchService()
        .getMatchById(groupId: widget.groupId, matchId: widget.matchId)
        .then((match) {
          if (!mounted || match == null) return;
          setState(() {
            _selectedDate = match.scheduledDate;
            _selectedTime = TimeOfDay.fromDateTime(match.scheduledDate);
            _matchLocation = match.location.toString();
          });
        });
  }

  // -------------------- Acciones de edición --------------------

  Future<void> _editLocation() async {
    final value = await showEditLocationDialog(
      context,
      initialValue: _matchLocation,
    );
    if (value == null || value == _matchLocation) return;

    setState(() => _matchLocation = value);

    await MatchService().updateMatchFields(
      groupId: widget.groupId,
      matchId: widget.matchId,
      data: {'location': _matchLocation},
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Lugar actualizado')));
  }

  Future<void> _editDateTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now, // evita fechas pasadas; ajusta si quieres
      lastDate: DateTime(2080),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.fromDateTime(now),
    );
    if (pickedTime == null) return;

    final dt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedDate = dt;
      _selectedTime = pickedTime;
    });

    await MatchService().updateScheduledDate(
      groupId: widget.groupId,
      matchId: widget.matchId,
      scheduledDate: dt,
    );
  }

  // -------------------- Asignaciones de slots --------------------

  /// Asigna el jugador seleccionado al [slotId].
  /// Si ese jugador ya estaba en otro slot, lo limpia primero.
  Future<void> _assignToSlot(String slotId) async {
    if (_selectedPlayerId == null) return;

    // Limpiamos cualquier slot que tenga a ese jugador
    final previous = _slotAssignments.entries.firstWhere(
      (e) => e.value == _selectedPlayerId,
      orElse: () => const MapEntry('', null),
    );
    if (previous.key.isNotEmpty) {
      _slotAssignments[previous.key] = null;
    }

    setState(() {
      _slotAssignments[slotId] = _selectedPlayerId;
      _selectedPlayerId = null; // des-selecciona tras asignar
    });

    await MatchService().updateSlotAssignments(
      groupId: widget.groupId,
      matchId: widget.matchId,
      assignments: _slotAssignments,
    );
  }

  Future<void> _clearSlot(String slotId) async {
    setState(() => _slotAssignments[slotId] = null);

    await MatchService().updateSlotAssignments(
      groupId: widget.groupId,
      matchId: widget.matchId,
      assignments: _slotAssignments,
    );
  }

  Future<void> _onSlotTap(String slotId) async {
    if (_selectedPlayerId != null) {
      // 👆 Asigna si hay un jugador seleccionado
      await _assignToSlot(slotId);
      return;
    }

    // 🧹 Si no hay selección y el slot está ocupado, límpialo
    final current = _slotAssignments[slotId];
    if (current != null) {
      await _clearSlot(slotId);
    }
    // Si está vacío y no hay selección → no hacemos nada
  }

  // -------------------- Inicio del partido --------------------

  Future<void> _startMatch() async {
    final teamA =
        _upperSlots
            .map((s) => _slotAssignments[s])
            .whereType<String>()
            .toList();
    final teamB =
        _lowerSlots
            .map((s) => _slotAssignments[s])
            .whereType<String>()
            .toList();

    if (teamA.length != 5 || teamB.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona 5 jugadores por equipo')),
      );
      return;
    }

    final ms = MatchService();
    await ms.updateTeams(
      groupId: widget.groupId,
      matchId: widget.matchId,
      teamA: teamA,
      teamB: teamB,
    );
    await ms.markMatchAsStarted(widget.groupId, widget.matchId);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('¡Partido comenzado!')));
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    final viewPadding =
        MediaQuery.maybeOf(context)?.viewPadding ?? EdgeInsets.zero;

    return Scaffold(
      appBar: AppBar(
        title: const Text('5 vs 5'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.place_outlined),
            tooltip: 'Lugar del partido',
            onPressed: _editLocation,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Fecha y hora',
            onPressed: _editDateTime,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: FutureBuilder<List<Player>>(
          future: _playersFuture,
          builder: (context, snapPlayers) {
            if (snapPlayers.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapPlayers.hasError ||
                !snapPlayers.hasData ||
                snapPlayers.data!.isEmpty) {
              return const Center(child: Text('No hay jugadores disponibles'));
            }

            final players = snapPlayers.data!;
            _playersById = {for (final p in players) p.id: p};

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MatchHeader(
                  selectedDate: _selectedDate,
                  location: _matchLocation,
                ),
                const SizedBox(height: 4),

                // Board + panel inferior sincronizados con el stream
                Expanded(
                  child: StreamBuilder<Map<String, String>>(
                    stream: MatchService().watchSlotAssignments(
                      groupId: widget.groupId,
                      matchId: widget.matchId,
                    ),
                    builder: (context, snap) {
                      // Estado base
                      final live = _defaultSlots();

                      // Mezcla segura con lo que venga del stream
                      if (snap.hasData) {
                        for (final e in snap.data!.entries) {
                          if (live.containsKey(e.key)) live[e.key] = e.value;
                        }
                      }
                      _slotAssignments = Map<String, String?>.from(live);

                      // Conjunto de ids ya asignados (para filtrar el panel)
                      final assignedIds =
                          _slotAssignments.values.whereType<String>().toSet();

                      return Column(
                        children: [
                          Expanded(
                            child: FieldBoard(
                              playersById: _playersById,
                              liveAssignments: _slotAssignments,
                              // Resalta todos los slots cuando hay un jugador seleccionado
                              highlightAll: _selectedPlayerId != null,
                              // 👇 Tap inteligente (asigna o borra)
                              onU1: () => _onSlotTap('U1'),
                              onU2: () => _onSlotTap('U2'),
                              onU3: () => _onSlotTap('U3'),
                              onU4: () => _onSlotTap('U4'),
                              onU5: () => _onSlotTap('U5'),
                              onD6: () => _onSlotTap('D6'),
                              onD7: () => _onSlotTap('D7'),
                              onD8: () => _onSlotTap('D8'),
                              onD9: () => _onSlotTap('D9'),
                              onD10: () => _onSlotTap('D10'),
                              // Callbacks de limpieza
                              clearU1: () => _clearSlot('U1'),
                              clearU2: () => _clearSlot('U2'),
                              clearU3: () => _clearSlot('U3'),
                              clearU4: () => _clearSlot('U4'),
                              clearU5: () => _clearSlot('U5'),
                              clearD6: () => _clearSlot('D6'),
                              clearD7: () => _clearSlot('D7'),
                              clearD8: () => _clearSlot('D8'),
                              clearD9: () => _clearSlot('D9'),
                              clearD10: () => _clearSlot('D10'),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Panel inferior con lista filtrada y acción de empezar
                          PlayerSelectorPanel(
                            playersById: _playersById,
                            assignedIds: assignedIds,
                            selectedPlayerId: _selectedPlayerId,
                            onPlayerTap: (player) {
                              setState(() {
                                _selectedPlayerId =
                                    (_selectedPlayerId == player.id)
                                        ? null
                                        : player.id;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // FABs (de momento conecto Start; Filter queda como TODO)
      floatingActionButton: Padding(
        // Altura del selector + margen + safe area
        padding: EdgeInsets.only(bottom: 96 + viewPadding.bottom),
        child: Align(
          alignment: Alignment.bottomRight,
          child: NewMatchFABs(
            onStartMatch: _startMatch,
            onFilter: () {
              // TODO: abrir modal de filtros del selector si decides añadirlo
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
