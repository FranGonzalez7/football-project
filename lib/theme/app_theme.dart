import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

/// 🎨 Configuración de temas visuales para la aplicación Football Picker.
class AppTheme {
  // ────────────────────────────────────────────────────────────────
  /// 🌑 Tema oscuro (activo por defecto)
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,

    // 🌌 Fondo principal
    scaffoldBackgroundColor: AppColors.background,

    // 🧭 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // 📦 BottomAppBar
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.textFieldBackground, // Asegúrate de que este nombre esté en AppColors
    ),

    // 🔘 Iconos
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),

    // 🖊️ Estilo de texto
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );

  // ────────────────────────────────────────────────────────────────
  /// ☀️ Tema claro (alternativo)
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,

    // 🟡 Fondo principal
    scaffoldBackgroundColor: Colors.grey[100],

    // 🧭 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
    ),

    // 📦 BottomAppBar
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.grey[200],
    ),

    // 🔘 Iconos
    iconTheme: const IconThemeData(
      color: Colors.black87,
    ),

    // 🖊️ Estilo de texto
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),

    // ✏️ Campos de entrada
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    ),
  );
}
