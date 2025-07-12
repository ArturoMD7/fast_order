// lib/models/order.dart
class Order {
  final String id;
  final String restaurantId;
  final String tableId;
  final List<OrderItem> items;
  final double total;
  final String status; // 'pending', 'preparing', 'ready', 'delivered'
  final DateTime createdAt;

  Order({
    required this.id,
    required this.restaurantId,
    required this.tableId,
    required this.items,
    required this.total,
    this.status = 'pending',
    required this.createdAt,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });
}