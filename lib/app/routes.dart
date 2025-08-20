import 'package:flutter/material.dart';

// 📦 Screens
import 'package:football_picker/screens/auth/login_screen.dart';
import 'package:football_picker/screens/auth/register_screen.dart';
import 'package:football_picker/screens/home/home_screen.dart';
import 'package:football_picker/screens/new_match/new_match_screen.dart';
import 'package:football_picker/screens/players/player_screen.dart';
import 'package:football_picker/screens/score/score_screen.dart';

/// 🚏 Contenedor central de rutas usadas en la app.
class AppRoutes {
  // 🟢 Rutas nombradas
  static const String login = '/login';            // 🔐 Login de usuario
  static const String register = '/register';      // 📝 Registro de usuario
  static const String home = '/home';              // 🏠 Pantalla principal
  static const String players = '/players';        // 🧍‍♂️ Lista de jugadores
  static const String newMatch5 = '/newMatch5';    // 🧍‍♂️ Nuevo partido
  static const String score = '/score';            // 📊 Marcador (ScoreScreen)

  /// 🗺️ Mapa de rutas asociadas a sus pantallas correspondientes.
  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    players: (context) => const PlayerScreen(),
    // Nota: ScoreScreen necesita argumentos → la resolvemos en onGenerateRoute
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == newMatch5) {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => NewMatchScreen(
          groupId: args['groupId'],
          matchId: args['matchId'],
        ),
      );
    }

    // ⬇️ NUEVO: resolver ScoreScreen con argumentos
    if (settings.name == score) {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => ScoreScreen(
          groupId: args['groupId'] as String, 
          matchId: args['matchId'] as String,
          teamAName: (args['teamAName'] as String?) ?? 'Equipo A',
          teamBName: (args['teamBName'] as String?) ?? 'Equipo B',
          // opcionales si los pasas:
          teamAColor: args['teamAColor'] ?? Colors.red,
          teamBColor: args['teamBColor'] ?? Colors.blue,
        ),
      );
    }

    return null; // Ruta desconocida
  }
}
