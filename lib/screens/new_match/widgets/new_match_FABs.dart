import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class NewMatchFABs extends StatelessWidget {
  final VoidCallback onStartMatch;
  final VoidCallback onFilter;

  const NewMatchFABs({
    super.key,
    required this.onStartMatch,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FAB pequeño redondo (filtro)
        SizedBox(
          height: 36,
          width: 36,
          child: FloatingActionButton(
            heroTag: 'filterFab',
            backgroundColor: AppColors.primaryButton,
            elevation: 2,
            onPressed: onFilter,
            child: const Icon(Icons.filter_list, size: 18, color: Colors.black),
          ),
        ),
        const SizedBox(width: 8),
        // FAB estrecho y más bajo (comenzar partido)
        SizedBox(
          height: 36,
          child: FloatingActionButton.extended(
            heroTag: 'startFab',
            backgroundColor: AppColors.primaryButton,
            elevation: 2,
            icon: const Icon(Icons.play_arrow, size: 18, color: Colors.black),
            label: const Text(
              'Comenzar partido',
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),
            onPressed: onStartMatch,
          ),
        ),
      ],
    );
  }
}
