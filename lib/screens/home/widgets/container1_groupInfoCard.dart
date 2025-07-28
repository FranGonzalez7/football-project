import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class GroupInfoCard extends StatelessWidget {
  final String groupName;
  final String groupCode;

  const GroupInfoCard({
    super.key,
    required this.groupName,
    required this.groupCode,
  });

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Text(
                  'Welcome to $groupName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryButton,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Group Code: $groupCode',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primaryButton,
                  ),
                ),
                  ],
                ),
                
              ],
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
              'Info Grupo',
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
