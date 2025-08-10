// lib/services/product_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  final SupabaseClient _supabase;

  ProductService({SupabaseClient? supabase}) 
    : _supabase = supabase ?? Supabase.instance.client;

  // Obtener TODOS los productos de un restaurante específico
  Future<List<Product>> getAllProductsByRestaurant(String restaurantId) async {
    try {
      final response = await _supabase
        .from('productos')
        .select('''
          *,
          categorias: id_categoria (nombre)
        ''')
        .eq('id_restaurante', restaurantId)
        .order('created_at', ascending: false);

      return response.map<Product>((json) {
        final categoryJson = json['categorias'] as Map<String, dynamic>?;
        final categoryName = categoryJson?['nombre'] as String? ?? 'Sin categoría';
        
        return Product.fromJson(json).copyWith(
          categoryName: categoryName,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener productos del restaurante: $e');
    }
  }

  // Obtener productos por categoría específica
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _supabase
        .from('productos')
        .select()
        .eq('id_categoria', categoryId)
        .order('nombre', ascending: true);

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }

  // Crear un nuevo producto
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _supabase
        .from('productos')
        .insert({
          'nombre': product.nombre,
          'description': product.description,
          'precio': product.precio,
          'imagen_url': product.imagenUrl,
          'id_categoria': product.idCategoria,
          'id_restaurante': product.idRestaurante,
        })
        .select()
        .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  // Actualizar un producto existente
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _supabase
        .from('productos')
        .update({
          'nombre': product.nombre,
          'description': product.description,
          'precio': product.precio,
          'imagen_url': product.imagenUrl,
          'id_categoria': product.idCategoria,
        })
        .eq('id', product.id)
        .select()
        .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  // Eliminar un producto
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase
        .from('productos')
        .delete()
        .eq('id', productId);
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  // Buscar productos por nombre en un restaurante
  Future<List<Product>> searchProducts(String restaurantId, String query) async {
    try {
      final response = await _supabase
        .from('productos')
        .select()
        .eq('id_restaurante', restaurantId)
        .ilike('nombre', '%$query%')
        .order('nombre', ascending: true);

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar productos: $e');
    }
  }

  // Obtener productos destacados (ejemplo adicional)
  Future<List<Product>> getFeaturedProducts(String restaurantId) async {
    try {
      final response = await _supabase
        .from('productos')
        .select()
        .eq('id_restaurante', restaurantId)
        .eq('destacado', true)
        .order('created_at', ascending: false)
        .limit(10);

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener productos destacados: $e');
    }
  }
}