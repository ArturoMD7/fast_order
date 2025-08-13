import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/restaurant.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant;
    final primaryColor = const Color(0xFFD2691E);
    final secondaryColor = const Color(0xFFF4A460);
    final backgroundColor = const Color(0xFFFFF8F0);
    final accentColor = const Color(0xFF8B4513);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Menú - ${restaurant.nombre}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: FutureBuilder<List<Category>>(
        future: Provider.of<CategoryService>(context, listen: false)
            .getCategories(restaurantId: restaurant.id),
        builder: (context, categoriesSnapshot) {
          // Estados de carga y error
          if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD2691E)));
          }

          if (categoriesSnapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el menú',
                style: TextStyle(fontSize: 18, color: primaryColor),
              ),
            );
          }

          if (!categoriesSnapshot.hasData || categoriesSnapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay categorías disponibles',
                style: TextStyle(fontSize: 18, color: primaryColor),
              ),
            );
          }

          final categories = categoriesSnapshot.data!;

          return DefaultTabController(
            length: categories.length,
            child: Column(
              children: [
                Container(
                  color: primaryColor.withOpacity(0.1),
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: primaryColor,
                    labelColor: primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: categories.map((category) => 
                      Tab(text: category.nombre.toUpperCase())).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: categories.map((category) {
                      return _buildCategoryProducts(
                        context: context,
                        category: category,
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor,
                        accentColor: accentColor,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () {
          // Navegar al carrito
          // Navigator.pushNamed(context, '/client/cart');
        },
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: const Text('Ver Pedido', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCategoryProducts({
    required BuildContext context,
    required Category category,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
  }) {
    return FutureBuilder<List<Product>>(
      future: Provider.of<ProductService>(context, listen: false)
          .getProductsByCategory(category.id),
      builder: (context, productsSnapshot) {
        if (productsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD2691E)));
        }

        if (productsSnapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar productos',
              style: TextStyle(fontSize: 16, color: primaryColor),
            ),
          );
        }

        if (!productsSnapshot.hasData || productsSnapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No hay productos en esta categoría',
              style: TextStyle(fontSize: 16, color: primaryColor),
            ),
          );
        }

        final products = productsSnapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductItem(
              product: product,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              accentColor: accentColor,
            );
          },
        );
      },
    );
  }

  Widget _buildProductItem({
    required Product product,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: product.imagenUrl != null && product.imagenUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imagenUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.fastfood,
                          color: primaryColor,
                          size: 40,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.fastfood,
                      color: primaryColor,
                      size: 40,
                    ),
            ),
            
            const SizedBox(width: 12),
            
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (product.description != null && product.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '\$${product.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Botón para agregar al carrito
            IconButton(
              icon: Icon(Icons.add_circle, color: primaryColor, size: 30),
              onPressed: () {
                // Lógica para agregar al carrito
              },
            ),
          ],
        ),
      ),
    );
  }
}