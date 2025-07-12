// lib/screens/client/order_confirmation_screen.dart
import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmación')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 100),
              const SizedBox(height: 24),
              const Text(
                '¡Pedido Confirmado!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Número de orden: #$orderId',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              const Text(
                'Tu pedido está siendo preparado',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/client/order-status', (route) => false,
                      arguments: orderId),
                  child: const Text('Ver Estado del Pedido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}