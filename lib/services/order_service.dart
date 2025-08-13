// lib/services/order_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/product.dart';

class OrderService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final List<Order> _orders = [];

  Future<List<Order>> getActiveOrders(String restaurantId) async {
    try {
      final response = await _supabase
          .from('Pedidos')
          .select('''
            *,
            id_producto:Productos(nombre, precio, imagen_url),
            id_usuario:Usuarios(nombre)
          ''')
          .eq('id_restaurante', restaurantId)
          .eq('estado', 'pedido') // Solo pedidos activos
          .order('fecha', ascending: false);

      return response.map((order) {
        final productData = order['id_producto'] as Map<String, dynamic>?;
        final userData = order['id_usuario'] as Map<String, dynamic>?;

        return Order(
          id: order['id'].toString(),
          restaurantId: order['id_restaurante'].toString(),
          tableId: order['mesa']?.toString() ?? 'Sin mesa',
          items: [
            OrderItem(
              productId: order['id_producto'].toString(),
              productName: productData?['nombre'] ?? 'Producto desconocido',
              quantity: order['cantidad'] ?? 1,
              price: (productData?['precio'] as num?)?.toDouble() ?? 0.0,
            ),
          ],
          total: (order['cantidad'] ?? 1) * 
                ((productData?['precio'] as num?)?.toDouble() ?? 0.0),
          status: order['estado'] ?? 'pedido',
          createdAt: DateTime.parse(order['fecha']),
          customerName: userData?['nombre']?.toString(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error al obtener pedidos: $e');
      return [];
    }
  }

  Future<String> createOrder({
    required String restaurantId,
    required String productId,
    required int quantity,
    String? tableId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final response = await _supabase.from('Pedidos').insert({
        'id_restaurante': restaurantId,
        'id_producto': productId,
        'id_usuario': user.id,
        'cantidad': quantity,
        'mesa': tableId,
        'fecha': DateTime.now().toIso8601String(),
        'estado': 'pedido',
      }).select('id').single();

      final newOrderId = response['id'].toString();
      notifyListeners();
      return newOrderId;
    } catch (e) {
      debugPrint('Error al crear pedido: $e');
      throw Exception('No se pudo crear el pedido');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase
          .from('Pedidos')
          .update({'estado': newStatus})
          .eq('id', orderId);

      // Actualizar lista local
      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al actualizar estado: $e');
      throw Exception('No se pudo actualizar el estado');
    }
  }

  // Método para agregar múltiples productos a un pedido
  Future<String> createOrderWithItems({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    String? tableId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Validar items
      if (items.isEmpty) throw Exception('El carrito está vacío');

      // Crear pedidos en Supabase
      final orders = items.map((item) => {
        'id_restaurante': restaurantId,
        'id_producto': item['id'],
        'id_usuario': user.id,
        'cantidad': item['quantity'] ?? 1,
        'mesa': tableId,
        'fecha': DateTime.now().toIso8601String(),
        'estado': 'pedido',
      }).toList();

      final response = await _supabase.from('Pedidos').insert(orders).select();

      return response.first['id'].toString();
    } catch (e) {
      debugPrint('Error al crear pedido: $e');
      throw Exception('No se pudo crear el pedido: ${e.toString()}');
    }
  }
}