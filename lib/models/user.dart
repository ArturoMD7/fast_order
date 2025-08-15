enum UserRole {
  client('cliente'),
  worker('trabajador'),
  restaurantAdmin('administrador'); // Coincide con el valor en DB

  final String value;
  const UserRole(this.value);

  factory UserRole.fromString(String value) {
    return switch (value.toLowerCase()) {
      'client' => UserRole.client,
      'cliente' => UserRole.client,
      'worker' => UserRole.worker,
      'trabajador' => UserRole.worker,
      'restaurantadmin' => UserRole.restaurantAdmin,
      'restaurant_admin' => UserRole.restaurantAdmin,
      'administrador' => UserRole.restaurantAdmin,
      _ => throw ArgumentError('Unknown UserRole value: $value'),
    };
  }
}

class User {
  final String id;
  final DateTime createdAt;
  final String name;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final String? restaurantId;
  final String? password; // Solo para uso interno, nunca debería exponerse
  final String? qrToken;
  final DateTime? qrGeneratedAt;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.restaurantId,
    this.password,
    this.qrToken,
    this.qrGeneratedAt,
  });

  // Constructor desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      name: json['nombre'] as String,
      lastName: json['apellidos'] as String? ?? '',
      email: json['email'] as String,
      phoneNumber: json['num_telefono'] as String?,
      role: UserRole.fromString(json['rol'].toString()),
      restaurantId: json['id_restaurante']?.toString(),
      password: json['contrasena'] as String?,
      qrToken: json['token_qr_actual'] as String?,
      qrGeneratedAt: json['fecha_qr_generado'] != null 
          ? DateTime.parse(json['fecha_qr_generado'].toString())
          : null,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'nombre': name,
      'apellidos': lastName,
      'email': email,
      'num_telefono': phoneNumber,
      'rol': role.value,
      'id_restaurante': restaurantId,
      'contrasena': password,
      'token_qr_actual': qrToken,
      'fecha_qr_generado': qrGeneratedAt?.toIso8601String(),
    };
  }

  // Método copyWith
  User copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? lastName,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? restaurantId,
    String? password,
    String? qrToken,
    DateTime? qrGeneratedAt,
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      restaurantId: restaurantId ?? this.restaurantId,
      password: password ?? this.password,
      qrToken: qrToken ?? this.qrToken,
      qrGeneratedAt: qrGeneratedAt ?? this.qrGeneratedAt,
    );
  }

  // Helpers para verificar roles
  bool get isClient => role == UserRole.client;
  bool get isWorker => role == UserRole.worker;
  bool get isRestaurantAdmin => role == UserRole.restaurantAdmin;


  String get roleDisplayName {
    return switch (role) {
      UserRole.client => 'Cliente',
      UserRole.worker => 'Trabajador',
      UserRole.restaurantAdmin => 'Administrador',
    };
  }

  String get fullName => '$name $lastName'.trim();

  bool get hasValidQrToken {
    if (qrToken == null || qrGeneratedAt == null) return false;
    final now = DateTime.now();
    final expiration = qrGeneratedAt!.add(const Duration(hours: 24)); // Token vale por 24 horas
    return now.isBefore(expiration);
  }
}