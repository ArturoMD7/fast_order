import 'package:flutter/material.dart';
import '../utils/theme.dart';

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

    final primaryColor = const Color(0xFFD2691E);
    final secondaryColor = const Color(0xFFF4A460);
    final backgroundColor = const Color(0xFFFFF8F0);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: primaryColor , // Color ámbar para ícono y texto seleccionado
      unselectedItemColor: Colors.grey, // Color gris para ícono y texto no seleccionado
      showSelectedLabels: true, // Mostrar texto del ítem seleccionado
      showUnselectedLabels: true, // Mostrar texto de ítems no seleccionados
      type: BottomNavigationBarType.fixed, // Evita que se muevan los íconos
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
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