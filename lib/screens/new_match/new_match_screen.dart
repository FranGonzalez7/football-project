import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/new_match_FABs.dart';
import 'package:football_picker/services/player_services.dart';
import 'package:football_picker/services/match_service.dart';
import 'package:football_picker/theme/app_colors.dart';

import 'package:football_picker/screens/new_match/widgets/match_header.dart';
import 'package:football_picker/screens/new_match/widgets/field_board.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_panel.dart';
import 'package:football_picker/screens/new_match/utils/edit_location_dialog.dart';

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
  late Future<List<Player>> _playersFuture;
  final PlayerService _playerService = PlayerService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _matchLocation = '';

  String? _selectedPlayerId;

  // Copia local (inmediata) de asignaciones
  Map<String, String?> _slotAssignments = _defaultSlots();

  // Para lookup rápido
  Map<String, Player> _playersById = {};

  static Map<String, String?> _defaultSlots() => {
    'U1': null,
    'U2': null,
    'U3': null,
    'U4': null,
    'U5': null,
    'D10': null,
    'D9': null,
    'D8': null,
    'D7': null,
    'D6': null,
  };

  @override
  void initState() {
    super.initState();
    _playersFuture = _playerService.getPlayers();

    // Cargar fecha + lugar iniciales
    MatchService()
        .getMatchById(groupId: widget.groupId, matchId: widget.matchId)
        .then((match) {
          if (match != null && mounted) {
            setState(() {
              _selectedDate = match.scheduledDate;
              _selectedTime = TimeOfDay.fromDateTime(match.scheduledDate);
              _matchLocation = match.location.toString();
            });
          }
        });
  }

  // --- Editar ubicación
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

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lugar actualizado')));
    }
  }

  // --- Editar fecha/hora
  Future<void> _editDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2025),
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

  // --- Asignar / limpiar slots
  Future<void> _assignToSlot(String slotId) async {
    if (_selectedPlayerId == null) return;

    final previous = _slotAssignments.entries.firstWhere(
      (e) => e.value == _selectedPlayerId,
      orElse: () => const MapEntry('', null),
    );
    if (previous.key.isNotEmpty) _slotAssignments[previous.key] = null;

    setState(() {
      _slotAssignments[slotId] = _selectedPlayerId;
      _selectedPlayerId = null;
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

  // --- Empezar partido
  Future<void> _startMatch() async {
    final teamA =
        [
          'U1',
          'U2',
          'U3',
          'U4',
          'U5',
        ].map((s) => _slotAssignments[s]).whereType<String>().toList();
    final teamB =
        [
          'D6',
          'D7',
          'D8',
          'D9',
          'D10',
        ].map((s) => _slotAssignments[s]).whereType<String>().toList();

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

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('¡Partido comenzado!')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(height: 4),

                // Board en tiempo real
                Expanded(
                  child: StreamBuilder<Map<String, String>>(
                    stream: MatchService().watchSlotAssignments(
                      groupId: widget.groupId,
                      matchId: widget.matchId,
                    ),
                    builder: (context, snap) {
                      final live = _defaultSlots();
                      if (snap.hasData) {
                        for (final e in snap.data!.entries) {
                          if (live.containsKey(e.key)) live[e.key] = e.value;
                        }
                      }
                      _slotAssignments = Map<String, String?>.from(live);

                      final assignedIds = <String>{
                        ..._slotAssignments.values.whereType<String>(),
                        if (snap.hasData)
                          ...snap.data!.values.whereType<String>(),
                      };

                      return Column(
                        children: [
                          Expanded(
                            child: FieldBoard(
                              playersById: _playersById,
                              liveAssignments: _slotAssignments,
                              highlightAll: _selectedPlayerId != null,
                              onU1: () => _assignToSlot('U1'),
                              onU2: () => _assignToSlot('U2'),
                              onU3: () => _assignToSlot('U3'),
                              onU4: () => _assignToSlot('U4'),
                              onU5: () => _assignToSlot('U5'),
                              onD6: () => _assignToSlot('D6'),
                              onD7: () => _assignToSlot('D7'),
                              onD8: () => _assignToSlot('D8'),
                              onD9: () => _assignToSlot('D9'),
                              onD10: () => _assignToSlot('D10'),
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
                          Container(height: 18),

                          // Panel inferior
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
                            onStartMatch: _startMatch,
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

      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom:
              96 +
              MediaQuery.viewPaddingOf(
                context,
              ).bottom, // altura selector + margen
          
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: NewMatchFABs(onStartMatch: () {}, onFilter: () {}),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
