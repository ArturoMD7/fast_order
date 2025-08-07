import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../services/order_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<OrderItem> cartItems = [
      OrderItem(
        productId: '101',
        productName: 'Pizza Margarita',
        quantity: 2,
        price: 12.99,
      ),
    ];

    final total = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Carrito'),
        backgroundColor: Colors.deepOrange,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Tu carrito está vacío',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.all(12),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.fastfood, color: Colors.deepOrange),
                          title: Text(
                            item.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text('Cantidad: ${item.quantity}'),
                          trailing: Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final orderService =
                        Provider.of<OrderService>(context, listen: false);

                    final newOrder = Order(
                      id: '',
                      restaurantId: '1',
                      tableId: 'Mesa-5',
                      items: cartItems,
                      total: total,
                      createdAt: DateTime.now(),
                    );

                    final orderId = await orderService.createOrder(newOrder);

                    Navigator.pushNamed(
                      context,
                      '/client/order-confirmation',
                      arguments: orderId,
                    );
                  },
                  child: const Text(
                    'Confirmar Pedido',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
