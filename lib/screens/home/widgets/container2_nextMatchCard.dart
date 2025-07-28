import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class NextMatchCard extends StatelessWidget {
  const NextMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.primaryButton),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.sports_soccer),
              label: const Text('5 vs 5'),
              onPressed: () {
                Navigator.pushNamed(context, '/newMatch5');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -12,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: AppColors.background,
            child: const Text(
              'Siguiente Partido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryButton,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
