import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class CustomDivider extends StatelessWidget {
  final String title;

  const CustomDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
    // Campo de texto
  }
}
