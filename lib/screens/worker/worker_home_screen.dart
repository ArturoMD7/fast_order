import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final supabase = Supabase.instance.client;
  String _restaurantName = "Mi Restaurante";
  int _activeOrdersCount = 0;
  bool _isLoading = true;
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _loadRestaurantData();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      _greeting = hour < 12
          ? 'Buenos días'
          : hour < 18
              ? 'Buenas tardes'
              : 'Buenas noches';
    });
  }

  Future<void> _loadRestaurantData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Obtener datos del usuario
      final userData = await supabase
          .from('Usuarios')
          .select('id_restaurante')
          .eq('id', user.id)
          .maybeSingle();

      if (userData == null || userData['id_restaurante'] == null) {
        setState(() => _isLoading = false);
        return;
      }

      final restaurantId = userData['id_restaurante'] as int;

      // Obtener información del restaurante
      final restaurantResponse = await supabase
          .from('Restaurantes')
          .select('nombre')
          .eq('id', restaurantId)
          .maybeSingle();

      // Obtener conteo de pedidos activos (FORMA CORRECTA)
      final ordersResponse = await supabase
          .from('Pedidos')
          .select()
          .eq('id_restaurante', restaurantId)
          .eq('completado', false);

      setState(() {
        _restaurantName = restaurantResponse?['nombre'] ?? "Mi Restaurante";
        _activeOrdersCount = ordersResponse.length; // Usamos length directamente
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... (El resto del código build y _buildActionButton permanece igual)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_restaurantName),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_outline, size: 100, color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  Text(
                    _greeting,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¿Qué necesitas hacer hoy?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.qr_code,
                          label: 'Generar QR para mesa',
                          onPressed: () => Navigator.pushNamed(context, '/worker/qr-generator'),
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(
                          context,
                          icon: Icons.receipt_long,
                          label: 'Ver pedidos activos',
                          badgeCount: _activeOrdersCount > 0 ? _activeOrdersCount : null,
                          onPressed: () => Navigator.pushNamed(context, '/worker/active-orders'),
                        ),
                        if (_activeOrdersCount > 0) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Tienes $_activeOrdersCount pedidos pendientes',
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    int? badgeCount,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: badgeCount != null
            ? Badge(
                label: Text(badgeCount.toString()),
                backgroundColor: Colors.deepOrange,
                child: Icon(icon),
              )
            : Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
