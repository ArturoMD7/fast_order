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

  void _showEditWorkerDialog(BuildContext context, Map<String, dynamic>? worker) {
    final isEditing = worker != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: worker?['nombre'] ?? '');
    final lastNameController = TextEditingController(text: worker?['apellidos'] ?? '');
    final emailController = TextEditingController(text: worker?['email'] ?? '');
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Editar Trabajador' : 'Registrar Trabajador'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Apellidos'),
                    validator: (value) => value!.isEmpty ? 'Los apellidos son requeridos' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value!.isEmpty ? 'El email es requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña (opcional)'),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);

                      try {
                        if (isEditing) {
                          final updateData = {
                            'nombre': nameController.text.trim(),
                            'apellidos': lastNameController.text.trim(),
                            'email': emailController.text.trim(),
                          };
                          if (passwordController.text.isNotEmpty) {
                            updateData['contrasena'] = passwordController.text;
                          }

                          await supabase
                              .from('Usuarios')
                              .update(updateData)
                              .eq('id', worker!['id']);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Trabajador actualizado'), backgroundColor: Colors.green),
                            );
                            _fetchWorkers();
                          }
                        } else {
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
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Guardar Cambios' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteWorker(BuildContext context, Map<String, dynamic> worker) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar al trabajador "${worker['nombre']} ${worker['apellidos']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await supabase.from('Usuarios').delete().eq('id', worker['id']);
                _fetchWorkers();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Trabajador "${worker['nombre']}" eliminado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar trabajador: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
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
                              onPressed: () => _showEditWorkerDialog(context, worker),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteWorker(context, worker),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showEditWorkerDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
