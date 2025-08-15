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
    if (user == null) {
      debugPrint('Usuario no autenticado');
      return;
    }

    debugPrint('Cargando carrito para usuario: ${user.id}');

    final response = await supabase
        .from('Pedidos')
        .select('''
          id,
          cantidad,
          estado,
          id_producto:Productos(id, nombre, precio, imagen_url, id_restaurante)
        ''')
        .eq('id_usuario', user.id)
        .eq('estado', 'sin_pedido')
        .order('created_at', ascending: false);

    debugPrint('Respuesta de Supabase: ${response.toString()}');

    if (response.isEmpty) {
      debugPrint('No hay items en el carrito');
    }

    setState(() {
      _cartItems = response.map<OrderItem>((item) {
        debugPrint('Procesando item: ${item.toString()}');
        final product = item['id_producto'] as Map<String, dynamic>?;
        
        if (product == null) {
          debugPrint('Producto no encontrado para item: ${item['id']}');
        }

        return OrderItem(
          productId: product?['id']?.toString() ?? '0', 
          productName: product?['nombre']?.toString() ?? 'Producto desconocido',
          quantity: (item['cantidad'] as num?)?.toInt() ?? 1,
          price: (product?['precio'] as num?)?.toDouble() ?? 0.0,
          imageUrl: product?['imagen_url']?.toString(),
          restaurantId: product?['id_restaurante']?.toString(),
          orderItemId: item['id']?.toString() ?? '0', 
        );
      }).toList();

      if (_cartItems.isNotEmpty) {
        _restaurantId = _cartItems.first.restaurantId;
        debugPrint('Restaurante ID: $_restaurantId');
      }

      _isLoading = false;
    });
  } catch (e) {
    debugPrint('Error al cargar carrito: $e');
    setState(() => _isLoading = false);
  }
}

  Future<void> _updateItemQuantity(String orderItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await _removeItem(orderItemId);
        return;
      }

      await supabase
          .from('Pedidos')
          .update({'cantidad': newQuantity})
          .eq('id', orderItemId);

      await _loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar cantidad: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeItem(String orderItemId) async {
    try {
      await supabase.from('Pedidos').delete().eq('id', orderItemId);
      await _loadCartItems();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado del carrito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar producto: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmOrder() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null || _restaurantId == null) return;

      final orderService = Provider.of<OrderService>(context, listen: false);

      // Crear el pedido principal
      final orderId = await orderService.createOrder(
        restaurantId: _restaurantId!,
        tableId: _tableId, productId: "productId",
        quantity: 1, 
      );

      // Actualizar estado de los items a "pedido" y asignar el orderId
      await supabase
          .from('Pedidos')
          .update({
            'estado': 'pedido',
            'id_orden': orderId,
          })
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFD2691E);
    final total = _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Carrito'),
        backgroundColor: primaryColor,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Tu carrito está vacío',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _cartItems.length,
                          padding: const EdgeInsets.all(12),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Imagen del producto
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey.shade200,
                                      ),
                                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                item.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Icon(
                                                  Icons.fastfood,
                                                  color: primaryColor,
                                                  size: 40,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.fastfood,
                                              color: primaryColor,
                                              size: 40,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // Información del producto
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${item.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Controles de cantidad
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () => _updateItemQuantity(
                                            item.orderItemId!,
                                            item.quantity - 1,
                                          ),
                                        ),
                                        Text(item.quantity.toString()),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => _updateItemQuantity(
                                            item.orderItemId!,
                                            item.quantity + 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Botón para eliminar
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeItem(item.orderItemId!),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Total y botón de confirmación
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
                          backgroundColor: primaryColor,
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