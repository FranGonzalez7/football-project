import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/screens/new_match/widgets/player_bubble_down.dart';
import 'package:football_picker/screens/new_match/widgets/player_bubble_up.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_list.dart';
import 'package:football_picker/services/match_services.dart';
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

  @override
  void initState() {
    super.initState();

    _playersFuture = _playerService.getPlayers();

    // 🔁 Cargamos el partido para leer su fecha programada
    MatchService()
        .getMatchById(groupId: widget.groupId, matchId: widget.matchId)
        .then((match) {
          if (match != null && mounted) {
            setState(() {
              _selectedDate = match.scheduledDate;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    Color upperTeam = Colors.red;
    Color lowerTeam = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('5 vs 5'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime now = DateTime.now();

              // Primero selecciona la fecha
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? now,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                // Luego selecciona la hora
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _selectedDate != null
                  ? '📅 ${DateFormat('dd/MM/yyyy – HH:mm').format(_selectedDate!)}'
                  : '📅 Fecha no seleccionada',

              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/field_white_vertical.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: 196,
                        top: 16,
                        child: PlayerBubbleUp(color: upperTeam, number: '1'),
                      ),
                      Positioned(
                        left: 196,
                        top: 116,
                        child: PlayerBubbleUp(color: upperTeam, number: '2'),
                      ),
                      Positioned(
                        left: 196,
                        top: 246,
                        child: PlayerBubbleUp(color: upperTeam, number: '3'),
                      ),
                      Positioned(
                        left: 56,
                        top: 181,
                        child: PlayerBubbleUp(color: upperTeam, number: '4'),
                      ),
                      Positioned(
                        right: 56,
                        top: 181,
                        child: PlayerBubbleUp(color: upperTeam, number: '5'),
                      ),
                      Positioned(
                        left: 196,
                        bottom: 16,
                        child: PlayerBubbleDown(color: lowerTeam, number: '10'),
                      ),
                      Positioned(
                        left: 196,
                        bottom: 116,
                        child: PlayerBubbleDown(color: lowerTeam, number: '9'),
                      ),
                      Positioned(
                        left: 196,
                        bottom: 246,
                        child: PlayerBubbleDown(color: lowerTeam, number: '8'),
                      ),
                      Positioned(
                        left: 56,
                        bottom: 181,
                        child: PlayerBubbleDown(color: lowerTeam, number: '7'),
                      ),
                      Positioned(
                        right: 56,
                        bottom: 181,
                        child: PlayerBubbleDown(color: lowerTeam, number: '6'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Seleccionar jugadores',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Player>>(
                    future: _playersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text('Error cargando jugadores');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No hay jugadores disponibles');
                      } else {
                        final players = snapshot.data!;
                        return PlayerSelectorList(
                          players: players,
                          playerColors: {
                            for (var p in players) p.id: lowerTeam,
                          },
                        );
                      }
                    },
                  ),
                  const Spacer(),
                  CustomPrimaryButton(
                    text: 'Comenzar Partido',
                    onPressed: () async {
                      await MatchService().markMatchAsStarted(
                        widget.groupId,
                        widget.matchId,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Partido comenzado!')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
