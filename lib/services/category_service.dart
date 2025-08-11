// lib/services/category_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/product.dart';

class CategoryService {
  final SupabaseClient _supabase;

  CategoryService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Obtener todas las categorías
  
  Future<List<Category>> getCategories({String? restaurantId}) async {
  final query = _supabase
      .from('categorias')
      .select()
      .maybeEq('id_restaurante', restaurantId) // 👈 nuevo helper
      .order('created_at', ascending: false);

  final response = await query;
  return (response as List)
      .map((json) => Category.fromJson(json as Map<String, dynamic>))
      .toList();
}


  /// Obtener productos por categoría
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final response = await _supabase
        .from('Productos')
        .select()
        .eq('id_categoria', categoryId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtener categorías con sus productos
  Future<Map<Category, List<Product>>> getCategoriesWithProducts({
    String? restaurantId,
  }) async {
    final categories = await getCategories(restaurantId: restaurantId);
    final result = <Category, List<Product>>{};

    for (final category in categories) {
      final products = await getProductsByCategory(category.id);
      result[category] = products;
    }

    return result;
  }
}
extension OptionalFilter on PostgrestFilterBuilder {
  PostgrestFilterBuilder maybeEq(String column, String? value) {
    if (value != null) {
      return eq(column, value);
    }
    return this;
  }
}