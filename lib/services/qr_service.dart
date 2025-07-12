// lib/services/qr_service.dart
import 'package:flutter/foundation.dart';

class QRService with ChangeNotifier {
  Future<String> generateQRForTable(String tableId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular generación
    return 'restaurant://table/$tableId'; // URL del QR
  }

  Future<String> processQRCode(String qrData) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular procesamiento
    
    // Extraer mesa y restaurante del QR
    final parts = qrData.split('/');
    if (parts.length >= 4 && parts[2] == 'table') {
      return parts[3]; // Devuelve el ID de la mesa
    }
    throw Exception('QR inválido');
  }
}