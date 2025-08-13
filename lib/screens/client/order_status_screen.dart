import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/order_service.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('Pedidos')
          .select('''
            id,
            estado,
            created_at,
            id_producto:Productos(nombre, precio, imagen_url),
            cantidad
          ''')
          .eq('id_usuario', user.id)
          .eq('estado', 'pedido')
          .order('created_at', ascending: false);

      setState(() {
        _orders = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al cargar pedidos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pedidos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatOrderId(dynamic id) {
    try {
      final idStr = id.toString();
      return idStr.length > 6 ? 'Pedido #${idStr.substring(0, 6)}' : 'Pedido #$idStr';
    } catch (e) {
      return 'Pedido #---';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Estado de tus Pedidos'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(
                  child: Text(
                    'No tienes pedidos en proceso',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final product = order['id_producto'] as Map<String, dynamic>?;
                    final orderStatus = order['estado'];
                    final createdAt = DateTime.parse(order['created_at']);
                    final formattedDate =
                        '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatOrderId(order['id']),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${product?['nombre'] ?? 'Producto desconocido'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Cantidad: ${order['cantidad']}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Fecha: $formattedDate',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            _buildStatusIndicator(orderStatus),
                            const SizedBox(height: 8),
                            if (orderStatus == 'preparing')
                              const Text(
                                'Estamos preparando tu pedido...',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            if (orderStatus == 'ready')
                              const Text(
                                '¡Tu pedido está listo para recoger!',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadOrders,
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    return Column(
      children: [
        _buildStatusStep(
          title: 'Pedido Recibido',
          icon: Icons.receipt_long,
          isActive: true,
          isCompleted: true,
        ),
        _buildStatusLine(isActive: true),
        _buildStatusStep(
          title: 'En Preparación',
          icon: Icons.kitchen,
          isActive: status == 'preparing',
          isCompleted: status == 'preparing' || status == 'ready',
        ),
        _buildStatusLine(
          isActive: status == 'preparing' || status == 'ready',
        ),
        _buildStatusStep(
          title: 'Listo para Recoger',
          icon: Icons.check_circle,
          isActive: status == 'ready',
          isCompleted: status == 'ready',
        ),
      ],
    );
  }

  Widget _buildStatusStep({
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
  }) {
    final color = isCompleted
        ? Colors.green
        : isActive
            ? Colors.green.withOpacity(0.6)
            : Colors.grey[300];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 2, bottom: 2),
      width: 2,
      height: 20,
      color: isActive ? Colors.green : Colors.grey[300],
    );
  }
}