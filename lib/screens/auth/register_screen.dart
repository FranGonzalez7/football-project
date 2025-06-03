import 'package:flutter/material.dart';
import 'package:football_picker/theme/app_colors.dart';
import 'package:football_picker/widgets/appbar_menu_button.dart';
import 'package:football_picker/widgets/custom_primary_button.dart';
import 'package:football_picker/widgets/custom_secondary_button.dart';
import 'package:football_picker/widgets/custom_textField.dart';
import 'package:football_picker/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Campos nuevos
  final _groupNameController = TextEditingController();
  final _groupCodeController = TextEditingController();

  String? _error;

  // Control para pestañas Crear / Unirse
  late TabController _tabController;

  final AuthService _authService = AuthService();

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

  Future<void> _register() async {
    setState(() => _error = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final groupName = _groupNameController.text.trim();
    final groupCode = _groupCodeController.text.trim().toUpperCase();

    String? errorMessage;

    //✅ Tab de crear grupo:
    if (_tabController.index == 0) {
      // Crear grupo
      if (groupName.isEmpty || groupCode.isEmpty || email.isEmpty || password.isEmpty) {
        setState(() => _error = 'Introduce campos restantes');
        return;
      }

      errorMessage = await _authService.registerWithNewGroup(
        email: email,
        password: password,
        groupName: groupName,
        groupCode: groupCode,
      );
    } else {
      // Unirse a grupo existente
      if (groupCode.isEmpty || email.isEmpty || password.isEmpty) {
        setState(() => _error = 'Introduce campos restantes');
        return;
      }

      errorMessage = await _authService.registerWithExistingGroup(
        email: email,
        password: password,
        groupCode: groupCode,
      );
    }

    if (errorMessage != null) {
      setState(() => _error = errorMessage);
    } else {
      // Limpiar campos
      _emailController.clear();
      _passwordController.clear();
      _groupNameController.clear();
      _groupCodeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Usuario registrado con éxito',
            style: TextStyle(color: AppColors.accentButton),
          ),
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Screen'),
        actions: [
          AppBarMenuButton(),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentButton,
          indicatorWeight: 4,
          labelColor: AppColors.accentButton,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: [Tab(text: 'Crear grupo'), Tab(text: 'Unirse a grupo')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Crear grupo
          _buildRegisterForm(isCreatingGroup: true),
          // Unirse a grupo
          _buildRegisterForm(isCreatingGroup: false),
        ],
      ),
    );
  }

  Widget _buildRegisterForm({required bool isCreatingGroup}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 12),
            ],
            Text('⚽', style: TextStyle(fontSize: 58)),

            SizedBox(height: 76),

            CustomTextfield(labelText: 'Email', controller: _emailController),

            SizedBox(height: 22),

            CustomTextfield(
              labelText: 'Contraseña',
              controller: _passwordController,
              obscureText: true,
            ),

            SizedBox(height: 22),

            if (isCreatingGroup) ...[
              CustomTextfield(
                controller: _groupNameController,
                labelText: 'Nombre del grupo',
              ),
              SizedBox(height: 22),
              CustomTextfield(
                controller: _groupCodeController,
                labelText: 'Contraseña del grupo',
              ),
            ] else ...[
              CustomTextfield(
                controller: _groupCodeController,
                labelText: 'Código del grupo',
              ),
            ],

            SizedBox(height: 32),

            CustomPrimaryButton(text: 'Registrarse', onPressed: _register),

            SizedBox(height: 22),

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
