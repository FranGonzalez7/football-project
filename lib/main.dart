import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:football_picker/app/routes.dart';
import 'package:football_picker/theme/app_theme.dart';
import 'firebase_options.dart';

/// 🏁 Punto de entrada principal de la aplicación.
void main() async {
  // 🔧 Asegura que los widgets estén correctamente inicializados antes de usar plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Inicializa Firebase con las opciones específicas de la plataforma.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🎬 Lanza la aplicación.
  runApp(const MyApp());
}

/// 🧱 Widget raíz de la app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Football Picker App',

      // 🎨 Tema visual de la aplicación
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // 📍 Ruta inicial
      initialRoute: AppRoutes.login,

      // 🗺️ Mapa de rutas
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
