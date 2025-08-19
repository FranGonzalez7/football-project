import 'package:flutter/material.dart';

/// 🏷️ Diálogo para editar el **lugar del partido**.
/// - 📝 Muestra el valor actual y permite cambiarlo.
/// - 🔤 Autofocus + capitalización por palabras.
/// - ✂️ Devuelve el texto **trimmed** (`String?`) o `null` si se cancela.
Future<String?> showEditLocationDialog(
  BuildContext context, {
  required String initialValue,
}) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      // 📍 Título con icono
      title: Row(
        children: const [
          Icon(Icons.place_outlined, size: 20),
          SizedBox(width: 8),
          Text('Lugar del partido'),
        ],
      ),

      // ✏️ Campo de texto
      content: TextField(
        controller: controller,
        autofocus: true, // 👀 foco directo al abrir
        textCapitalization: TextCapitalization.words, // 🔤 nombres propios
        keyboardType: TextInputType.streetAddress,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'Ej. Parque de la Cartuja',
          prefixIcon: const Icon(Icons.edit_location_alt_outlined),
          suffixIcon: IconButton(
            tooltip: 'Limpiar',
            icon: const Icon(Icons.clear),
            onPressed: controller.clear, // 🧼 borrar rápido
          ),
        ),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),

      // 🧭 Acciones
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
