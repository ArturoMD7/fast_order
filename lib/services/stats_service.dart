// lib/services/stats_service.dart
import 'package:flutter/foundation.dart';

class StatsService with ChangeNotifier {
  Future<Map<String, dynamic>> getRestaurantStats(String restaurantId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular carga
    
    return {
      'todaySales': 2500.0,
      'todayOrders': 45,
      'monthlySales': {
        'Ene': 5000.0,
        'Feb': 7000.0,
        'Mar': 4000.0,
        'Abr': 8000.0,
        'May': 9000.0,
      },
      'topProduct': 'Pizza Margarita',
    };
  }
}