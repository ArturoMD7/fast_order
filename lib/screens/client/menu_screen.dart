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
    final tableId = args['tableId'] as String;

    final restaurantService = Provider.of<RestaurantService>(context);

    final primaryColor = const Color(0xFFD2691E);
    final secondaryColor = const Color(0xFFF4A460);
    final backgroundColor = const Color(0xFFFFF8F0);

    return FutureBuilder<List<String>>(
      future: restaurantService.getCategories(restaurantId),
      builder: (context, categoriesSnapshot) {
        if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.brown)),
          );
        }

        if (!categoriesSnapshot.hasData || categoriesSnapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: const Text('Menú', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: Text(
                'No hay categorías disponibles',
                style: TextStyle(fontSize: 16, color: primaryColor),
              ),
            ),
          );
        }

        final categories = categoriesSnapshot.data!;

        return DefaultTabController(
          length: categories.length,
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: const Text('Menú', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: categories.map((category) => Tab(text: category)).toList(),
              ),
            ),
            body: TabBarView(
              children: categories.map((category) {
                return FutureBuilder<List<Product>>(
                  future: restaurantService.getProductsByCategory(restaurantId, category),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.brown));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay productos en $category',
                          style: TextStyle(fontSize: 16, color: primaryColor),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final product = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ProductCard(
                              product: product,
                              onAddToCart: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} agregado al carrito'),
                                    backgroundColor: primaryColor,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () => Navigator.pushNamed(context, '/client/cart'),
              child: const Icon(Icons.shopping_cart, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
