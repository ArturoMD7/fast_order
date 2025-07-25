import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;
  bool _isLoading = false;
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _firstNameController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _passwordController = TextEditingController();
  late final TextEditingController _restaurantNameController = TextEditingController();
  late final TextEditingController _restaurantDescController = TextEditingController();

  static const String cliente = 'cliente';
  static const String administrador = 'administrador';

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user == null && response.session == null) {
        throw Exception(response.toString());
      }
      int? restauranteId;
      if (_selectedRole == administrador) {
        final restaurantData = {
          'nombre': _restaurantNameController.text.trim(),
          'descripcion': _restaurantDescController.text.trim(),
        };
        final response = await supabase.from('Restaurantes').insert(restaurantData).select().single();
        restauranteId = response['id'];
      }
      final userData = {
        'nombre': _nameController.text.trim(),
        'apellido': _firstNameController.text.trim(),
        'email': _emailController.text.trim(),
        'contrasena': _passwordController.text,
        'num_telefono': _phoneController.text.trim(),
        'rol': _selectedRole,
        if (restauranteId != null) 'id_restaurante': restauranteId,
      };
      await supabase.from('Usuarios').insert(userData);
      if (mounted) {
        switch (_selectedRole) {
          case cliente:
            Navigator.pushReplacementNamed(context, '/client/restaurants');
            break;
          case administrador:
            Navigator.pushReplacementNamed(context, '/login');
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _restaurantNameController.dispose();
    _restaurantDescController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    final trimmed = email.trim();
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed);
  }


  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFD2691E);
    final accentColor = const Color(0xFF238800);
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Registro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _selectedRole == null 
              ? _buildRoleSelection(primaryColor, accentColor)
              : _buildForm(primaryColor, accentColor),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection(Color primaryColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Selecciona el tipo de cuenta:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: accentColor, minimumSize: const Size(double.infinity, 50)),
          onPressed: () => setState(() => _selectedRole = cliente),
          child: const Text('Cliente', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)),
          onPressed: () => setState(() => _selectedRole = administrador),
          child: const Text('Dueño de Restaurante', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildForm(Color primaryColor, Color accentColor) {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          if (_selectedRole == administrador) ...[
            Text('Datos del Restaurante', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor)),
            const SizedBox(height: 10),
            _buildInputField('Nombre del Restaurante', _restaurantNameController, true),
            _buildInputField('Descripción del Restaurante', _restaurantDescController, false, maxLines: 3),
            const SizedBox(height: 20),
          ],
          Text('Datos Personales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor)),
          const SizedBox(height: 10),
          _buildInputField('Nombre', _nameController, true),
          _buildInputField('Apellido(s)', _firstNameController, true),
          _buildInputField('Email', _emailController, true, isEmail: true),
          _buildInputField('Número de teléfono (Opcional)', _phoneController, false, keyboardType: TextInputType.phone),
          _buildInputField('Contraseña', _passwordController, true, isPassword: true),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)),
            onPressed: _isLoading ? null : _registerUser,
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Registrarse', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedRole = null),
            child: const Text('Cambiar tipo de cuenta', style: TextStyle(color: Colors.green),),
          )
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isRequired, {bool isEmail = false, bool isPassword = false, TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Requerido';
          }
          if (isEmail && !_isEmailValid(value!.trim())) {
            return 'Email inválido';
          }
          if (isPassword && value!.length < 6) {
            return 'Mínimo 6 caracteres';
          }
          return null;
        },
      ),
    );
  }
} 
