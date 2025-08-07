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

    final primaryColor = const Color(0xFFD2691E);
    final secondaryColor = const Color(0xFFF4A460);
    final backgroundColor = const Color(0xFFFFF8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Restaurantes',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: restaurantService.getRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.brown));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay restaurantes disponibles',
                style: TextStyle(color: primaryColor, fontSize: 18),
              ),
            );
          }

          final restaurants = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Image(
                  image: AssetImage('assets/imgs/logo_fast.png'),
                  height: 80,
                ),
                const SizedBox(height: 10),
                Text(
                  'Elige tu restaurante favorito',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          shadowColor: primaryColor.withOpacity(0.3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/client/restaurant-detail',
                              arguments: restaurant,
                            ),
                            child: RestaurantCard(
                              onTap: () => {},
                              restaurant: restaurant),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
