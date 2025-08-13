import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

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

  // Función mejorada para seleccionar y subir imagen con vista previa
  Future<String?> _pickAndUploadImage(String restaurantId, {String? oldImageUrl}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // Optimizar tamaño
      maxHeight: 1024,
      imageQuality: 85, // Comprimir para menor peso
    );
    
    if (pickedFile == null) return null;

    final file = File(pickedFile.path);
    
    // Crear nombre de archivo organizado por restaurante
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = pickedFile.name.split('.').last;
    final fileName = 'productos/$restaurantId/${timestamp}_producto.$extension';

    try {
      // Mostrar indicador de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Subiendo imagen...'),
              ],
            ),
          ),
        );
      }

      // Subir imagen
      await Supabase.instance.client.storage
          .from('imgs.restaurantes')
          .upload(fileName, file);

      // Cerrar indicador de carga
      if (mounted) Navigator.pop(context);

      // Si hay una imagen anterior, eliminarla para ahorrar espacio
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          final oldFileName = oldImageUrl.split('/').last;
          await Supabase.instance.client.storage
              .from('imgs.restaurantes')
              .remove(['productos/$restaurantId/$oldFileName']);
        } catch (e) {
          debugPrint('Error eliminando imagen anterior: $e');
        }
      }

      // Retornar URL pública
      return Supabase.instance.client.storage
          .from('imgs.restaurantes')
          .getPublicUrl(fileName);

    } catch (e) {
      // Cerrar indicador de carga si hay error
      if (mounted) Navigator.pop(context);
      
      debugPrint('Error subiendo imagen: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error subiendo imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Widget _buildImagePreview(String? imageUrl, VoidCallback onSelectImage, {bool isRequired = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Imagen del producto${isRequired ? ' *' : ''}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onSelectImage,
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: imageUrl != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 40),
                              Text('Error cargando imagen'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Toca para seleccionar imagen',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
        ),
      ),
    ],
  );
}

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
  String? selectedImageUrl;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vista previa de imagen
                        _buildImagePreview(
                          selectedImageUrl,
                          () async {
                            final imageUrl = await _pickAndUploadImage(restaurantId);
                            if (imageUrl != null) {
                              setState(() {
                                selectedImageUrl = imageUrl;
                              });
                            }
                          },
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                            hintText: 'Describe tu producto...',
                          ),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 12),
                        
                        TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Precio *',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value!.isEmpty) return 'El precio es requerido';
                            final price = double.tryParse(value);
                            if (price == null) return 'Ingresa un número válido';
                            if (price <= 0) return 'El precio debe ser mayor a 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Categoría *',
                            border: OutlineInputBorder(),
                          ),
                          items: categories
                              .map((category) => DropdownMenuItem(
                                    value: category.id,
                                    child: Text(category.nombre),
                                  ))
                              .toList(),
                          onChanged: (value) => selectedCategoryId = value,
                          validator: (value) => value == null ? 'Selecciona una categoría' : null,
                        ),
                        const SizedBox(height: 8),
                        
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddCategoryDialog(context, restaurantId);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar nueva categoría'),
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
                        // Validar que se haya seleccionado imagen
                        if (selectedImageUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Debes seleccionar una imagen para el producto'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        try {
                          final service = Provider.of<ProductService>(context, listen: false);
                          final newProduct = Product(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            nombre: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            precio: double.parse(priceController.text),
                            imagenUrl: selectedImageUrl,
                            idCategoria: selectedCategoryId!,
                            idRestaurante: restaurantId,
                            createdAt: DateTime.now(),
                          );

                          await service.createProduct(newProduct);
                          
                          Navigator.pop(context);
                          _loadData();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Producto "${newProduct.nombre}" agregado exitosamente'),
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
                    child: const Text('Guardar Producto'),
                  ),
                ],
              );
            },
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
  String? selectedImageUrl = product.imagenUrl; // Imagen actual
  bool imageChanged = false; // Flag para saber si cambió la imagen

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
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
              final authService = Provider.of<AuthService>(context, listen: false);
              final restaurantId = authService.currentRestaurant?.id ?? '';
              
              return AlertDialog(
                title: const Text('Editar Producto'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vista previa de imagen
                        _buildImagePreview(
                          selectedImageUrl,
                          () async {
                            final imageUrl = await _pickAndUploadImage(
                              restaurantId,
                              oldImageUrl: imageChanged ? null : product.imagenUrl,
                            );
                            if (imageUrl != null) {
                              setState(() {
                                selectedImageUrl = imageUrl;
                                imageChanged = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                            hintText: 'Describe tu producto...',
                          ),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 12),
                        
                        TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Precio *',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value!.isEmpty) return 'El precio es requerido';
                            final price = double.tryParse(value);
                            if (price == null) return 'Ingresa un número válido';
                            if (price <= 0) return 'El precio debe ser mayor a 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Categoría *',
                            border: OutlineInputBorder(),
                          ),
                          items: categories
                              .map((category) => DropdownMenuItem(
                                    value: category.id,
                                    child: Text(category.nombre),
                                  ))
                              .toList(),
                          onChanged: (value) => selectedCategoryId = value,
                          validator: (value) => value == null ? 'Selecciona una categoría' : null,
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
                            nombre: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            precio: double.parse(priceController.text),
                            idCategoria: selectedCategoryId!,
                            imagenUrl: selectedImageUrl, // Usar la imagen actual o la nueva
                          );

                          await service.updateProduct(updatedProduct);
                          
                          Navigator.pop(context);
                          _loadData();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Producto "${updatedProduct.nombre}" actualizado exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al actualizar producto: $e'),
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
    },
  );
}
}