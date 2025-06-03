import 'package:flutter/material.dart';
import 'package:football_picker/screens/players/player_model.dart';
import 'package:football_picker/screens/players/player_services.dart';

class AddPlayerModal extends StatefulWidget {
  final PlayerService playerService;
  final VoidCallback onPlayerAdded;

  const AddPlayerModal({
    Key? key,
    required this.playerService,
    required this.onPlayerAdded,
  }) : super(key: key);

  @override
  State<AddPlayerModal> createState() => _AddPlayerModalState();
}

class _AddPlayerModalState extends State<AddPlayerModal> {
  String name = '';
  String position = '';
  int number = 0;

  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newPlayer = Player(
      id: '',
      name: name,
      position: position,
      number: number,
      points: 100,
      createdBy: '',
    );

    try {
      await widget.playerService.addPlayer(newPlayer);
      Navigator.pop(context);
      widget.onPlayerAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error añadiendo jugador: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aquí envolvemos en SingleChildScrollView para evitar overflow con el teclado
    return Expanded(
      child: SingleChildScrollView(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // bordes redondeados
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Añadir Jugador',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (value) => name = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Posición'),
                    onChanged: (value) => position = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Número'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => number = int.tryParse(value) ?? 0,
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) return 'Número inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Añadir jugador'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Volver'),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
