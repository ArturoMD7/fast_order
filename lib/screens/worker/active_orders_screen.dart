// lib/screens/worker/active_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/common/order_tile.dart';

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Activos'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Order>>(
        future: orderService.getActiveOrders('1'), // ID del restaurante
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay pedidos activos',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/worker/order-detail',
                    arguments: order.id,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    child: OrderTile(order: order, onTap: () => {},),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
