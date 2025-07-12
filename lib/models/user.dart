enum UserRole { client, worker, restaurantAdmin }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? restaurantId; // Solo para workers y restaurantAdmin

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.restaurantId,
  });
}