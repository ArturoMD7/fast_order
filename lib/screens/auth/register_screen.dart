import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'cliente'; 
  bool _isLoading = false;
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _firstNameController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _passwordController = TextEditingController();
  late final TextEditingController _restaurantNameController = TextEditingController();
  late final TextEditingController _restaurantDescController = TextEditingController();


  static const String cliente = 'cliente';
  static const String trabajador = 'trabajador';
  static const String administrador = 'administrador';

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      
      final authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (authResponse.user == null) {
        throw Exception('Error al registrar usuario');
      }

      final userData = {
        'id': authResponse.user!.id,
        'nombre': _nameController.text.trim(),
        'apellido': _firstNameController.text.trim(),
        'email': _emailController.text.trim(),
        'num_telefono': _phoneController.text.trim(),
        'rol': _selectedRole,
      };


      if (_selectedRole == administrador) {
        userData['nombre_restaurante'] = _restaurantNameController.text.trim();
        userData['descripcion_restaurante'] = _restaurantDescController.text.trim();
      }

      await supabase.from('Usuarios').insert(userData);


      if (mounted) {
        switch (_selectedRole) {
          case cliente:
            Navigator.pushReplacementNamed(context, '/client/restaurants');
            break;
          case trabajador:
          case administrador:
            Navigator.pushReplacementNamed(context, '/login');
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar: ${e.toString()}')),
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
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
                controller: _nameController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Apellido(s)'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
                controller: _firstNameController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => 
                  value!.isEmpty ? 'Requerido' : 
                  !_isEmailValid(value) ? 'Email inválido' : null,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Número de teléfono (Opcional)'),
                keyboardType: TextInputType.phone,
                controller: _phoneController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                controller: _passwordController,
              ),
              if (_selectedRole == administrador) ...[
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre del Restaurante'),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  controller: _restaurantNameController,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Descripción del Restaurante'),
                  maxLines: 3,
                  controller: _restaurantDescController,
                ),
              ],
              const SizedBox(height: 20),
              const Text('Tipo de cuenta:'),
              RadioListTile(
                title: const Text('Cliente'),
                value: cliente,
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              RadioListTile(
                title: const Text('Trabajador de Restaurante'),
                value: trabajador,
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              RadioListTile(
                title: const Text('Dueño de Restaurante'),
                value: administrador,
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Registrarse'),
              ),
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}