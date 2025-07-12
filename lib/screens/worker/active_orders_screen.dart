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
      appBar: AppBar(title: const Text('Pedidos Activos')),
      body: FutureBuilder<List<Order>>(
        future: orderService.getActiveOrders('1'), // ID del restaurante
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay pedidos activos'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return OrderTile(
                order: order,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/worker/order-detail',
                  arguments: order.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}