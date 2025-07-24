import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';
import 'package:football_picker/widgets/appbar_menu_button.dart';
import 'package:football_picker/widgets/custom_primary_button.dart';
import 'package:football_picker/widgets/custom_secondary_button.dart';
import 'package:football_picker/widgets/custom_textField.dart';
import 'package:football_picker/services/auth_service.dart';

/// 📝 Pantalla de registro con opción de crear o unirse a un grupo.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _groupNameController = TextEditingController();
  final _groupCodeController = TextEditingController();

  String? _error;
  bool _isLoading = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _groupNameController.dispose();
    _groupCodeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────
  /// 👤 Función que gestiona el registro según el modo activo
  Future<void> _register() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final groupName = _groupNameController.text.trim();
    final groupCode = _groupCodeController.text.trim().toUpperCase();

    String? errorMessage;

    if (_tabController.index == 0) {
      // 👥 Crear grupo
      if (groupName.isEmpty ||
          groupCode.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        setState(() {
          _error = 'Introduce todos los campos.';
          _isLoading = false;
        });
        return;
      }

      errorMessage = await _authService.registerWithNewGroup(
        email: email,
        password: password,
        groupName: groupName,
        groupCode: groupCode,
      );
    } else {
      // 🔗 Unirse a grupo
      if (groupCode.isEmpty || email.isEmpty || password.isEmpty) {
        setState(() {
          _error = 'Introduce todos los campos.';
          _isLoading = false;
        });
        return;
      }

      errorMessage = await _authService.registerWithExistingGroup(
        email: email,
        password: password,
        groupCode: groupCode,
      );
    }

    if (errorMessage != null) {
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    } else {
      _emailController.clear();
      _passwordController.clear();
      _groupNameController.clear();
      _groupCodeController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Screen'),
        actions: const [AppBarMenuButton()],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryButton,
          indicatorWeight: 4,
          labelColor: AppColors.primaryButton,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: const [Tab(text: 'Crear grupo'), Tab(text: 'Unirse a grupo')],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildRegisterForm(isCreatingGroup: true),
              _buildRegisterForm(isCreatingGroup: false),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  /// 📋 Formulario reutilizable para crear o unirse a un grupo.
  Widget _buildRegisterForm({required bool isCreatingGroup}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            const Text('⚽', style: TextStyle(fontSize: 58)),
            const SizedBox(height: 76),

            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 22),

            CustomTextfield(labelText: 'Email', controller: _emailController),
            const SizedBox(height: 22),

            CustomTextfield(
              labelText: 'Contraseña',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 22),

            if (isCreatingGroup) ...[
              CustomTextfield(
                controller: _groupNameController,
                labelText: 'Nombre del grupo',
              ),
              const SizedBox(height: 22),
            ],

            CustomTextfield(
              controller: _groupCodeController,
              labelText: 'Código del grupo',
            ),
            const SizedBox(height: 32),

            CustomPrimaryButton(text: 'Registrarse', onPressed: _register),
            const SizedBox(height: 22),

            CustomSecondaryButton(
              text: 'Volver a inicio de sesión',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
