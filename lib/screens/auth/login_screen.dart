import 'package:flutter/material.dart';
import 'package:football_picker/services/auth_service.dart';
import 'package:football_picker/widgets/appbar_menu_button.dart';
import 'package:football_picker/widgets/custom_primary_button.dart';
import 'package:football_picker/widgets/custom_secondary_button.dart';
import 'package:football_picker/widgets/custom_textField.dart';

/// 🔐 Pantalla de inicio de sesión de usuario.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _error;
  bool _isLoading = false;

  // ────────────────────────────────────────────────────────────────
  /// 📥 Función que gestiona el inicio de sesión
  Future<void> _login() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Por favor, introduce el email y la contraseña.';
        _isLoading = false;
      });
      return;
    }

    final result = await _authService.login(email: email, password: password);

    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inicio de sesión exitoso')));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _error = result;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
        actions: const [AppBarMenuButton()],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Text('⚽', style: TextStyle(fontSize: 58)),
                    const SizedBox(height: 102),

                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 22),

                    CustomTextfield(
                      labelText: 'Email',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 22),

                    CustomTextfield(
                      labelText: 'Contraseña',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),

                    CustomPrimaryButton(
                      text: 'Iniciar Sesión',
                      onPressed: _login,
                    ),
                    const SizedBox(height: 22),

                    CustomSecondaryButton(
                      text: 'Registrarse',
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🌀 Overlay de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
