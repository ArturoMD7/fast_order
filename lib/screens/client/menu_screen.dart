import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/category_service.dart'; // Importamos el servicio correcto
import '../../widgets/common/product_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final restaurantId = args?['restaurantId'] as String?;
    final tableId = args?['tableId'] as String?;

    if (restaurantId == null || tableId == null) {
      return _buildErrorScreen('Datos del restaurante no disponibles');
    }

    final categoryService = Provider.of<CategoryService>(context, listen: false);
    final primaryColor = const Color(0xFFD2691E);
    final backgroundColor = const Color(0xFFFFF8F0);

    return FutureBuilder<List<Category>>(
      future: categoryService.getCategories(restaurantId: restaurantId),
      builder: (context, categoriesSnapshot) {
        // Estados de carga y error
        if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(backgroundColor);
        }

        if (categoriesSnapshot.hasError) {
          return _buildErrorScreen('Error al cargar categorías');
        }

        if (!categoriesSnapshot.hasData || categoriesSnapshot.data!.isEmpty) {
          return _buildNoCategoriesScreen(primaryColor, backgroundColor);
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
                tabs: categories.map((category) => Tab(text: category.nombre)).toList(),
              ),
            ),
            body: TabBarView(
              children: categories.map((category) {
                return _buildProductList(
                  context: context,
                  categoryService: categoryService,
                  categoryId: category.id,
                  primaryColor: primaryColor,
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

  // Widget auxiliar para la lista de productos
  Widget _buildProductList({
    required BuildContext context,
    required CategoryService categoryService,
    required String categoryId,
    required Color primaryColor,
  }) {
    return FutureBuilder<List<Product>>(
      future: categoryService.getProductsByCategory(categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.brown));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar productos',
              style: TextStyle(fontSize: 16, color: primaryColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No hay productos en esta categoría',
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
                        content: Text('${product.nombre} agregado al carrito'),
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
  }

  // Widgets auxiliares (iguales que en la versión anterior)
  Widget _buildLoadingScreen(Color backgroundColor) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.brown)),
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildNoCategoriesScreen(Color primaryColor, Color backgroundColor) {
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

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}