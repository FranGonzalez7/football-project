import 'package:flutter/material.dart';
import 'package:football_picker/screens/players/player_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String players = '/players';
  

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    home: (context) => HomeScreen(),
    players: (context) => PlayerScreen(),
    
  };
}
