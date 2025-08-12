// lib/services/category_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryService {
  final SupabaseClient _supabase;

  CategoryService({SupabaseClient? supabase}) 
    : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Category>> getCategories({required String restaurantId}) async {
    try {
      final response = await _supabase
        .from('Categorias')
        .select('*')
        .eq('id_restaurante', restaurantId)
        .order('nombre', ascending: true);

      return response.map<Category>((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  Future<Category> createCategory(String nombre, String restaurantId) async {
    try {
      final response = await _supabase
        .from('Categorias')
        .insert({
          'nombre': nombre,
          'id_restaurante': restaurantId,
        })
        .select()
        .single();

      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear categoría: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _supabase
        .from('Categorias')
        .delete()
        .eq('id', categoryId);
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }
}