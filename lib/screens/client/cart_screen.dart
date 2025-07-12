// lib/screens/client/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/common/product_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // En una app real, esto vendría de un CartService o similar
    final List<OrderItem> cartItems = [
      OrderItem(
        productId: '101',
        productName: 'Pizza Margarita',
        quantity: 2,
        price: 12.99,
      ),
    ];

    final total = cartItems.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: const Icon(Icons.fastfood),
                  title: Text(item.productName),
                  subtitle: Text('Cantidad: ${item.quantity}'),
                  trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 18)),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final orderService =
                          Provider.of<OrderService>(context, listen: false);
                      
                      // Crear la orden
                      final newOrder = Order(
                        id: '',
                        restaurantId: '1', // ID del restaurante actual
                        tableId: 'Mesa-5', // Mesa del QR
                        items: cartItems,
                        total: total,
                        createdAt: DateTime.now(),
                      );

                      // Enviar la orden
                      final orderId = await orderService.createOrder(newOrder);
                      
                      // Navegar a confirmación
                      Navigator.pushNamed(
                        context,
                        '/client/order-confirmation',
                        arguments: orderId,
                      );
                    },
                    child: const Text('Confirmar Pedido'),
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