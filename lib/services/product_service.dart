// lib/services/product_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  final SupabaseClient _supabase;

  ProductService({SupabaseClient? supabase}) 
    : _supabase = supabase ?? Supabase.instance.client;

  /// Obtiene todos los productos de un restaurante específico con información de categoría
  Future<List<Product>> getAllProductsByRestaurant(String restaurantId) async {
    try {
      _validateRestaurantId(restaurantId);
      
      final response = await _supabase
        .from('Productos')
        .select('''
          *,
          categorias: id_categoria (
            nombre
          )
        ''')
        .eq('id_restaurante', restaurantId)
        .order('created_at', ascending: false);

      return _parseProductList(response);
    } on PostgrestException catch (e) {
      throw Exception('Error de base de datos al obtener productos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener productos: $e');
    }
  }

  /// Obtiene productos filtrados por categoría
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      _validateCategoryId(categoryId);
      
      final response = await _supabase
        .from('Productos')
        .select('''
          *,
          categorias: id_categoria (nombre)
        ''')
        .eq('id_categoria', categoryId)
        .order('nombre', ascending: true);

      return _parseProductList(response);
    } on PostgrestException catch (e) {
      throw Exception('Error de base de datos al obtener productos por categoría: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener productos por categoría: $e');
    }
  }

  /// Crea un nuevo producto en la base de datos
  Future<Product> createProduct(Product product) async {
    try {
      _validateProductData(product);
      
      final response = await _supabase
        .from('Productos')
        .insert({
          'nombre': product.nombre,
          'description': product.description ?? '',
          'precio': product.precio,
          'imagen_url': product.imagenUrl ?? '',
          'id_categoria': product.idCategoria,
          'id_restaurante': product.idRestaurante,
          'destacado': product.destacado ?? false,
          'activo': product.activo ?? true,
        })
        .select('''
          *,
          categorias: id_categoria (nombre)
        ''')
        .single();

      return _parseProduct(response);
    } on PostgrestException catch (e) {
      throw Exception('Error de base de datos al crear producto: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear producto: $e');
    }
  }

  /// Actualiza un producto existente
  Future<Product> updateProduct(Product product) async {
    try {
      _validateProductId(product.id);
      _validateProductData(product);
      
      final response = await _supabase
        .from('Productos')
        .update({
          'nombre': product.nombre,
          'description': product.description ?? '',
          'precio': product.precio,
          'imagen_url': product.imagenUrl ?? '',
          'id_categoria': product.idCategoria,
          'destacado': product.destacado ?? false,
          'activo': product.activo ?? true,
        })
        .eq('id', product.id)
        .select('''
          *,
          categorias: id_categoria (nombre)
        ''')
        .single();

      return _parseProduct(response);
    } on PostgrestException catch (e) {
      throw Exception('Error de base de datos al actualizar producto: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar producto: $e');
    }
  }

  /// Elimina un producto de la base de datos
  Future<void> deleteProduct(String productId) async {
    try {
      _validateProductId(productId);
      
      await _supabase
        .from('Productos')
        .delete()
        .eq('id', productId);
    } on PostgrestException catch (e) {
      throw Exception('Error de base de datos al eliminar producto: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar producto: $e');
    }
  }

  /// Busca productos por nombre dentro de un restaurante
  Future<List<Product>> searchProducts(String restaurantId, String query) async {
    try {
      _validateRestaurantId(restaurantId);
      if (query.isEmpty) throw ArgumentError('El término de búsqueda no puede estar vacío');
      
      final response = await _supabase
        .from('Productos')
        .select('''
          *,
          categorias: id_categoria (nombre)
        ''')
        .eq('id_restaurante', restaurantId)
        .ilike('nombre', '%$query%')
        .order('nombre', ascending: true);

      return _parseProductList(response);
    } on PostgrestException catch (e) {
      throw Exception('Error de base de datos al buscar productos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al buscar productos: $e');
    }
  }

  /// Obtiene productos destacados de un restaurante
  Future<List<Product>> getFeaturedProducts(String restaurantId) async {
    try {
      _validateRestaurantId(restaurantId);
      
      final response = await _supabase
        .from('Productos')
        .select('''
          *,
          categorias: id_categoria (nombre)
        ''')
        .eq('id_restaurante', restaurantId)
        .eq('destacado', true)
        .eq('activo', true)
        .order('created_at', ascending: false)
        .limit(10);

      return _parseProductList(response);
    } on PostgrestException catch (e) {
      throw Exception('Error de base de datos al obtener productos destacados: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener productos destacados: $e');
    }
  }

  // Métodos auxiliares privados

  List<Product> _parseProductList(List<dynamic> response) {
    return response.map<Product>((json) {
      final categoryJson = json['categorias'] as Map<String, dynamic>?;
      final categoryName = categoryJson?['nombre'] as String? ?? 'Sin categoría';
      
      return Product.fromJson(json).copyWith(
        categoryName: categoryName,
      );
    }).toList();
  }

  Product _parseProduct(Map<String, dynamic> response) {
    final categoryJson = response['categorias'] as Map<String, dynamic>?;
    final categoryName = categoryJson?['nombre'] as String? ?? 'Sin categoría';
    
    return Product.fromJson(response).copyWith(
      categoryName: categoryName,
    );
  }

  void _validateRestaurantId(String restaurantId) {
    if (restaurantId.isEmpty) {
      throw ArgumentError('El ID del restaurante no puede estar vacío');
    }
    if (int.tryParse(restaurantId) == null) {
      throw ArgumentError('El ID del restaurante debe ser un número válido');
    }
  }

  void _validateCategoryId(String categoryId) {
    if (categoryId.isEmpty) {
      throw ArgumentError('El ID de categoría no puede estar vacío');
    }
    if (int.tryParse(categoryId) == null) {
      throw ArgumentError('El ID de categoría debe ser un número válido');
    }
  }

  void _validateProductId(String productId) {
    if (productId.isEmpty) {
      throw ArgumentError('El ID del producto no puede estar vacío');
    }
  }

  void _validateProductData(Product product) {
    if (product.nombre.isEmpty) {
      throw ArgumentError('El nombre del producto no puede estar vacío');
    }
    if (product.precio <= 0) {
      throw ArgumentError('El precio debe ser mayor que cero');
    }
    if (product.idCategoria.isEmpty) {
      throw ArgumentError('Debe seleccionar una categoría para el producto');
    }
    if (product.idRestaurante.isEmpty) {
      throw ArgumentError('El ID del restaurante no puede estar vacío');
    }
  }
}