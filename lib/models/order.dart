// lib/models/order.dart
class Order {
  final String id;
  final String restaurantId;
  final String tableId;
  final List<OrderItem> items;
  final double total;
  final String status; // 'sin_pedido', 'pedido', 'completado'
  final DateTime createdAt;
  final String? customerName;

  Order({
    required this.id,
    required this.restaurantId,
    required this.tableId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.customerName,
  });

  Order copyWith({
    String? status,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id,
      restaurantId: restaurantId,
      tableId: tableId,
      items: items ?? this.items,
      total: total,
      status: status ?? this.status,
      createdAt: createdAt,
      customerName: customerName,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });
}