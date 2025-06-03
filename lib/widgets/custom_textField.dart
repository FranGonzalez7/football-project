import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class CustomTextfield extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final TextEditingController? controller;
  final Color backgroundColor;

  const CustomTextfield({
    super.key,
    this.obscureText = false,
    this.controller,
    required this.labelText,
    this.backgroundColor = AppColors.textField,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.white),
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        //Etiqueta de texto:
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        //Relleno del fondo:
        filled: true,
        fillColor: AppColors.textField,
        //Borde sin foco:
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none, // borde invisible pero con forma
        ),
        //Borde con foco:
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.accentButton),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}
