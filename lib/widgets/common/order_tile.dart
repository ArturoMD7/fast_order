// lib/widgets/common/order_tile.dart
import 'package:flutter/material.dart';
import '../../models/order.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderTile({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.receipt_long),
        title: Text('Orden #${order.id}'),
        subtitle: Text('Mesa: ${order.tableId} - ${order.status}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${order.items.length} items',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}