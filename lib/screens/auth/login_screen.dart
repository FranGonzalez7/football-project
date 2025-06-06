import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:football_picker/widgets/appbar_menu_button.dart';
import 'package:football_picker/widgets/custom_primary_button.dart';
import 'package:football_picker/widgets/custom_secondary_button.dart';
import 'package:football_picker/widgets/custom_textField.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _error;

  // Función para iniciar sesión:
  Future<void> _login() async {
  setState(() {
    _error = null;
  });

  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    setState(() {
      _error = 'Por favor, introduce el email y la contraseña.';
    });
    return;
  }

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inicio de sesión exitoso')),
    );

    Navigator.pushReplacementNamed(context, '/home');
  } on FirebaseAuthException catch (e) {
    setState(() {
      //TODO: Este manejo de errores no funciona del todo bien:
      switch (e.code) {
        case 'user-not-found':
          _error = 'No se encontró una cuenta con ese email.';
          break;
        case 'wrong-password':
          _error = 'La contraseña es incorrecta.';
          break;
        case 'invalid-email':
          _error = 'El formato del email no es válido.';
          break;
        default:
          _error = 'Error al iniciar sesión. Inténtalo de nuevo.';
      }
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Screen'),
        actions: [
          AppBarMenuButton(),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_error != null) ...[
                  Text(_error!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 8),
                ],

                

                Text('Welcome to the Game', style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold) ),
                Text('⚽', style: TextStyle(fontSize: 58),),

                SizedBox(height: 102),
        
                CustomTextfield(labelText: 'Email', controller: _emailController),
        
                SizedBox(height: 22),
        
                CustomTextfield(
                  labelText: 'Contraseña',
                  controller: _passwordController,
                  obscureText: true,
                ),
        
                SizedBox(height: 32),
        
                CustomPrimaryButton(text: 'Iniciar Sesión', onPressed: _login),
        
                SizedBox(height: 22),
        
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
    );
  }
}
