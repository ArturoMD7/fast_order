// lib/models/restaurant.dart
class Restaurant {
  final String id;
  final String nombre;
  final String? description;
  final String? tokenQrActual;
  final DateTime? fechaQrGenerado;
  final DateTime createdAt;
  final String? mesa; // Nuevo campo
  final String? tokenQr;

  Restaurant({
    required this.id,
    required this.nombre,
    this.description,
    this.tokenQrActual,
    this.fechaQrGenerado,
    this.mesa,
    this.tokenQr,
    required this.createdAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'].toString(),
      nombre: json['nombre'],
      description: json['descripcion'],
      tokenQrActual: json['token_qr_actual'],
      fechaQrGenerado: json['fecha_qr_generado'] != null 
          ? DateTime.parse(json['fecha_qr_generado']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      mesa: json['mesa'],
      tokenQr: json['token_qr'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': description,
      'token_qr_actual': tokenQrActual,
      'fecha_qr_generado': fechaQrGenerado?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}