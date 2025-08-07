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

    // Simulación de orden, en producción cargar desde el servicio
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

    final primaryColor = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #$orderId'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de la Orden',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailLabel('Mesa:', order.tableId),
                        _buildDetailLabel(
                          'Estado:',
                          _getStatusText(order.status),
                          color: _statusColor(order.status, primaryColor),
                        ),
                        _buildDetailLabel(
                          'Hora:',
                          _formatTime(order.createdAt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total: \$${order.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.fastfood, color: Colors.deepPurple),
                    ),
                    title: Text(
                      item.productName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Cantidad: ${item.quantity}'),
                    trailing: Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  );
                },
              ),
            ),
            if (order.status != 'delivered') ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
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
                  child: Text(
                    _getActionText(order.status),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailLabel(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            )),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
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

  Color _statusColor(String status, Color defaultColor) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.grey;
      default:
        return defaultColor;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
