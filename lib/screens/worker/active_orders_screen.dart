import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _activeOrders = [];
  bool _isLoading = true;
  int? _restaurantId;

  @override
  void initState() {
    super.initState();
    _loadActiveOrders();
  }

  Future<void> _loadActiveOrders() async {
    try {
      setState(() => _isLoading = true);
      _activeOrders.clear();

      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no autenticado')),
          );
        }
        return;
      }

      // Obtener solo el ID del restaurante del usuario
      final userData = await supabase
          .from('Usuarios')
          .select('id_restaurante')
          .eq('id', user.id)
          .single();

      _restaurantId = userData['id_restaurante'] as int?;
      if (_restaurantId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no asociado a restaurante')),
          );
        }
        return;
      }

      // Obtener SOLO los datos de pedidos activos
      final ordersResponse = await supabase
          .from('Pedidos')
          .select('''
            id,
            cantidad,
            estado,
            created_at,
            mesa
          ''')
          .eq('id_restaurante', _restaurantId!)
          .eq('estado', 'pedido')
          .order('created_at', ascending: true);

      setState(() {
        _activeOrders = List<Map<String, dynamic>>.from(ordersResponse);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading orders: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar pedidos: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await supabase
          .from('Pedidos')
          .update({'estado': newStatus})
          .eq('id', orderId);

      setState(() {
        _activeOrders.removeWhere((order) => order['id'] == orderId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido marcado como $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Activos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeOrders.isEmpty
              ? const Center(child: Text('No hay pedidos pendientes'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeOrders.length,
                  itemBuilder: (context, index) {
                    final order = _activeOrders[index];
                    final orderDate = DateTime.parse(order['created_at']).toLocal();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pedido #${order['id']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Mesa ${order['mesa'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hora: ${orderDate.hour}:${orderDate.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Cantidad: ${order['cantidad']}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _updateOrderStatus(order['id'], 'cancelado'),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _updateOrderStatus(order['id'], 'completado'),
                                    child: const Text('Completar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}