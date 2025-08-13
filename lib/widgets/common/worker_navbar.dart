import 'package:flutter/material.dart';

class WorkerNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const WorkerNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.amber, // Color ámbar para ítem seleccionado
      unselectedItemColor: Colors.grey, // Color gris para ítem no seleccionado
      showSelectedLabels: true, // Mostrar texto del ítem seleccionado
      showUnselectedLabels: true, // Mostrar texto de ítems no seleccionados
      type: BottomNavigationBarType.fixed, // Evita el desplazamiento de íconos
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'Generar QR',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Pedidos',
        ),
      ],
    );
  }
}