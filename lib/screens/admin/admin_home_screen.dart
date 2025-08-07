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
    final user = authService.currentUser!;

    final primaryColor = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              accountName: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(
                user.email,
                style: const TextStyle(fontSize: 14),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 40,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.menu_book,
                    text: 'Menú del Restaurante',
                    onTap: () => Navigator.pushNamed(context, '/admin/product-manager'),
                    primaryColor: primaryColor,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.people,
                    text: 'Gestión de Empleados',
                    onTap: () => Navigator.pushNamed(context, '/admin/worker-management'),
                    primaryColor: primaryColor,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.bar_chart,
                    text: 'Estadísticas',
                    onTap: () => Navigator.pushNamed(context, '/admin/restaurant-stats'),
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Panel de Administración',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Gestiona el menú, empleados y estadísticas de tu restaurante fácilmente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      required Color primaryColor}) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      hoverColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
    );
  }
}
