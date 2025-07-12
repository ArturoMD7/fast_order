// lib/screens/admin/restaurant_stats_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../widgets/common/stats_chart.dart';

class RestaurantStatsScreen extends StatelessWidget {
  const RestaurantStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 300,
              child: StatsChart(
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
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(title: Text('Total ventas hoy'), trailing: Text('\$2,500')),
                  ListTile(title: Text('Pedidos hoy'), trailing: Text('45')),
                  ListTile(title: Text('Producto más vendido'), trailing: Text('Pizza Margarita')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}