import 'package:flutter/material.dart';

// 📦 Screens
import 'package:football_picker/screens/auth/login_screen.dart';
import 'package:football_picker/screens/auth/register_screen.dart';
import 'package:football_picker/screens/home/home_screen.dart';
import 'package:football_picker/screens/players/player_screen.dart';

/// 🚏 Contenedor central de rutas usadas en la app.
class AppRoutes {
  // 🟢 Rutas nombradas
  static const String login = '/login';           // 🔐 Login de usuario
  static const String register = '/register';     // 📝 Registro de usuario
  static const String home = '/home';             // 🏠 Pantalla principal
  static const String players = '/players';       // 🧍‍♂️ Lista de jugadores

  /// 🗺️ Mapa de rutas asociadas a sus pantallas correspondientes.
  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    players: (context) => const PlayerScreen(),
  };
}
