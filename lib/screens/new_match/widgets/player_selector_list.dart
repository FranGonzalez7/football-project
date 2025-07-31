import 'package:flutter/material.dart';
import 'player_selector_bubble.dart'; // Asegúrate de tener este widget o eliminarlo si no lo usas

class PlayerSelectorList extends StatelessWidget {
  const PlayerSelectorList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          PlayerSelectorBubble(number: '1', color: Colors.red),
          PlayerSelectorBubble(number: '2', color: Colors.yellow),
          PlayerSelectorBubble(number: '3', color: Colors.purple),
          PlayerSelectorBubble(number: '4', color: Colors.blue),
          PlayerSelectorBubble(number: '5', color: Colors.orange),
          PlayerSelectorBubble(number: '6', color: Colors.green),
          PlayerSelectorBubble(number: '7', color: Colors.lightBlueAccent),
          PlayerSelectorBubble(number: '8', color: Colors.black),
          PlayerSelectorBubble(number: '9', color: Colors.grey),
        ],
      ),
    );
  }
}
