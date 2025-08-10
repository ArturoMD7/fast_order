import 'package:flutter/material.dart';
import '../../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: theme.colorScheme.primary.withOpacity(0.2),
        highlightColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de imagen (removida ya que no existe en tu modelo)
            Container(
              height: 150,
              color: Colors.grey[200],
              child: Center(
                child: Icon(Icons.restaurant, size: 60, color: Colors.grey[400]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.nombre,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.description ?? 'Sin descripción',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Sección de información adicional
                  if (restaurant.tokenQrActual != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.qr_code, size: 18, color: theme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'QR disponible',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (restaurant.fechaQrGenerado != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Actualizado: ${restaurant.fechaQrGenerado!.toLocal().toString().split(' ')[0]}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}