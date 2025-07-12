import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/restaurant_service.dart';
import '../../widgets/common/product_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final restaurantId = args['restaurantId'] as String;
    final tableId = args['tableId'] as String; // Ahora se usa
    
    final restaurantService = Provider.of<RestaurantService>(context);
    
    return FutureBuilder<List<String>>(
      future: restaurantService.getCategories(restaurantId),
      builder: (context, categoriesSnapshot) {
        if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!categoriesSnapshot.hasData || categoriesSnapshot.data!.isEmpty) {
          return const Center(child: Text('No hay categorías disponibles'));
        }
        
        final categories = categoriesSnapshot.data!;
        
        return DefaultTabController(
          length: categories.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Menú'),
              bottom: TabBar(
                tabs: categories.map((category) => Tab(text: category)).toList(),
              ),
            ),
            body: TabBarView(
              children: categories.map((category) {
                return FutureBuilder<List<Product>>(
                  future: restaurantService.getProductsByCategory(restaurantId, category),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No hay productos en $category'));
                    }
                    
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final product = snapshot.data![index];
                        return ProductCard(
                          product: product,
                          onAddToCart: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} agregado al carrito')),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/client/cart'),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        );
      },
    );
  }
}