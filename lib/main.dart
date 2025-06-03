import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:football_picker/app/routes.dart';
import 'package:football_picker/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Picker App',
      theme: AppTheme.regularTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes
    );
  }
}
