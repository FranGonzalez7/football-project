import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';

/// 🧭 Grupo de FABs para la pantalla de nuevo partido:
/// - 🔎 Filtro (FAB redondo pequeño)
/// - ▶️ Comenzar partido (FAB extendido)
///
/// 💡 Notas:
/// - Los `heroTag` deben ser únicos por pantalla para evitar conflictos de Hero.
/// - Tooltips mejoran accesibilidad en móvil y web.
class NewMatchFABs extends StatelessWidget {
  final VoidCallback onStartMatch; // ▶️ comenzar
  final VoidCallback onFilter;     // 🔎 filtrar

  const NewMatchFABs({
    super.key,
    required this.onStartMatch,
    required this.onFilter,
  });

  // ⚙️ Constantes de UI
  static const double _miniSize = 36;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔎 FAB pequeño redondo (filtro)
        Semantics(
          label: 'Abrir filtros',
          button: true,
          child: SizedBox(
            height: _miniSize,
            width: _miniSize,
            child: FloatingActionButton(
              heroTag: 'filterFab',
              backgroundColor: AppColors.primaryButton,
              elevation: 2,
              tooltip: 'Filtrar jugadores',
              onPressed: onFilter,
              child: const Icon(Icons.filter_list, size: 18, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: _gap),

        // ▶️ FAB extendido (comenzar partido)
        Semantics(
          label: 'Comenzar partido',
          button: true,
          child: SizedBox(
            height: _miniSize, // compacto para que no tape el panel
            child: FloatingActionButton.extended(
              heroTag: 'startFab',
              backgroundColor: AppColors.primaryButton,
              elevation: 2,
              tooltip: 'Comenzar partidos',
              icon: const Icon(Icons.play_arrow, size: 18, color: Colors.black),
              label: const Text('Comenzar partido',
                  style: TextStyle(fontSize: 13, color: Colors.black)),
              onPressed: onStartMatch,
            ),
          ),
        ),
      ],
    );
  }
}
