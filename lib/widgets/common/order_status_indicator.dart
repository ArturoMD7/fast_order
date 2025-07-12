import 'package:flutter/material.dart';

class OrderStatusIndicator extends StatelessWidget {
  final String status;
  
  const OrderStatusIndicator({
    super.key,
    required this.status,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'en espera':
        return Colors.orange;
      case 'preparando':
        return Colors.blue;
      case 'listo':
        return Colors.green;
      case 'entregado':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          getStatusColor().withOpacity(0.2),
          Theme.of(context).canvasColor,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getStatusColor()),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: getStatusColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}