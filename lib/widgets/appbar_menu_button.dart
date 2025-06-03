import 'package:flutter/material.dart';

class AppBarMenuButton extends StatelessWidget {
  const AppBarMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.menu),
      onSelected: (value) {
        Navigator.pushNamed(context, value);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: '/home',
          child: Text('Ir a Home'),
        ),
        PopupMenuItem(
          value: '/login',
          child: Text('Ir a Login'),
        ),
        PopupMenuItem(
          value: '/register',
          child: Text('Ir a Registro'),
        ),
        PopupMenuItem(
          value: '/players',
          child: Text('Ir a Jugadores'),
        ),
        // Añade más rutas según necesites
      ],
    );
  }
}
