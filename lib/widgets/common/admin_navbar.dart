import 'package:flutter/material.dart';

class AdminNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.amber, // Color ámbar para ícono y texto seleccionado
      unselectedItemColor: Colors.grey, // Color gris para ícono y texto no seleccionado
      showSelectedLabels: true, // Asegura que el texto seleccionado se muestre
      showUnselectedLabels: true, // Asegura que el texto no seleccionado se muestre
      type: BottomNavigationBarType.fixed, // Importante para que funcione correctamente
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts),
          label: 'Usuarios',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fastfood),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Estadísticas',
        ),
      ],
    );
  }
}