// lib/screens/client/restaurants_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/restaurant.dart';
import '../../services/restaurant_service.dart';
import '../../widgets/common/restaurant_card.dart';

class RestaurantsScreen extends StatelessWidget {
  const RestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantService = Provider.of<RestaurantService>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurantes')),
      body: FutureBuilder<List<Restaurant>>(
        future: restaurantService.getRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay restaurantes disponibles'));
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final restaurant = snapshot.data![index];
              return RestaurantCard(
                restaurant: restaurant,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/client/restaurant-detail',
                  arguments: restaurant,
                ),
              );
            },
          );
        },
      ),
    );
  }
}