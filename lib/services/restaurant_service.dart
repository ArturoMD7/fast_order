import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/restaurant.dart';

class RestaurantService with ChangeNotifier {
  final List<Restaurant> _restaurants = [];
  final List<Product> _products = [];

  Future<List<Restaurant>> getRestaurants() async {
    await Future.delayed(const Duration(seconds: 1));
    return _restaurants;
  }

  Future<Restaurant> createRestaurant({
    required String name,
    required String description,
    required String ownerId,
  }) async {
    final newRestaurant = Restaurant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      imageUrl: 'https://example.com/restaurant.jpg',
      ownerId: ownerId,
    );
    _restaurants.add(newRestaurant);
    notifyListeners();
    return newRestaurant;
  }

  Future<List<Product>> getProductsByCategory(String restaurantId, String category) async {
    await Future.delayed(const Duration(seconds: 1));
    return _products.where((p) => p.restaurantId == restaurantId && p.category == category).toList();
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    notifyListeners();
  }

  Future<List<String>> getCategories(String restaurantId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final categories = _products
        .where((p) => p.restaurantId == restaurantId)
        .map((p) => p.category)
        .toSet()
        .toList();
    return categories.isNotEmpty ? categories : ['Entradas', 'Platos principales', 'Postres'];
  }
}