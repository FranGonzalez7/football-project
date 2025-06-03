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

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Inicio de sesión exitoso')));

      // Ruta para home_screen:
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
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
