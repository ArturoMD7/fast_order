import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;
  
  const AdminGuard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final restaurant = authService.currentRestaurant;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('No autenticado')),
      );
    }

    if (!user.isRestaurantAdmin) {
      return Scaffold(
        body: Center(child: Text('No tienes permisos de administrador')),
      );
    }

    if (restaurant == null || restaurant.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No tienes un restaurante asignado'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false
                ),
                child: Text('Volver al login'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}