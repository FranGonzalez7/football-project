import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';
// Aseúrate de tener esta clase con tus colores

class AppTheme {

  
  static ThemeData get regularTheme => ThemeData(
    //Color de fondo de la App:
    scaffoldBackgroundColor: AppColors.background,

    //Diseño de la AppBar:
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    //Diseño para la BottomAppBar:
    bottomAppBarTheme: BottomAppBarTheme(
      color: AppColors.textField,     
      
    ),

    //Diseño para los iconos:
    iconTheme: const IconThemeData(
      color: Colors.white, 
    ),
  );
}
