import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final restaurant = authService.currentRestaurant!;

    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(authService.currentUser!.name),
              accountEmail: Text(authService.currentUser!.email),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Menú del Restaurante'),
              onTap: () => Navigator.pushNamed(context, '/admin/product-manager'),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Gestión de Empleados'),
              onTap: () => Navigator.pushNamed(context, '/admin/worker-management'),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Estadísticas'),
              onTap: () => Navigator.pushNamed(context, '/admin/restaurant-stats'),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Panel de Administración del Restaurante'),
      ),
    );
  }
}