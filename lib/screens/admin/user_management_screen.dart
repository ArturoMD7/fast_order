import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementScreen extends StatefulWidget {
  final String idRestaurante;

  const UserManagementScreen({
    super.key,
    required this.idRestaurante,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> workers = [];
  bool isLoadingWorkers = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
  }

  Future<void> _fetchWorkers() async {
    setState(() => isLoadingWorkers = true);
    try {
      final response = await supabase
          .from('Usuarios')
          .select()
          .eq('rol', 'trabajador')
          .eq('id_restaurante', widget.idRestaurante);
      if (response != null) {
        setState(() => workers = List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar trabajadores: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isLoadingWorkers = false);
    }
  }

  Future<void> _deleteWorker(String workerId) async {
    try {
      await supabase.from('Usuarios').delete().eq('id', workerId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trabajador eliminado'), backgroundColor: Colors.green),
      );
      _fetchWorkers();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar trabajador: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddOrEditUserDialog(BuildContext context, Color primaryColor, {Map<String, dynamic>? worker}) {
    final nameController = TextEditingController(text: worker?['nombre'] ?? '');
    final lastNameController = TextEditingController(text: worker?['apellidos'] ?? '');
    final emailController = TextEditingController(text: worker?['email'] ?? '');
    final passwordController = TextEditingController();
    bool isLoading = false;
    final isEditing = worker != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> saveUser() async {
            if (nameController.text.trim().isEmpty ||
                lastNameController.text.trim().isEmpty ||
                emailController.text.trim().isEmpty ||
                (!isEditing && passwordController.text.isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Todos los campos son obligatorios!'), backgroundColor: Colors.red),
              );
              return;
            }

            setState(() => isLoading = true);

            try {
              if (isEditing) {
                // Actualizar trabajador
                final updateData = {
                  'nombre': nameController.text.trim(),
                  'apellidos': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                };
                if (passwordController.text.isNotEmpty) {
                  updateData['contrasena'] = passwordController.text;
                }

                await supabase.from('Usuarios').update(updateData).eq('id', worker!['id']);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trabajador actualizado'), backgroundColor: Colors.green),
                  );
                  _fetchWorkers();
                }
              } else {
                // Crear trabajador
                final authResponse = await supabase.auth.signUp(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
                if (authResponse.user == null) throw Exception('No se pudo crear el usuario.');

                final userId = authResponse.user!.id;

                await supabase.from('Usuarios').insert({
                  'id': userId,
                  'nombre': nameController.text.trim(),
                  'apellidos': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'contrasena': passwordController.text,
                  'rol': 'trabajador',
                  'id_restaurante': widget.idRestaurante,
                  'created_at': DateTime.now().toIso8601String(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trabajador registrado correctamente'), backgroundColor: Colors.green),
                  );
                  _fetchWorkers();
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            } finally {
              if (context.mounted) setState(() => isLoading = false);
            }
          }

          return AlertDialog(
            title: Text(isEditing ? 'Editar Trabajador' : 'Registrar Trabajador'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person, color: primaryColor))),
                  const SizedBox(height: 12),
                  TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Apellidos', prefixIcon: Icon(Icons.badge, color: primaryColor))),
                  const SizedBox(height: 12),
                  TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email, color: primaryColor))),
                  const SizedBox(height: 12),
                  TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Contraseña (opcional)', prefixIcon: Icon(Icons.lock, color: primaryColor)), obscureText: true),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar', style: TextStyle(color: primaryColor))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: isLoading ? null : saveUser,
                child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(isEditing ? 'Guardar Cambios' : 'Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoadingWorkers
          ? const Center(child: CircularProgressIndicator())
          : workers.isEmpty
              ? const Center(child: Text('No hay trabajadores registrados.'))
              : ListView.builder(
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text('${worker['nombre']} ${worker['apellidos']}'),
                        subtitle: Text(worker['email'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddOrEditUserDialog(context, primaryColor, worker: worker),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteWorker(worker['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showAddOrEditUserDialog(context, primaryColor),
        child: const Icon(Icons.add),
      ),
    );
  }
}
