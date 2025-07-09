import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

class StatSlider extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const StatSlider({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<StatSlider> createState() => _StatSliderState();
}

class _StatSliderState extends State<StatSlider> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  String _getDescription(int value) {
    if (value <= 50) return 'Muy malo';
    if (value <= 120) return 'Malo';
    if (value <= 180) return 'Neutral';
    if (value <= 240) return 'Bueno';
    return 'Muy bueno';
  }

  Color _getColor(int value) {
    if (value <= 50) return Colors.red.shade800;
    if (value <= 120) return Colors.orange;
    if (value <= 180) return Colors.yellow.shade600;
    if (value <= 240) return Colors.lightGreen;
    return Colors.greenAccent.shade400;
  }

  @override
  Widget build(BuildContext context) {

    final description = _getDescription(_currentValue);
    final descriptionColor = _getColor(_currentValue);

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryButton,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: Colors.green,
            valueIndicatorColor: AppColors.primaryButton,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            activeTickMarkColor: Colors.white,
            inactiveTickMarkColor: Colors.black,
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: Slider(
            value: _currentValue.toDouble(),
            min: 0,
            max: 300,
            divisions: 10,
            label: _currentValue.toString(),
            onChanged: (double newValue) {
              setState(() {
                _currentValue = newValue.round();
              });
              widget.onChanged(_currentValue);
            },
          ),
        ),
        Text(
          '$_currentValue pts',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(fontSize: 18, color: descriptionColor),
        ),
      ],
    );
  }
}
