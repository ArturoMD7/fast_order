import 'package:fast_order/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/restaurant_service.dart';

class ProductManagerScreen extends StatelessWidget {
  const ProductManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantService = Provider.of<RestaurantService>(context);
    final restaurantId = Provider.of<AuthService>(context).currentRestaurant?.id ?? '';
    final primaryColor = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Product>>(
        future: restaurantService.getProductsByCategory(restaurantId, 'all'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay productos registrados',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final product = snapshot.data![index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    '\$${product.price.toStringAsFixed(2)} - ${product.category}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: SizedBox(
                    width: 96,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: primaryColor),
                          tooltip: 'Editar',
                          onPressed: () => _showEditProductDialog(context, product),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          tooltip: 'Eliminar',
                          onPressed: () {
                            // Aquí implementa la eliminación si quieres
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: Text('¿Eliminar el producto "${product.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Producto "${product.name}" eliminado'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    },
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showAddProductDialog(context, restaurantId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, String restaurantId) {
    final restaurantService = Provider.of<RestaurantService>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = 'Entradas';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Entradas', 'Platos principales', 'Postres']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) => selectedCategory = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newProduct = Product(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    imageUrl: 'https://example.com/product.jpg',
                    category: selectedCategory,
                    restaurantId: restaurantId,
                  );

                  await restaurantService.addProduct(newProduct);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Producto "${newProduct.name}" agregado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    // Similar al _showAddProductDialog pero prellenando campos y actualizando producto
  }
}
