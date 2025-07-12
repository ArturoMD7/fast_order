// lib/screens/worker/worker_qr_generator_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WorkerQRGeneratorScreen extends StatelessWidget {
  const WorkerQRGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String tableId = 'Mesa-5'; // Esto vendría de alguna selección
    
    return Scaffold(
      appBar: AppBar(title: const Text('Generador QR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: tableId,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            Text('QR para $tableId', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}