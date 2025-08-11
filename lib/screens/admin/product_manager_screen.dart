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
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final restaurant = authService.currentRestaurant;
    
    if (restaurant == null || restaurant.id.isEmpty) {
      debugPrint('No hay restaurante asignado');
      return;
    }

    final categoryService = Provider.of<CategoryService>(context, listen: false);
    final productService = Provider.of<ProductService>(context, listen: false);
    
    _categoriesFuture = categoryService.getCategories(restaurantId: restaurant.id);
    _refreshProducts(productService, restaurant.id);
  }

  void _refreshProducts(ProductService service, String restaurantId) {
    if (restaurantId.isEmpty) return;

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

    if (restaurantId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gestión de Productos')),
        body: const Center(child: Text('No se ha asignado un restaurante')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context, restaurantId),
            tooltip: 'Agregar categoría',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar productos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadData();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  _loadData();
                } else {
                  _searchProducts(value, restaurantId);
                }
              },
            ),
          ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final categories = snapshot.data ?? [];
        final options = [
          const DropdownMenuItem(value: 'all', child: Text('Todas las categorías')),
          ...categories.map((category) => DropdownMenuItem(
                value: category.id,
                child: Text(category.nombre),
              ))
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
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
                    setState(() {
                      _selectedCategoryId = value;
                    });
                    final service = Provider.of<ProductService>(context, listen: false);
                    _refreshProducts(service, restaurantId);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  final categoryService = Provider.of<CategoryService>(context, listen: false);
                  setState(() {
                    _categoriesFuture = categoryService.getCategories(restaurantId: restaurantId);
                  });
                },
                tooltip: 'Actualizar categorías',
              ),
            ],
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${product.precio.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (product.categoryName != null)
              Text(
                product.categoryName!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
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

  void _searchProducts(String query, String restaurantId) {
    if (query.isEmpty) {
      _loadData();
      return;
    }

    final productService = Provider.of<ProductService>(context, listen: false);
    setState(() {
      _productsFuture = productService.searchProducts(restaurantId, query);
    });
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
                _loadData();
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

  void _showAddCategoryDialog(BuildContext context, String restaurantId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nueva Categoría'),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la categoría',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_categoryController.text.isNotEmpty) {
                  try {
                    final service = Provider.of<CategoryService>(context, listen: false);
                    await service.createCategory(_categoryController.text, restaurantId);
                    
                    _categoryController.clear();
                    Navigator.pop(context);
                    
                    setState(() {
                      _categoriesFuture = service.getCategories(restaurantId: restaurantId);
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Categoría creada exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al crear categoría: $e'),
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
            
            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('No se pudieron cargar las categorías: ${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            }
            
            final categories = snapshot.data ?? [];
            
            if (categories.isEmpty) {
              return AlertDialog(
                title: const Text('No hay categorías'),
                content: const Text('Debes crear al menos una categoría antes de agregar productos.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddCategoryDialog(context, restaurantId);
                      // After the category dialog closes, reopen the add product dialog
                      // This can be improved with async/await if _showAddCategoryDialog returns Future
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _showAddProductDialog(context, restaurantId);
                      });
                    },
                    child: const Text('Crear Categoría'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              );
            }
            
            selectedCategoryId ??= categories.first.id;
            
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
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddCategoryDialog(context, restaurantId);
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _showAddProductDialog(context, restaurantId);
                          });
                        },
                        child: const Text('+ Agregar nueva categoría'),
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
                          imagenUrl: '',
                          idCategoria: selectedCategoryId!,
                          idRestaurante: restaurantId,
                          createdAt: DateTime.now(),
                        );

                        await service.createProduct(newProduct);
                        
                        Navigator.pop(context);
                        _loadData();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Producto "${newProduct.nombre}" agregado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al agregar producto: $e'),
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
            
            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('No se pudieron cargar las categorías: ${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
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
                        _loadData();
                        
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