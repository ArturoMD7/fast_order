// lib/screens/worker/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../services/order_service.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)!.settings.arguments as String;
    final orderService = Provider.of<OrderService>(context);

    // En una app real, obtendrías la orden completa del servicio
    final order = Order(
      id: orderId,
      restaurantId: '1',
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
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Orden #$orderId')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles de la Orden',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Mesa: ${order.tableId}'),
                    Text('Estado: ${_getStatusText(order.status)}'),
                    Text('Hora: ${_formatTime(order.createdAt)}'),
                    const SizedBox(height: 8),
                    Text(
                      'Total: \$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return ListTile(
                    leading: const Icon(Icons.fastfood),
                    title: Text(item.productName),
                    subtitle: Text('Cantidad: ${item.quantity}'),
                    trailing: Text(
                        '\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            if (order.status != 'delivered')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    String newStatus = 'ready';
                    if (order.status == 'pending') {
                      newStatus = 'preparing';
                    } else if (order.status == 'preparing') {
                      newStatus = 'ready';
                    }

                    await orderService.updateOrderStatus(orderId, newStatus);
                    Navigator.pop(context);
                  },
                  child: Text(_getActionText(order.status)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'preparing':
        return 'En Preparación';
      case 'ready':
        return 'Listo para Servir';
      case 'delivered':
        return 'Entregado';
      default:
        return status;
    }
  }

  String _getActionText(String status) {
    switch (status) {
      case 'pending':
        return 'Comenzar Preparación';
      case 'preparing':
        return 'Marcar como Listo';
      default:
        return 'Actualizar Estado';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}