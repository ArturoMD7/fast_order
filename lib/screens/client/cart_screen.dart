import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fast_order/models/order.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fast_order/services/order_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final supabase = Supabase.instance.client;
  List<OrderItem> _cartItems = [];
  bool _isLoading = true;
  String? _restaurantId;
  String? _tableId;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Obtener pedidos no confirmados del usuario actual
      final response = await supabase
          .from('Pedidos')
          .select('''
            id,
            cantidad,
            estado,
            id_producto:Productos(nombre, precio, imagen_url)
          ''')
          .eq('id_usuario', user.id)
          .eq('estado', 'sin_pedido') // Solo items no confirmados
          .order('created_at', ascending: false);

      setState(() {
        _cartItems =
            response.map<OrderItem>((item) {
              final product = item['id_producto'] as Map<String, dynamic>?;
              return OrderItem(
                productId: item['id_producto'].toString(),
                productName: product?['nombre'] ?? 'Producto desconocido',
                quantity: item['cantidad'] ?? 1,
                price: (product?['precio'] as num?)?.toDouble() ?? 0.0,
              );
            }).toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al cargar carrito: $e');
    }
  }

  Future<void> _confirmOrder() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null || _restaurantId == null) return;

      final orderService = Provider.of<OrderService>(context, listen: false);

      // Convertir items del carrito al formato esperado
      final items =
          _cartItems
              .map((item) => {'id': item.productId, 'quantity': item.quantity})
              .toList();

      // Crear el pedido en Supabase
      final orderId = await orderService.createOrderWithItems(
        restaurantId: _restaurantId!,
        items:
            _cartItems
                .map(
                  (item) => {'id': item.productId, 'quantity': item.quantity},
                )
                .toList(),
        tableId: _tableId, // Este parámetro es opcional
      );

      // Actualizar estado de los items a "pedido"
      await supabase
          .from('Pedidos')
          .update({'estado': 'pedido'})
          .eq('id_usuario', user.id)
          .eq('estado', 'sin_pedido');

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/client/order-confirmation',
          arguments: orderId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al confirmar pedido: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
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
    final total = _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Carrito'),
        backgroundColor: Colors.deepOrange,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        _cartItems.isEmpty
                            ? const Center(
                              child: Text(
                                'Tu carrito está vacío',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                            : ListView.separated(
                              itemCount: _cartItems.length,
                              padding: const EdgeInsets.all(12),
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = _cartItems[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.deepOrange.shade100,
                                        child: const Icon(
                                          Icons.fastfood,
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      title: Text(
                                        item.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Cantidad: ${item.quantity}'),
                                          Text(
                                            'Precio unitario: \$${item.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Text(
                                        '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _cartItems.isEmpty ? null : _confirmOrder,
                          child: const Text(
                            'Confirmar Pedido',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
