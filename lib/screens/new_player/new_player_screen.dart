import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

/// ➕ Pantalla para añadir un nuevo jugador al grupo.
/// Permite seleccionar nombre, número, posición y stats (solo admin).
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
  bool _isAdmin = false;

  final List<PositionType> _selectedPositions = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  /// 🔍 Carga el rol del usuario actual para saber si puede editar stats.
  void _loadUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final role = userDoc.data()?['role'];
    setState(() {
      _isAdmin = role == 'admin';
    });
  }

  /// 🔄 Añade o quita posiciones seleccionadas.
  void _togglePosition(PositionType position) {
    setState(() {
      _selectedPositions.contains(position)
          ? _selectedPositions.remove(position)
          : _selectedPositions.add(position);
    });
  }

  /// 💾 Valida formulario y guarda el nuevo jugador.
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
      points: _isAdmin ? _points : 150,
      createdBy: '',
    );

    await widget.playerService.addPlayer(player);
    Navigator.pop(context, true); // Regresa indicando éxito
  }

  // ────────────────────────────────────────────────────────────────
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
                // 🎯 Título principal
                Text(
                  'Nuevo jugador',
                  style: TextStyle(
                    color: AppColors.primaryButton,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // 📸 Avatar placeholder
                CircleAvatar(
                  radius: 80,
                  backgroundColor: AppColors.primaryButton,
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 60,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                // 📝 Campo Nombre
                CustomTextFormField(
                  title: 'Nombre',
                  onChanged: (value) => _name = value,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Obligatorio' : null,
                ),

                // 🔢 Campo Número
                CustomTextFormField(
                  title: 'Número',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _number = value,
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Número inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // ⚽ Selector de posiciones
                CustomDivider(title: 'Posición'),
                const SizedBox(height: 8),
                PositionSelector(
                  selectedPositions: _selectedPositions,
                  onToggle: _togglePosition,
                ),

                const SizedBox(height: 10),

                // 📊 Slider de stats solo para admin
                if (_isAdmin) ...[
                  CustomDivider(title: 'Stats iniciales'),
                  const SizedBox(height: 5),
                  StatSlider(
                    initialValue: _points,
                    onChanged: (value) {
                      setState(() {
                        _points = value;
                      });
                    },
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Los stats iniciales serán 150 por defecto.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],

                const SizedBox(height: 20),

                // 💾 Botón guardar
                CustomPrimaryButton(text: 'Guardar', onPressed: _savePlayer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
