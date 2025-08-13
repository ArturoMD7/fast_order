import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final StreamSubscription<AuthState> _authStateSubscription;
  bool _isLoading = false;
  bool _redirecting = false;
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        if (_redirecting) return;
        final session = data.session;
        if (session != null) {
          _redirecting = true;
          _redirectBasedOnRole(session.user.id);
        }
      },
      onError: (error) {
        _showErrorSnackBar(error.toString());
      },
    );
    
    super.initState();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión exitoso')),
        );

        final userId = response.user?.id;
        if (userId == null) throw Exception('Usuario inválido');

        // Verificar y crear usuario en tabla personalizada si no existe
        await _ensureUserExistsInProfileTable(userId);
        await _redirectBasedOnRole(userId);
      }
    } on AuthException catch (e) {
      _showErrorSnackBar(e.message);
    } catch (e) {
      _showErrorSnackBar('Error al iniciar sesión: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ensureUserExistsInProfileTable(String userId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Verificar si existe en la tabla Usuarios
      final existingUser = await supabase
        .from('Usuarios')
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    } catch (e) {
      throw Exception('Error al verificar perfil de usuario: ${e.toString()}');
    }
  }

  Future<void> _redirectBasedOnRole(String userId) async {
    try {
      final userData = await supabase
        .from('Usuarios')
        .select('rol, id_restaurante')
        .eq('id', userId)
        .single();

      final rol = userData['rol'] as String;

      switch (rol) {
        case 'administrador':
          Navigator.pushReplacementNamed(context, '/admin/home');
          break;
        case 'cliente':
          Navigator.pushReplacementNamed(context, '/client/restaurants');
          break;
        case 'trabajador':
          Navigator.pushReplacementNamed(context, '/worker/home');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/complete-profile');
      }
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') { // Código para "no encontrado"
        await supabase.auth.signOut();
        _showErrorSnackBar('Por favor completa tu registro');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/complete-profile');
        }
      } else {
        throw Exception('Error al obtener datos del usuario: ${e.message}');
      }
    } catch (e) {
      await supabase.auth.signOut();
      _showErrorSnackBar('Error al redirigir: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFD2691E);
    final secondaryColor = const Color(0xFFF4A460);
    final backgroundColor = const Color(0xFFFFF8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            shadowColor: primaryColor.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Image(
                      image: AssetImage('assets/imgs/logo_fast.png'),
                      height: 100,
                    ),
                    Text(
                      'Bienvenido a Fast Order',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      'Ordena y asegura tu pedido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,  
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.email, color: primaryColor),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Ingresa tu correo' : null,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: primaryColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.lock, color: primaryColor),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Ingresa tu contraseña' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        '¿No tienes cuenta? Regístrate',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}