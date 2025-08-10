import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';

class ProductManagerScreen extends StatefulWidget {
  const ProductManagerScreen({super.key});

  @override
  State<ProductManagerScreen> createState() => _ProductManagerScreenState();
}

class _ProductManagerScreenState extends State<ProductManagerScreen> {
  late Future<List<Product>> _productsFuture;
  late Future<List<Category>> _categoriesFuture;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final categoryService = Provider.of<CategoryService>(context, listen: false);
    final productService = Provider.of<ProductService>(context, listen: false);
    final restaurantId = authService.currentRestaurant?.id ?? '';

    _categoriesFuture = categoryService.getCategories(restaurantId: restaurantId);
    _refreshProducts(productService, restaurantId);
  }

  void _refreshProducts(ProductService service, String restaurantId) {
    setState(() {
      _productsFuture = _selectedCategoryId != null && _selectedCategoryId != 'all'
          ? service.getProductsByCategory(_selectedCategoryId!)
          : service.getAllProductsByRestaurant(restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple;
    final authService = Provider.of<AuthService>(context);
    final restaurantId = authService.currentRestaurant?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(context, restaurantId),
          Expanded(
            child: _buildProductList(primaryColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showAddProductDialog(context, restaurantId),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, String restaurantId) {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final categories = snapshot.data!;
        final options = [
          const DropdownMenuItem(value: 'all', child: Text('Todas las categorías')),
          ...categories.map((category) => DropdownMenuItem(
                value: category.id,
                child: Text(category.nombre),
              ))
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<String>(
            value: _selectedCategoryId ?? 'all',
            decoration: InputDecoration(
              labelText: 'Filtrar por categoría',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: options,
            onChanged: (value) {
              _selectedCategoryId = value;
              final service = Provider.of<ProductService>(context, listen: false);
              _refreshProducts(service, restaurantId);
            },
          ),
        );
      },
    );
  }

  Widget _buildProductList(Color primaryColor) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
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
            return _buildProductCard(product, primaryColor, context);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product, Color primaryColor, BuildContext context) {
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
            product.imagenUrl ?? '',
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
          product.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '\$${product.precio.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey[700]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: primaryColor),
              onPressed: () => _showEditProductDialog(context, product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _confirmDeleteProduct(context, product),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar el producto "${product.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final service = Provider.of<ProductService>(context, listen: false);
                await service.deleteProduct(product.id);
                _loadData(); // Recargar datos
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto "${product.nombre}" eliminado'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, String restaurantId) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedCategoryId;

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Category>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final categories = snapshot.data ?? [];
            
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
                        validator: (value) {
                          if (value!.isEmpty) return 'Requerido';
                          if (double.tryParse(value) == null) return 'Número inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: categories.isNotEmpty ? categories.first.id : null,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map((category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.nombre),
                                ))
                            .toList(),
                        onChanged: (value) => selectedCategoryId = value,
                        validator: (value) => value == null ? 'Seleccione una categoría' : null,
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
                    if (formKey.currentState!.validate() && selectedCategoryId != null) {
                      try {
                        final service = Provider.of<ProductService>(context, listen: false);
                        final newProduct = Product(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          nombre: nameController.text,
                          description: descriptionController.text,
                          precio: double.parse(priceController.text),
                          imagenUrl: '', // Implementa subida de imagen si es necesario
                          idCategoria: selectedCategoryId!,
                          idRestaurante: restaurantId,
                          createdAt: DateTime.now(),
                        );

                        Navigator.pop(context);
                        _loadData(); // Recargar datos
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Producto "${newProduct.nombre}" agregado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al agregar: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product.nombre);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.precio.toString());
    String? selectedCategoryId = product.idCategoria;

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Category>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final categories = snapshot.data ?? [];
            
            return AlertDialog(
              title: const Text('Editar Producto'),
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
                        validator: (value) {
                          if (value!.isEmpty) return 'Requerido';
                          if (double.tryParse(value) == null) return 'Número inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map((category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.nombre),
                                ))
                            .toList(),
                        onChanged: (value) => selectedCategoryId = value,
                        validator: (value) => value == null ? 'Seleccione una categoría' : null,
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
                    if (formKey.currentState!.validate() && selectedCategoryId != null) {
                      try {
                        final service = Provider.of<ProductService>(context, listen: false);
                        final updatedProduct = product.copyWith(
                          nombre: nameController.text,
                          description: descriptionController.text,
                          precio: double.parse(priceController.text),
                          idCategoria: selectedCategoryId!,
                        );

                        await service.updateProduct(updatedProduct);
                        
                        Navigator.pop(context);
                        _loadData(); // Recargar datos
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Producto "${updatedProduct.nombre}" actualizado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Guardar Cambios'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}