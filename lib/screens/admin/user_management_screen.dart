import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo
    final users = [
      {'id': '1', 'name': 'Admin', 'email': 'admin@example.com', 'role': 'admin'},
      {'id': '2', 'name': 'Mesero 1', 'email': 'mesero1@example.com', 'role': 'worker'},
      {'id': '3', 'name': 'Cliente 1', 'email': 'cliente1@example.com', 'role': 'client'},
    ];

    final primaryColor = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: primaryColor,
                ),
              ),
              title: Text(
                user['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                '${user['email']} • ${_roleLabel(user['role']!)}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: primaryColor),
                    tooltip: 'Editar usuario',
                    onPressed: () {
                      // Lógica para editar usuario
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: 'Eliminar usuario',
                    onPressed: () {
                      // Lógica para eliminar usuario
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showAddUserDialog(context, primaryColor),
        child: const Icon(Icons.add),
      ),
    );
  }

  static String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'worker':
        return 'Trabajador';
      case 'client':
        return 'Cliente';
      default:
        return role;
    }
  }

  void _showAddUserDialog(BuildContext context, Color primaryColor) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Usuario'),
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
              child: Text(
                'Cancelar',
                style: TextStyle(color: primaryColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // Aquí agregarías la lógica para guardar el usuario
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
