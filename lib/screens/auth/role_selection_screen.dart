import 'package:fast_order/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona tu rol')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.role == UserRole.client)
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/client/restaurants', (route) => false),
                child: const Text('Entrar como Cliente'),
              ),
            if (user.role == UserRole.restaurantAdmin)
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/admin/home', (route) => false),
                child: const Text('Administrar mi Restaurante'),
              ),
            if (user.role == UserRole.worker)
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/worker/home', (route) => false),
                child: const Text('Entrar como Trabajador'),
              ),
          ],
        ),
      ),
    );
  }
}