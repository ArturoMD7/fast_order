// lib/screens/restaurants/restaurant_list_screen.dart
import 'package:fast_order/screens/client/restaurant_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/restaurant_service.dart';
import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import 'package:provider/provider.dart';
import './restaurant_detail_screen.dart'; // Asegúrate de que la ruta sea correcta

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  late Future<List<Restaurant>> _restaurantsFuture;
  late RestaurantService _restaurantService;

  @override
  void initState() {
    super.initState();
    _restaurantService = Provider.of<RestaurantService>(context, listen: false);
    _restaurantsFuture = _restaurantService.getRestaurants();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurantes Disponibles'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.access_alarm),
          ),
        ],
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _restaurantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar restaurantes: ${snapshot.error}',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
              ),
            );
          }

          final restaurants = snapshot.data ?? [];

          if (restaurants.isEmpty) {
            return Center(
              child: Text(
                'No hay restaurantes disponibles',
                style: theme.textTheme.titleMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.restaurant, size: 40),
                  title: Text(
                    restaurant.nombre,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: restaurant.description != null
                      ? Text(
                          restaurant.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RestaurantDetailScreen(),
                        settings: RouteSettings(
                          arguments: restaurant,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}