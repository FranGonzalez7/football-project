import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class CustomSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomSecondaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ocupa todo el ancho disponible
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textFieldBackground,
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 16),),
        onPressed: onPressed, 
        child: Text(text,
          style:TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.bold)
        )));
  }
}
