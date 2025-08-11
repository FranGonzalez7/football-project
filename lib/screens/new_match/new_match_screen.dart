import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_list.dart';
import 'package:football_picker/services/match_service.dart'; // ¡ojo: singular!
import 'package:football_picker/services/player_services.dart';
import 'package:football_picker/theme/app_colors.dart';
import 'package:football_picker/widgets/custom_primary_button.dart';
import 'package:intl/intl.dart';

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

  String? _selectedPlayerId; // jugador seleccionado en la tira

  // Copia local de asignaciones para respuesta inmediata
  Map<String, String?> slotAssignments = _defaultSlots();

  // Para renderizar avatar/nombre rápido por id
  Map<String, Player> _playersById = {};

  // Slots por defecto
  static Map<String, String?> _defaultSlots() => {
    'U1': null, 'U2': null, 'U3': null, 'U4': null, 'U5': null, // arriba (rojo)
    'D10': null, 'D9': null, 'D8': null, 'D7': null, 'D6': null, // abajo (azul)
  };

  @override
  void initState() {
    super.initState();
    _playersFuture = _playerService.getPlayers();

    // Cargar fecha programada del partido
    MatchService()
        .getMatchById(groupId: widget.groupId, matchId: widget.matchId)
        .then((match) {
          if (match != null && mounted) {
            setState(() => _selectedDate = match.scheduledDate);
          }
        });
  }

  // Asignar jugador al slot y persistir
  Future<void> _assignToSlot(String slotId) async {
    if (_selectedPlayerId == null) return;

    // Evitar duplicados: si ya estaba en otro slot, lo quitamos
    final previous = slotAssignments.entries.firstWhere(
      (e) => e.value == _selectedPlayerId,
      orElse: () => const MapEntry('', null),
    );
    if (previous.key.isNotEmpty) slotAssignments[previous.key] = null;

    setState(() {
      slotAssignments[slotId] = _selectedPlayerId;
      _selectedPlayerId = null; // limpiar selección en la UI
    });

    await MatchService().updateSlotAssignments(
      groupId: widget.groupId,
      matchId: widget.matchId,
      assignments: slotAssignments,
    );
  }

  // Limpiar slot y persistir
  Future<void> _clearSlot(String slotId) async {
    setState(() => slotAssignments[slotId] = null);

    await MatchService().updateSlotAssignments(
      groupId: widget.groupId,
      matchId: widget.matchId,
      assignments: slotAssignments,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color upperTeam = Colors.red;
    const Color lowerTeam = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('5 vs 5'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime now = DateTime.now();

              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? now,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.fromDateTime(now),
                );

                if (pickedTime != null) {
                  final scheduledDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );

                  setState(() {
                    _selectedDate = scheduledDateTime;
                    _selectedTime = pickedTime;
                  });

                  await MatchService().updateScheduledDate(
                    groupId: widget.groupId,
                    matchId: widget.matchId,
                    scheduledDate: scheduledDateTime,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
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

            // Con jugadores cargados, ya podemos renderizar tablero + selector
            final players = snapPlayers.data!;
            _playersById = {for (final p in players) p.id: p};

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fecha
                Text(
                  _selectedDate != null
                      ? '📅 ${DateFormat('dd/MM/yyyy – HH:mm').format(_selectedDate!)}'
                      : '📅 Fecha no seleccionada',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),

                // TABLERO + SLOTS en TIEMPO REAL
                Expanded(
                  child: StreamBuilder<Map<String, String>>(
                    stream: MatchService().watchSlotAssignments(
                      groupId: widget.groupId,
                      matchId: widget.matchId,
                    ),
                    builder: (context, snap) {
                      // Fusiona datos en vivo con slots por defecto
                      final live = _defaultSlots();
                      if (snap.hasData) {
                        for (final e in snap.data!.entries) {
                          if (live.containsKey(e.key)) live[e.key] = e.value;
                        }
                      }
                      // Mantén una copia local para la respuesta inmediata
                      slotAssignments = Map<String, String?>.from(live);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: AspectRatio(
                          aspectRatio:
                              16 /
                              9, // si tu imagen es vertical, puedes cambiar a 9/16
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/images/field_white_vertical.png',
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // ------- UPPER (rojo)
                              Positioned(
                                left: 192,
                                top: 16,
                                child: _SlotBubble(
                                  id: 'U1',
                                  teamColor: upperTeam,
                                  number: '1',
                                  assigned:
                                      live['U1'] != null
                                          ? _playersById[live['U1']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('U1'),
                                  onLongPress: () => _clearSlot('U1'),
                                ),
                              ),
                              Positioned(
                                left: 192,
                                top: 116,
                                child: _SlotBubble(
                                  id: 'U2',
                                  teamColor: upperTeam,
                                  number: '2',
                                  assigned:
                                      live['U2'] != null
                                          ? _playersById[live['U2']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('U2'),
                                  onLongPress: () => _clearSlot('U2'),
                                ),
                              ),
                              Positioned(
                                left: 192,
                                top: 246,
                                child: _SlotBubble(
                                  id: 'U3',
                                  teamColor: upperTeam,
                                  number: '3',
                                  assigned:
                                      live['U3'] != null
                                          ? _playersById[live['U3']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('U3'),
                                  onLongPress: () => _clearSlot('U3'),
                                ),
                              ),
                              Positioned(
                                left: 56,
                                top: 181,
                                child: _SlotBubble(
                                  id: 'U4',
                                  teamColor: upperTeam,
                                  number: '4',
                                  assigned:
                                      live['U4'] != null
                                          ? _playersById[live['U4']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('U4'),
                                  onLongPress: () => _clearSlot('U4'),
                                ),
                              ),
                              Positioned(
                                right: 56,
                                top: 181,
                                child: _SlotBubble(
                                  id: 'U5',
                                  teamColor: upperTeam,
                                  number: '5',
                                  assigned:
                                      live['U5'] != null
                                          ? _playersById[live['U5']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('U5'),
                                  onLongPress: () => _clearSlot('U5'),
                                ),
                              ),

                              // ------- LOWER (azul)
                              Positioned(
                                left: 192,
                                bottom: 16,
                                child: _SlotBubble(
                                  id: 'D10',
                                  teamColor: lowerTeam,
                                  number: '10',
                                  assigned:
                                      live['D10'] != null
                                          ? _playersById[live['D10']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('D10'),
                                  onLongPress: () => _clearSlot('D10'),
                                ),
                              ),
                              Positioned(
                                left: 192,
                                bottom: 116,
                                child: _SlotBubble(
                                  id: 'D9',
                                  teamColor: lowerTeam,
                                  number: '9',
                                  assigned:
                                      live['D9'] != null
                                          ? _playersById[live['D9']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('D9'),
                                  onLongPress: () => _clearSlot('D9'),
                                ),
                              ),
                              Positioned(
                                left: 192,
                                bottom: 246,
                                child: _SlotBubble(
                                  id: 'D8',
                                  teamColor: lowerTeam,
                                  number: '8',
                                  assigned:
                                      live['D8'] != null
                                          ? _playersById[live['D8']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('D8'),
                                  onLongPress: () => _clearSlot('D8'),
                                ),
                              ),
                              Positioned(
                                left: 56,
                                bottom: 181,
                                child: _SlotBubble(
                                  id: 'D7',
                                  teamColor: lowerTeam,
                                  number: '7',
                                  assigned:
                                      live['D7'] != null
                                          ? _playersById[live['D7']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('D7'),
                                  onLongPress: () => _clearSlot('D7'),
                                ),
                              ),
                              Positioned(
                                right: 56,
                                bottom: 181,
                                child: _SlotBubble(
                                  id: 'D6',
                                  teamColor: lowerTeam,
                                  number: '6',
                                  assigned:
                                      live['D6'] != null
                                          ? _playersById[live['D6']!]
                                          : null,
                                  highlighted: _selectedPlayerId != null,
                                  onTap: () => _assignToSlot('D6'),
                                  onLongPress: () => _clearSlot('D6'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Selector jugadores + botón
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Seleccionar jugadores',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 👇 Usamos el stream para saber quién está asignado y ocultarlo del selector
                      StreamBuilder<Map<String, String>>(
                        stream: MatchService().watchSlotAssignments(
                          groupId: widget.groupId,
                          matchId: widget.matchId,
                        ),
                        builder: (context, snap) {
                          // ids asignados actualmente
                          final assignedIds = <String>{
                            ...slotAssignments.values.whereType<String>(),
                            if (snap.hasData)
                              ...snap.data!.values.whereType<String>(),
                          };

                          // jugadores disponibles (no asignados)
                          final availablePlayers =
                              _playersById.values
                                  .where((p) => !assignedIds.contains(p.id))
                                  .toList();

                          return PlayerSelectorList(
                            players: availablePlayers,
                            playerColors: {
                              for (var p in availablePlayers) p.id: Colors.blue,
                            },
                            selectedPlayerId: _selectedPlayerId,
                            onPlayerTap: (player) {
                              setState(() {
                                _selectedPlayerId =
                                    (_selectedPlayerId == player.id)
                                        ? null
                                        : player.id;
                              });
                            },
                          );
                        },
                      ),
                      const Spacer(),
                      CustomPrimaryButton(
                        text: 'Comenzar Partido',
                        onPressed: () async {
                          final teamA =
                              ['U1', 'U2', 'U3', 'U4', 'U5']
                                  .map((s) => slotAssignments[s])
                                  .whereType<String>()
                                  .toList();

                          final teamB =
                              ['D6', 'D7', 'D8', 'D9', 'D10']
                                  .map((s) => slotAssignments[s])
                                  .whereType<String>()
                                  .toList();

                          if (teamA.length != 5 || teamB.length != 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Selecciona 5 jugadores por equipo',
                                ),
                              ),
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

                          await ms.markMatchAsStarted(
                            widget.groupId,
                            widget.matchId,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Partido comenzado!'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlotBubble extends StatelessWidget {
  final String id;
  final Color teamColor;
  final String number;
  final Player? assigned;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SlotBubble({
    required this.id,
    required this.teamColor,
    required this.number,
    required this.assigned,
    required this.highlighted,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final filled = assigned != null;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: teamColor, width: highlighted ? 3 : 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage:
                  filled &&
                          (assigned!.photoUrl != null &&
                              assigned!.photoUrl!.isNotEmpty)
                      ? NetworkImage(assigned!.photoUrl!)
                      : null,
              child:
                  !filled
                      ? Text(number)
                      : null, // si no hay asignación, muestra el número de posición
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textFieldBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              filled ? assigned!.name.split(' ').first : 'Nombre',
              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
