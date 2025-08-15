import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementScreen extends StatelessWidget {
  final String idRestaurante;

  const UserManagementScreen({
    super.key,
    required this.idRestaurante,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFD2691E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Aquí iría la lista de usuarios...',
          style: TextStyle(fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showAddUserDialog(context, primaryColor),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, Color primaryColor) {
    final supabase = Supabase.instance.client;

    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> saveUser() async {
              if (nameController.text.trim().isEmpty ||
                  lastNameController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Todos los campos son obligatorios!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() => isLoading = true);

              try {
                final authResponse = await supabase.auth.signUp(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );

                if (authResponse.user == null) {
                  throw Exception('No se pudo crear el usuario en autenticación.');
                }

                final userId = authResponse.user!.id;

                await supabase.from('Usuarios').insert({
                  'id': userId,
                  'nombre': nameController.text.trim(),
                  'apellidos': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'contrasena': passwordController.text,
                  'rol': 'trabajador',
                  'id_restaurante': idRestaurante, // se vincula con el restaurante del dueño
                  'created_at': DateTime.now().toIso8601String(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trabajador registrado correctamente'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } on AuthException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error de autenticación: ${e.message}'), backgroundColor: Colors.red),
                  );
                }
              } on PostgrestException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error en base de datos: ${e.message}'), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.red),
                  );
                }
              } finally {
                if (context.mounted) setState(() => isLoading = false);
              }
            }

            return AlertDialog(
              title: const Text('Registrar Trabajador'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Apellidos',
                        prefixIcon: Icon(Icons.badge, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: primaryColor),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock, color: primaryColor),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar', style: TextStyle(color: primaryColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isLoading ? null : saveUser,
                  child: isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
