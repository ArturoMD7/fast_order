import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WorkerQRGeneratorScreen extends StatelessWidget {
  const WorkerQRGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String tableId = 'Mesa-5'; // Esto vendría de alguna selección

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de QR'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: tableId,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(height: 20),
                Text(
                  'QR para $tableId',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[700],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Escanea este código para comenzar la orden en esta mesa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
