// lib/screens/worker/worker_home_screen.dart
import 'package:flutter/material.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio Trabajador')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/worker/qr-generator'),
              child: const Text('Generar QR para mesa'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/worker/active-orders'),
              child: const Text('Ver pedidos activos'),
            ),
          ],
        ),
      ),
    );
  }
}