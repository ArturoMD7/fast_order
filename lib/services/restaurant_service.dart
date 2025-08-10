// lib/services/restaurant_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant.dart';

class RestaurantService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Restaurant>> getRestaurants() async {
    final response = await _supabase
        .from('Restaurantes')
        .select()
        .order('created_at', ascending: false);

    return response.map<Restaurant>((json) => Restaurant.fromJson(json)).toList();
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    final response = await _supabase
        .from('Restaurantes')
        .select()
        .eq('id', id)
        .single();

    return response != null ? Restaurant.fromJson(response) : null;
  }

  Future<Restaurant> createRestaurant({
    required String nombre,
    String? description,
    String? tokenQrActual,
    DateTime? fechaQrGenerado,
  }) async {
    final response = await _supabase
        .from('Restaurantes')
        .insert({
          'nombre': nombre,
          'description': description,
          'token_qr_actual': tokenQrActual,
          'fecha_qr_generado': fechaQrGenerado?.toIso8601String(),
        })
        .select()
        .single();

    return Restaurant.fromJson(response);
  }

  Future<void> updateRestaurant(Restaurant restaurant) async {
    await _supabase.from('Restaurantes').update({
      'nombre': restaurant.nombre,
      'description': restaurant.description,
      'token_qr_actual': restaurant.tokenQrActual,
      'fecha_qr_generado': restaurant.fechaQrGenerado?.toIso8601String(),
    }).eq('id', restaurant.id);
  }
}