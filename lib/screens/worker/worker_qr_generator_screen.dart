import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class WorkerQRGeneratorScreen extends StatefulWidget {
  const WorkerQRGeneratorScreen({super.key});

  @override
  State<WorkerQRGeneratorScreen> createState() => _WorkerQRGeneratorScreenState();
}

class _WorkerQRGeneratorScreenState extends State<WorkerQRGeneratorScreen> {
  final supabase = Supabase.instance.client;
  late String _tableId = 'Mesa-1'; // Valor inicial
  String? _generatedToken;
  DateTime? _tokenExpiration;
  bool _isGenerating = false;
  final _tableIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tableIdController.text = _tableId;
    _generateNewToken();
  }

  @override
  void dispose() {
    _tableIdController.dispose();
    super.dispose();
  }

  Future<void> _generateNewToken() async {
    setState(() => _isGenerating = true);
    
    try {
      // Generar un token único con timestamp y mesa
      final newToken = '${DateTime.now().millisecondsSinceEpoch}-${_tableId.replaceAll(' ', '-')}';
      final expirationTime = DateTime.now().add(const Duration(hours: 1));

      // Guardar en Supabase (opcional)
      await supabase.from('tokens_qr').insert({
        'token': newToken,
        'mesa': _tableId,
        'expira_en': expirationTime.toIso8601String(),
        'activo': true,
      });

      setState(() {
        _generatedToken = newToken;
        _tokenExpiration = expirationTime;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar token: ${e.toString()}')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _copyToClipboard() async {
  if (_generatedToken == null) return;
  
  await Clipboard.setData(ClipboardData(text: _generatedToken!));
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token copiado al portapeles')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de QR'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isGenerating ? null : _generateNewToken,
            tooltip: 'Generar nuevo token',
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
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
                // Selector de mesa
                TextField(
                  controller: _tableIdController,
                  decoration: InputDecoration(
                    labelText: 'Número de Mesa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        setState(() => _tableId = _tableIdController.text);
                        _generateNewToken();
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() => _tableId = value);
                    _generateNewToken();
                  },
                ),
                const SizedBox(height: 24),
                
                // QR Code
                if (_generatedToken != null) ...[
                  GestureDetector(
                    onLongPress: _copyToClipboard,
                    child: QrImageView(
                      data: _generatedToken!,
                      version: QrVersions.auto,
                      size: 200.0,
                      embeddedImage: const AssetImage('assets/restaurant_logo.png'),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: const Size(40, 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mesa: $_tableId',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Token: ${_generatedToken!.substring(0, 8)}...',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expira: ${_tokenExpiration?.toLocal().toString().substring(0, 16) ?? ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Escanea este código para comenzar una orden en esta mesa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copiar Token'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateNewToken,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(_isGenerating ? 'Generando...' : 'Regenerar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[800],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ] else if (_isGenerating) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text('Generando token...'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}