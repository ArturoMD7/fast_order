// lib/models/category.dart
class Category {
  final String id;
  final String nombre;
  final String? idRestaurante;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.nombre,
    this.idRestaurante,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      nombre: json['nombre'],
      idRestaurante: json['id_restaurante']?.toString(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'id_restaurante': idRestaurante,
      'created_at': createdAt.toIso8601String(),
    };
  }
}