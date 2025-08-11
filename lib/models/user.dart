enum UserRole {
  client('client'),
  worker('worker'),
  restaurantAdmin('restaurantAdmin');

  final String value;
  const UserRole(this.value);

  factory UserRole.fromString(String value) {
    return switch (value) {
      'client' => UserRole.client,
      'worker' => UserRole.worker,
      'restaurant_admin' => UserRole.restaurantAdmin,
      'administrador' => UserRole.restaurantAdmin,
      _ => throw ArgumentError('Unknown UserRole value: $value'),
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? restaurantId; // Solo para workers y restaurantAdmin
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.restaurantId,
    required this.createdAt,
  });

  // Constructor desde JSON (para datos de Supabase)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['nombre'] as String, // Asume que en DB es 'nombre'
      email: json['email'] as String,
      role: UserRole.fromString(json['rol'] as String), // 'rol' en DB
      restaurantId: json['id_restaurante'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'email': email,
      'rol': role.value,
      'id_restaurante': restaurantId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Método copyWith para actualizaciones inmutables
  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? restaurantId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      restaurantId: restaurantId ?? this.restaurantId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper para verificar roles
  bool get isClient => role == UserRole.client;
  bool get isWorker => role == UserRole.worker;
  bool get isRestaurantAdmin => role == UserRole.restaurantAdmin;

  // Helper para UI
  String get roleDisplayName {
    return switch (role) {
      UserRole.client => 'Cliente',
      UserRole.worker => 'Trabajador',
      UserRole.restaurantAdmin => 'Administrador',
    };
  }
}