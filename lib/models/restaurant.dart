class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String ownerId; // ID del usuario restaurantAdmin
  final double rating;
  final int deliveryTime;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ownerId,
    this.rating = 0.0,
    this.deliveryTime = 30,
  });
}