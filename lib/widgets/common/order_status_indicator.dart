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

  IconData getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'en espera':
        return Icons.hourglass_empty;
      case 'preparando':
        return Icons.kitchen;
      case 'listo':
        return Icons.check_circle_outline;
      case 'entregado':
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.25),
            color.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getStatusIcon(), color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
