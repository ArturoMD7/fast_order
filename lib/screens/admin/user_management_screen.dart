import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fast_order/models/user.dart' as AppUser;
import '../../services/auth_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<AppUser.User> workers = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final restaurant = authService.currentRestaurant;

      if (restaurant == null || restaurant.id.isEmpty) {
        throw Exception('No hay restaurante asignado o el ID es inválido');
      }

      debugPrint('Buscando trabajadores para restaurante ID: ${restaurant.id}');

      final response = await Supabase.instance.client
          .from('Usuarios')
          .select('*');

      debugPrint('Trabajadores encontrados: ${response.length}');

      final List<AppUser.User> loadedWorkers = [];
      for (final workerData in response) {
        try {
          // Mapeo correcto según tu esquema de base de datos
          final mappedData = {
            'id': workerData['id'],
            'nombre': workerData['nombre'] ?? '',
            'apellidos': workerData['apellidos'] ?? '',
            'email': workerData['email'] ?? '',
            'rol': workerData['rol'] ?? 'worker', // Usando 'rd' como campo de rol
            'id_restaurante': workerData['id_restaurante'],
            'created_at': workerData['created_at'],
          };
          loadedWorkers.add(AppUser.User.fromJson(mappedData));
        } catch (e) {
          debugPrint('Error procesando trabajador: $e\nDatos: $workerData');
        }
      }

      setState(() {
        workers = loadedWorkers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar trabajadores: $e');
      setState(() {
        error = 'Error al cargar trabajadores: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _showAddUserDialog(Color primaryColor) {
    final supabase = Supabase.instance.client;
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool dialogLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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

              setDialogState(() => dialogLoading = true);

              try {
                // 1. Crear usuario en autenticación
                final authResponse = await supabase.auth.signUp(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );

                if (authResponse.user == null) {
                  throw Exception('No se pudo crear el usuario en autenticación.');
                }

                final userId = authResponse.user!.id;
                final authService = Provider.of<AuthService>(context, listen: false);
                final restaurant = authService.currentRestaurant;

                if (restaurant == null) {
                  throw Exception('No se pudo obtener el restaurante asociado');
                }

                // 2. Insertar en tabla Usuarios
                await supabase.from('Usuarios').insert({
                  'id': userId,
                  'nombre': nameController.text.trim(),
                  'apellidos': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'contrasena': passwordController.text,
                  'rol': 'worker', // Campo correcto según tu esquema
                  'id_restaurante': restaurant.id,
                  'created_at': DateTime.now().toIso8601String(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trabajador registrado correctamente'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  await _loadWorkers(); // Recargar la lista
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setDialogState(() => dialogLoading = false);
                }
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
                  onPressed: dialogLoading ? null : saveUser,
                  child: dialogLoading
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Trabajadores'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkers,
            tooltip: 'Recargar lista',
          ),
        ],
      ),
      body: _buildBody(primaryColor),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showAddUserDialog(primaryColor),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(Color primaryColor) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar trabajadores',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadWorkers,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar nuevamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
            ),
          ],
        ),
      );
    }

    if (workers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay trabajadores registrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Presiona el botón + para agregar uno nuevo',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workers.length,
      itemBuilder: (context, index) {
        final worker = workers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, color: primaryColor),
            ),
            title: Text(
              '${worker.name} ${worker.email}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(worker.email),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    worker.roleDisplayName,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: primaryColor,
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(worker.id),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Trabajador'),
        content: const Text('¿Estás seguro de que deseas eliminar a este trabajador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client
            .from('Usuarios')
            .delete()
            .eq('id', userId);

        // Opcional: Eliminar también de autenticación
        // await Supabase.instance.client.auth.admin.deleteUser(userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trabajador eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadWorkers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}