import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/common/stats_chart.dart';

class RestaurantStatsScreen extends StatelessWidget {
  const RestaurantStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              height: 320,
              child: const StatsChart(
                title: 'Ventas por mes',
                data: {
                  'Ene': 5000,
                  'Feb': 7000,
                  'Mar': 4000,
                  'Abr': 8000,
                  'May': 9000,
                },
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildStatTile(
                    title: 'Total ventas hoy',
                    trailing: '\$2,500',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  _buildStatTile(
                    title: 'Pedidos hoy',
                    trailing: '45',
                    icon: Icons.shopping_cart,
                    color: Colors.deepOrange,
                  ),
                  _buildStatTile(
                    title: 'Producto más vendido',
                    trailing: 'Pizza Margarita',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String trailing,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          trailing,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
