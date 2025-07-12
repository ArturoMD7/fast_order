// lib/screens/client/restaurant_detail_screen.dart
import 'package:flutter/material.dart';

import '../../models/restaurant.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant;
    
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: Column(
        children: [
          Image.network(restaurant.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(restaurant.description),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/client/qr-scanner'),
            child: const Text('Escanear QR para ordenar'),
          ),
        ],
      ),
    );
  }
}