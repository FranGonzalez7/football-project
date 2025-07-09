import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomPrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ocupa todo el ancho disponible
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 16),),
        onPressed: onPressed, 
        child: Text(text, 
          style:TextStyle(
            color: Colors.black, 
            fontSize: 20, 
            fontWeight: FontWeight.bold),)),
    );
  }
}
