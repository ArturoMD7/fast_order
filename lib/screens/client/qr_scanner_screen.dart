// lib/screens/client/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR'), actions: [
        IconButton(
          icon: const Icon(Icons.flash_on),
          onPressed: () => cameraController.toggleTorch(),
        ),
        IconButton(
          icon: const Icon(Icons.camera_front),
          onPressed: () => cameraController.switchCamera(),
        ),
      ]),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            // Aquí procesarías el código QR y navegarías al menú
            Navigator.pushNamed(context, '/client/menu', arguments: {
              'tableId': barcode.rawValue, // Suponiendo que el QR contiene el ID de la mesa
              'restaurantId': '123', // Esto vendría de la pantalla anterior
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}