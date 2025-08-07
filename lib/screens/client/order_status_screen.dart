// lib/screens/client/order_status_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/order_service.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)!.settings.arguments as String;
    final orderService = Provider.of<OrderService>(context);

    // Simulamos la obtención del estado del pedido
    final orderStatus = 'preparing'; // Esto debería venir del servicio

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Estado del Pedido'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            _buildStatusStep(
              context,
              title: 'Pedido Recibido',
              icon: Icons.receipt_long,
              isActive: true,
              isCompleted: true,
            ),
            _buildStatusLine(isActive: true),
            _buildStatusStep(
              context,
              title: 'En Preparación',
              icon: Icons.kitchen,
              isActive: orderStatus == 'preparing',
              isCompleted: orderStatus == 'preparing' || orderStatus == 'ready',
            ),
            _buildStatusLine(
              isActive: orderStatus == 'preparing' || orderStatus == 'ready',
            ),
            _buildStatusStep(
              context,
              title: 'Listo para Recoger',
              icon: Icons.check_circle,
              isActive: orderStatus == 'ready',
              isCompleted: orderStatus == 'ready',
            ),
            const SizedBox(height: 40),
            Text(
              'Orden #$orderId',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            if (orderStatus == 'preparing')
              const Text(
                'Estamos preparando tu pedido...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/client/restaurants', (route) => false);
                },
                icon: const Icon(Icons.restaurant),
                label: const Text('Volver a Restaurantes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
  }) {
    final color = isCompleted
        ? Colors.green
        : isActive
            ? Colors.green.withOpacity(0.6)
            : Colors.grey[300];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 2, bottom: 2),
      width: 2,
      height: 30,
      color: isActive ? Colors.green : Colors.grey[300],
    );
  }
}
