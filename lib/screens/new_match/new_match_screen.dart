import 'package:flutter/material.dart';
import 'package:football_picker/screens/new_match/widgets/player_bubble_down.dart';
import 'package:football_picker/screens/new_match/widgets/player_bubble_up.dart';
import 'package:football_picker/screens/new_match/widgets/player_selector_list.dart';
import 'package:football_picker/theme/app_colors.dart';
import 'package:football_picker/widgets/custom_primary_button.dart';

class NewMatchScreen extends StatelessWidget {
  const NewMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Color upperTeam = Colors.red;
    Color lowerTeam = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Partido'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      // Imagen del campo
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/field.png',
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Jugador 1 (posición fija relativa al campo)
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

                      // Jugador 2
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

            SizedBox(height: 5,),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Seleccionar jugadores',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  PlayerSelectorList(),
                  const Spacer(),
                  CustomPrimaryButton(text: 'Comenzar Partido', onPressed: () {
                    
                  },)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
