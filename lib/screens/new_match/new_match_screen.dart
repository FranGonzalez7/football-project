import 'package:flutter/material.dart';
import 'package:football_picker/screens/new_match/widgets/player_bubble_down.dart';
import 'package:football_picker/screens/new_match/widgets/player_bubble_up.dart';
import 'package:football_picker/theme/app_colors.dart';

class NewMatchScreen extends StatelessWidget {
  const NewMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        left: 196, // distancia desde la izquierda
                        top: 16, // distancia desde arriba
                        child: PlayerBubbleUp(color: Colors.red, number: '1'),
                      ),
                      Positioned(
                        left: 196, // distancia desde la izquierda
                        top: 116, // distancia desde arriba
                        child: PlayerBubbleUp(color: Colors.red, number: '2'),
                      ),

                      // Jugador 2
                      Positioned(
                        left: 196,
                        bottom: 16,
                        child: PlayerBubbleDown(color: Colors.blue, number: '10',),
                      ),
                      Positioned(
                        left: 196,
                        bottom: 116,
                        child: PlayerBubbleDown(color: Colors.blue, number: '9',),
                      ),

                      // Puedes seguir añadiendo más jugadores...
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 200,
            )
          ],
          
        ),
      ),
    );
  }
}


