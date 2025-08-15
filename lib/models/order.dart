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
  final String? restaurantId;
  final String orderItemId; // No-nullable

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.restaurantId,
    required this.orderItemId, // Marcado como requerido
  });

  // Constructor desde mapa mejorado
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id']?.toString() ?? '0', // Conversión segura
      productName: map['product_name']?.toString() ?? 'Producto desconocido',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url']?.toString(),
      restaurantId: map['restaurant_id']?.toString(),
      orderItemId: map['order_item_id']?.toString() ?? '0', // Valor por defecto
    );
  }

  // Convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'image_url': imageUrl,
      'restaurant_id': restaurantId,
      'order_item_id': orderItemId,
    };
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    String? imageUrl,
    String? restaurantId,
    String? orderItemId,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      restaurantId: restaurantId ?? this.restaurantId,
      orderItemId: orderItemId ?? this.orderItemId,
    );
  }
}