import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:football_picker/models/player_model.dart';
import 'package:football_picker/models/position_type.dart';
import 'package:football_picker/services/player_services.dart';

import 'package:football_picker/screens/new_player/widgets/position_selector.dart';
import 'package:football_picker/screens/new_player/widgets/stat_slider.dart';

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

  // 📋 Form values
  String _name = '';
  String _number = '';
  int _points = 150;
  bool _isAdmin = false;

  final List<PositionType> _selectedPositions = [];

  // 📸 Imagen
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false; // 🚫 Para evitar múltiples llamadas

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  /// 🔐 Comprueba si el usuario es admin
  void _loadUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = userDoc.data()?['role'];

    setState(() {
      _isAdmin = role == 'admin';
    });
  }

  /// 📷 Muestra opciones para elegir fuente de imagen (cámara o galería)
  void _showImageSourceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Usar cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📷 Abrir cámara o galería y guardar imagen temporal (evita múltiples aperturas)
  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return; // Evita múltiples ejecuciones

    _isPickingImage = true;
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al obtener imagen: $e')));
    } finally {
      _isPickingImage = false;
    }
  }

  /// ☁️ Sube la imagen a Firebase Storage y devuelve la URL
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      final fileName =
          'players/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = ref.putFile(imageFile);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Aquí podrías usar logs, analytics, etc.
      return null;
    }
  }

  /// ✅ Añade o quita una posición al jugador
  void _togglePosition(PositionType position) {
    setState(() {
      if (_selectedPositions.contains(position)) {
        _selectedPositions.remove(position);
      } else {
        _selectedPositions.add(position);
      }
    });
  }

  /// 💾 Guarda el jugador en Firestore
  void _savePlayer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPositions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una posición')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? photoUrl;
    if (_imageFile != null) {
      photoUrl = await _uploadImage(_imageFile!);
      if (photoUrl == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error subiendo la foto')));
        setState(() => _isSaving = false);
        return;
      }
    }

    final player = Player(
      id: '',
      name: _name,
      number: int.parse(_number),
      position: _selectedPositions.map((p) => positionLabels[p]).join(', '),
      points: _isAdmin ? _points : 150,
      createdBy: FirebaseAuth.instance.currentUser?.uid ?? '',
      photoUrl: photoUrl ?? '',
    );

    try {
      await widget.playerService.addPlayer(player);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error guardando jugador: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Jugador')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 🏷️ Título
                Text(
                  'Nuevo jugador',
                  style: TextStyle(
                    color: AppColors.primaryButton,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 📸 Imagen de avatar
                GestureDetector(
                  onTap: _isPickingImage
                      ? null
                      : () => _showImageSourceSelector(context),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: AppColors.primaryButton,
                    backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(
                            Icons.camera_alt_outlined,
                            size: 60,
                            color: Colors.black,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 15),

                // ✏️ Campo nombre
                CustomTextFormField(
                  title: 'Nombre',
                  onChanged: (value) => _name = value,
                  validator:
                      (value) => value == null || value.isEmpty ? 'Obligatorio' : null,
                ),

                // #️⃣ Número
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
                CustomDivider(title: 'Posición'),
                const SizedBox(height: 8),

                // 🧭 Selector de posiciones
                PositionSelector(
                  selectedPositions: _selectedPositions,
                  onToggle: _togglePosition,
                ),

                const SizedBox(height: 10),

                // 🎯 Stats (si admin)
                if (_isAdmin) ...[
                  CustomDivider(title: 'Stats iniciales'),
                  const SizedBox(height: 5),
                  StatSlider(
                    initialValue: _points,
                    onChanged: (value) {
                      setState(() => _points = value);
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
                _isSaving
                    ? const CircularProgressIndicator()
                    : CustomPrimaryButton(
                        text: 'Guardar',
                        onPressed: _savePlayer,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
