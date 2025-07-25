import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  

  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.primaryButton,
            width: 3.0,
          )
        )
      ),
      child: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
      
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.people,
                size: 32), 
              label: 'Players',
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer_outlined, size: 32),
              label: 'Matches',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 32), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events, size: 32),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 32),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
