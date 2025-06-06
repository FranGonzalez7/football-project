import 'package:flutter/material.dart';
import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/models/position_type.dart';
import 'package:football_picker/screens/new_player/widgets/position_selector.dart';
import 'package:football_picker/screens/new_player/widgets/stat_slider.dart';
import 'package:football_picker/services/player_services.dart';
import 'package:football_picker/theme/app_colors.dart';
import 'package:football_picker/widgets/custom_divider.dart';
import 'package:football_picker/widgets/custom_primary_button.dart';
import 'package:football_picker/widgets/custom_textFormField.dart';

class NewPlayerScreen extends StatefulWidget {
  final PlayerService playerService;

  const NewPlayerScreen({Key? key, required this.playerService})
    : super(key: key);

  @override
  State<NewPlayerScreen> createState() => _NewPlayerScreenState();
}

class _NewPlayerScreenState extends State<NewPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  int _points = 150;
  String _number = '';

  final List<PositionType> _selectedPositions = [];

  void _togglePosition(PositionType position) {
    setState(() {
      _selectedPositions.contains(position)
          ? _selectedPositions.remove(position)
          : _selectedPositions.add(position);
    });
  }

  void _savePlayer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPositions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una posición')),
      );
      return;
    }

    final player = Player(
      id: '',
      name: _name,
      position: _selectedPositions.map((p) => positionLabels[p]).join(', '),
      number: int.parse(_number),
      points: _points,
      createdBy: '',
    );

    await widget.playerService.addPlayer(player);
    Navigator.pop(context, true); // Volvemos con éxito
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Player Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                // ✅ Título:
                Text(
                  'Nuevo jugador',
                  style: TextStyle(
                    color: AppColors.accentButton,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20,),

                // ✅ Círculo para avatar/foto:
                CircleAvatar(
                  radius: 80,
                  backgroundColor: AppColors.accentButton,
                  child: Icon(Icons.camera_alt_outlined, size: 60, color: Colors.black,)
                ),

                SizedBox(height: 15),

                // ✅ Cuadro para el nombre:
                CustomTextFormField(
                  title: 'Nombre',
                  onChanged: (value) => _name = value,
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Obligatorio' : null,
                ),

                // ✅ Cuadro para el número:
                CustomTextFormField(
                  title: 'Número',
                  keyboardType: TextInputType.number, //❓esto no funciona
                  onChanged: (value) => _number = value,
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Número inválido';
                    return null;
                  },
                ),

                SizedBox(height: 10),

                // ✅ Sección para las posiciones:
                CustomDivider(title: 'Posición'),
                const SizedBox(height: 8),
                PositionSelector(
                  selectedPositions: _selectedPositions,
                  onToggle: _togglePosition,
                ),

                SizedBox(height: 10),

                // ✅ Sección para los stats:
                CustomDivider(title: 'Stats iniciales'),
                SizedBox(height: 5),

                StatSlider(
                  initialValue: _points,
                  onChanged: (value) {
                    setState(() {
                      _points = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                //Spacer(),
                //TODO: Poner este botón al final de la pantalla:
                CustomPrimaryButton(text: 'Guardar', onPressed: _savePlayer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
