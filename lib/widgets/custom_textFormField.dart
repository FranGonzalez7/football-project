import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String title;
  final bool obscureText;
  final TextEditingController? controller;
  final Color backgroundColor;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  

  const CustomTextFormField({
    super.key,
    required this.title,
    this.obscureText = false,
    this.controller,
    this.backgroundColor = AppColors.textField,
    this.validator,
    this.onChanged, 
    TextInputType? keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Título centrado con líneas a los lados
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Expanded(
                child: Divider(color: AppColors.accentButton, thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: AppColors.accentButton, thickness: 1),
              ),
            ],
          ),
        ),
        // Campo de texto
        TextFormField(
          style: const TextStyle(color: Colors.white),
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.accentButton),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
