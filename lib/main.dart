// lib/main.dart
import 'package:fast_order/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/screens/auth/login_screen.dart';
import '/screens/auth/role_selection_screen.dart';
import '/screens/client/restaurants_screen.dart';
import '/screens/client/restaurant_detail_screen.dart';
import '/screens/client/qr_scanner_screen.dart';
import '/screens/client/menu_screen.dart';
import '/screens/client/cart_screen.dart';
import '/screens/client/order_confirmation_screen.dart';
import '/screens/client/order_status_screen.dart';
import '/screens/worker/worker_home_screen.dart';
import '/screens/worker/worker_qr_generator_screen.dart';
import '/screens/worker/active_orders_screen.dart';
import '/screens/worker/order_detail_screen.dart';
import '/screens/admin/admin_home_screen.dart';
import '/screens/admin/product_manager_screen.dart';
import '/screens/admin/restaurant_stats_screen.dart';
import '/screens/admin/user_management_screen.dart';

// En lib/main.dart
import 'package:fast_order/services/auth_service.dart';
import 'package:fast_order/services/restaurant_service.dart';
import 'package:fast_order/services/order_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => RestaurantService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        // Cliente
        '/client/restaurants': (context) => const RestaurantsScreen(),
        '/client/restaurant-detail': (context) => const RestaurantDetailScreen(),
        '/client/qr-scanner': (context) => const QRScannerScreen(),
        '/client/menu': (context) => const MenuScreen(),
        '/client/cart': (context) => const CartScreen(),
        '/client/order-confirmation': (context) => const OrderConfirmationScreen(),
        '/client/order-status': (context) => const OrderStatusScreen(),
        // Trabajador
        '/worker/home': (context) => const WorkerHomeScreen(),
        '/worker/qr-generator': (context) => const WorkerQRGeneratorScreen(),
        '/worker/active-orders': (context) => const ActiveOrdersScreen(),
        '/worker/order-detail': (context) => const OrderDetailScreen(),
        // Admin
        '/admin/home': (context) => const AdminHomeScreen(),
        '/admin/product-manager': (context) => const ProductManagerScreen(),
        '/admin/restaurant-stats': (context) => const RestaurantStatsScreen(),
        '/admin/user-management': (context) => const UserManagementScreen(),
      },
    );
  }
}