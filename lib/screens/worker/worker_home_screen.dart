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
  int _pendingOrdersCount = 0; // Pedidos con estado "pedido"
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

      // Obtener conteo de pedidos PENDIENTES (estado = "pedido")
      final ordersResponse = await supabase
          .from('Pedidos')
          .select()
          .eq('id_restaurante', restaurantId)
          .eq('estado', 'pedido'); // Filtramos por estado "pedido"

      setState(() {
        _restaurantName = restaurantResponse?['nombre'] ?? "Mi Restaurante";
        _pendingOrdersCount = ordersResponse.length;
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

  Future<void> _signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFD2691E);
    return Scaffold(
      appBar: AppBar(
        title: Text(_restaurantName),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_outline, size: 100, color: Color(0xFFD2691E)),
                  const SizedBox(height: 16),
                  Text(
                    _greeting,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.black87,
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
                          label: 'Pedidos pendientes',
                          badgeCount: _pendingOrdersCount > 0 ? _pendingOrdersCount : null,
                          onPressed: () => Navigator.pushNamed(context, '/worker/active-orders'),
                        ),
                        if (_pendingOrdersCount > 0) ...[
                          const SizedBox(height: 20),
                          Text(
                            '$_pendingOrdersCount pedidos por atender',
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                backgroundColor: Color(0xFFD2691E),
                child: Icon(icon),
              )
            : Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFD2691E),
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