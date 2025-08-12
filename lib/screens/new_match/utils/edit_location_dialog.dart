import 'package:flutter/material.dart';

Future<String?> showEditLocationDialog(
  BuildContext context, {
  required String initialValue,
}) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Lugar del partido'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Ej. Parque Cartuja',
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
