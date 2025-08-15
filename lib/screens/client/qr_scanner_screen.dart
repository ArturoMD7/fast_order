import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fast_order/models/restaurant.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final supabase = Supabase.instance.client;
  final MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  bool _isValidating = false;
  BarcodeCapture? _lastCapture;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _processQRCode() async {
    if (_isProcessing || _lastCapture == null) return;
    
    final barcodes = _lastCapture!.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se detectó ningún código QR válido'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);
    await _validateAndRegisterToken(barcodes.first.rawValue!);
  }

  Future<void> _validateAndRegisterToken(String token) async {
    if (_isValidating) return;
    setState(() => _isValidating = true);

    try {
      // 1. Verificar token en tokens_qr
      final tokenData = await supabase
          .from('tokens_qr')
          .select('mesa, expira_en')
          .eq('token', token)
          .eq('activo', true)
          .gt('expira_en', DateTime.now().toIso8601String())
          .maybeSingle();

      if (tokenData == null || tokenData['id_restaurante'] == null) {
        throw Exception('Token inválido o expirado');
      }

      // 2. Obtener datos del restaurante con manejo de nulos
      final restaurantResponse = await supabase
          .from('Restaurantes')
          .select()
          .eq('id', tokenData['id_restaurante'])
          .maybeSingle();

      if (restaurantResponse == null) {
        throw Exception('Restaurante no encontrado');
      }

      // 3. Validar campos requeridos
      final restaurantData = {
        'id': restaurantResponse['id']?.toString(),
        'nombre': restaurantResponse['nombre']?.toString(),
        'descripcion': restaurantResponse['descripcion']?.toString(),
        'created_at': restaurantResponse['created_at']?.toString(),
      };

      if (restaurantData.values.any((value) => value == null)) {
        throw Exception('Datos del restaurante incompletos');
      }

      // 4. Usuario actual
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // 5. Actualizar usuario con el token QR
      final updateResponse = await supabase
          .from('Usuarios')
          .update({
            'token_qr_actual': token,
            'fecha_qr_generado': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id)
          .select();

      if (updateResponse.isEmpty) {
        throw Exception('Error al actualizar usuario');
      }

      // 6. Crear objeto Restaurant con datos validados
      final restaurant = Restaurant(
        id: restaurantData['id']!,
        nombre: restaurantData['nombre']!,
        description: restaurantData['descripcion'] ?? '',
        createdAt: DateTime.parse(restaurantData['created_at']!),
        mesa: tokenData['mesa']?.toString() ?? 'Sin mesa',
        tokenQrActual: token,
      );

      // 7. Navegar al menú
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/client/menu',
          arguments: restaurant,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
          _isValidating = false;
        });
        await cameraController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR de Mesa'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_off : Icons.flash_on,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_isProcessing && !_isValidating) {
                setState(() => _lastCapture = capture);
              }
            },
          ),
          
          // Marco de escaneo
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isValidating
                  ? const Center(child: CircularProgressIndicator())
                  : const Icon(Icons.qr_code, size: 60, color: Colors.green),
            ),
          ),
          
          // Botón de captura
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _isValidating ? null : _processQRCode,
                  backgroundColor: Colors.green,
                  child: _isProcessing || _isValidating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.camera, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  _isValidating
                      ? 'Validando código...'
                      : _lastCapture != null
                          ? 'Presiona para escanear'
                          : 'Enfoca un código QR',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}