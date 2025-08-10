import 'package:flutter/material.dart';

class ClientNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ClientNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant, color: Colors.amber,),
          label: 'Restaurantes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Escanear',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Carrito',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Pedidos',
        ),
      ],
    );
  }
}