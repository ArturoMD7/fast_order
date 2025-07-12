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
    final orderStatus = 'preparing'; // En una app real, esto vendría del servicio

    return Scaffold(
      appBar: AppBar(title: const Text('Estado del Pedido')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusStep(
                context,
                title: 'Pedido Recibido',
                isActive: true,
                isCompleted: true,
              ),
              _buildStatusLine(context, isActive: true),
              _buildStatusStep(
                context,
                title: 'En Preparación',
                isActive: orderStatus == 'preparing',
                isCompleted: orderStatus == 'preparing' || orderStatus == 'ready',
              ),
              _buildStatusLine(context,
                  isActive: orderStatus == 'preparing' || orderStatus == 'ready'),
              _buildStatusStep(
                context,
                title: 'Listo para Recoger',
                isActive: orderStatus == 'ready',
                isCompleted: orderStatus == 'ready',
              ),
              const SizedBox(height: 32),
              Text(
                'Orden #$orderId',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (orderStatus == 'preparing')
                const Text(
                  'Tu pedido está siendo preparado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/client/restaurants', (route) => false),
                child: const Text('Volver a Restaurantes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStep(
    BuildContext context, {
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Theme.of(context).primaryColor
                : isActive
                    ? Theme.of(context).primaryColor.withOpacity(0.5)
                    : Colors.grey[300],
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 8),
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

  Widget _buildStatusLine(BuildContext context, {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      width: 2,
      height: 30,
      color: isActive
          ? Theme.of(context).primaryColor
          : Colors.grey[300],
    );
  }
}