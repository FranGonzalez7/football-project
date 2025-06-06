import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class StatSlider extends StatelessWidget {

  final int initialValue ;
  final ValueChanged<int> onChanged;

  const StatSlider({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accentButton,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: Colors.green,
            valueIndicatorColor: AppColors.accentButton, // Fondo de la etiqueta
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,              
            ),
            activeTickMarkColor: Colors.white,
            inactiveTickMarkColor: Colors.black,
            showValueIndicator: ShowValueIndicator.always, 
          
          ),            
          child: Slider(
            value: initialValue.toDouble(),
            min: 0,
            max: 300,
            divisions: 10,
            label: initialValue.toString(),
            onChanged: (double newValue) {
              onChanged(newValue.round());
            },
          ),
        ),
        Text(
          '$initialValue pts',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ],
    );
  }
}
