import 'package:flutter/material.dart';

class WorkerManagementScreen extends StatelessWidget {
  const WorkerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Empleados')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkerDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 3, // Número de empleados de ejemplo
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Mesero ${index + 1}'),
            subtitle: Text('mesero${index + 1}@restaurante.com'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }

  void _showAddWorkerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Empleado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(decoration: InputDecoration(labelText: 'Nombre')),
              const TextField(decoration: InputDecoration(labelText: 'Email')),
              const TextField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Lógica para agregar empleado
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