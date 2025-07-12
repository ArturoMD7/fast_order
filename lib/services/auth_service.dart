import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/restaurant.dart';
import './restaurant_service.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  Restaurant? _currentRestaurant;

  User? get currentUser => _currentUser;
  Restaurant? get currentRestaurant => _currentRestaurant;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? restaurantName,
    String? restaurantDescription,
  }) async {
    // 1. Registrar usuario en tu backend
    _currentUser = User(
      id: 'generated-id',
      name: name,
      email: email,
      role: role == 'restaurant' ? UserRole.restaurantAdmin : UserRole.client,
    );

    // 2. Si es restaurante, crea el restaurante
    if (role == 'restaurant' && restaurantName != null) {
      final restaurantService = RestaurantService();
      _currentRestaurant = await restaurantService.createRestaurant(
        name: restaurantName,
        description: restaurantDescription ?? '',
        ownerId: _currentUser!.id,
      );
    }

    notifyListeners();
  }

   Future<bool> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulación de respuesta del servidor
      final mockUsers = [
        {
          'id': '1',
          'name': 'Cliente Ejemplo',
          'email': 'cliente@example.com',
          'role': UserRole.client,
        },
        {
          'id': '2',
          'name': 'Dueño Restaurante',
          'email': 'dueno@example.com',
          'role': UserRole.restaurantAdmin,
          'restaurantId': '1001',
        },
      ];
      
      final userData = mockUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () => throw Exception('Usuario no encontrado'),
      );
      
      _currentUser = User(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: email,
        role: userData['role'] as UserRole,
        restaurantId: userData['restaurantId'] as String?,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error en login: $e');
      return false;
    }
  }
}