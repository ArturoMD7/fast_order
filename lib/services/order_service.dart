// lib/services/order_service.dart
import 'package:flutter/foundation.dart';
import '../models/order.dart';

class OrderService with ChangeNotifier {
  final List<Order> _orders = [];

  Future<List<Order>> getActiveOrders(String restaurantId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular carga
    
    // Datos de ejemplo
    return [
      Order(
        id: '1001',
        restaurantId: restaurantId,
        tableId: 'Mesa-5',
        items: [
          OrderItem(
            productId: '101',
            productName: 'Pizza Margarita',
            quantity: 2,
            price: 12.99,
          ),
        ],
        total: 25.98,
        status: 'preparing',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
  }

  Future<String> createOrder(Order order) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular creación
    _orders.add(order);
    notifyListeners();
    return '2001'; // ID de la nueva orden
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular actualización
    final order = _orders.firstWhere((o) => o.id == orderId);
    // order.status = newStatus; // Descomentar cuando se implemente
    notifyListeners();
  }
}