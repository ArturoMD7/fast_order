// lib/models/product.dart
class Product {
  final String id;
  final String nombre;
  final String? description;
  final double precio;
  final String? imagenUrl;
  final String idCategoria;
  final String idRestaurante;
  final DateTime createdAt;
  final String? categoryName;
  final bool destacado; 
  final bool activo; 

  Product({
    required this.id,
    required this.nombre,
    this.description,
    required this.precio,
    this.imagenUrl,
    required this.idCategoria,
    required this.idRestaurante,
    required this.createdAt,
    this.categoryName,
    this.destacado = false, 
    this.activo = true, 
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      nombre: json['nombre'],
      description: json['description'],
      precio: (json['precio'] as num).toDouble(),
      imagenUrl: json['imagen_url'],
      idCategoria: json['id_categoria'].toString(),
      idRestaurante: json['id_restaurante'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      categoryName: json['category_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'description': description,
      'precio': precio,
      'imagen_url': imagenUrl,
      'id_categoria': idCategoria,
      'id_restaurante': idRestaurante,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? nombre,
    String? description,
    double? precio,
    String? imagenUrl,
    String? idCategoria,
    String? idRestaurante,
    DateTime? createdAt,
    String? categoryName,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      description: description ?? this.description,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      idCategoria: idCategoria ?? this.idCategoria,
      idRestaurante: idRestaurante ?? this.idRestaurante,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}