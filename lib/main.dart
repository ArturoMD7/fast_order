// lib/main.dart
import 'package:fast_order/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

import 'package:fast_order/services/auth_service.dart';
import 'package:fast_order/services/restaurant_service.dart';
import 'package:fast_order/services/order_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fast_order/widgets/common/role_layout.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  late final url = dotenv.env['SUPABASE_URL'];
  late final key = dotenv.env['SUPABASE_KEY'];
  await Supabase.initialize(
    url: url!,
    anonKey: key!,
  );
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
      debugShowCheckedModeBanner: false,
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
        '/client/restaurants': (context) => RoleLayout(
              route: '/client/restaurants',
              child: const RestaurantsScreen(),
            ),
        '/client/restaurant-detail': (context) => RoleLayout(
              route: '/client/restaurant-detail',
              child: const RestaurantDetailScreen(),
            ),
        '/client/qr-scanner': (context) => RoleLayout(
              route: '/client/qr-scanner',
              child: const QRScannerScreen(),
            ),
        '/client/menu': (context) => RoleLayout(
              route: '/client/menu',
              child: const MenuScreen(),
            ),
        '/client/cart': (context) => RoleLayout(
              route: '/client/cart',
              child: const CartScreen(),
            ),
        '/client/order-confirmation': (context) => RoleLayout(
              route: '/client/order-confirmation',
              child: const OrderConfirmationScreen(),
            ),
        '/client/order-status': (context) => RoleLayout(
              route: '/client/order-status',
              child: const OrderStatusScreen(),
            ),
        // Trabajador
        '/worker/home': (context) => RoleLayout(
              route: '/worker/home',
              child: const WorkerHomeScreen(),
            ),
        '/worker/qr-generator': (context) => RoleLayout(
              route: '/worker/qr-generator',
              child: const WorkerQRGeneratorScreen(),
            ),
        '/worker/active-orders': (context) => RoleLayout(
              route: '/worker/active-orders',
              child: const ActiveOrdersScreen(),
            ),
        '/worker/order-detail': (context) => RoleLayout(
              route: '/worker/order-detail',
              child: const OrderDetailScreen(),
            ),
        // Admin
        '/admin/home': (context) => RoleLayout(
              route: '/admin/home',
              child: const AdminHomeScreen(),
            ),
        '/admin/product-manager': (context) => RoleLayout(
              route: '/admin/product-manager',
              child: const ProductManagerScreen(),
            ),
        '/admin/restaurant-stats': (context) => RoleLayout(
              route: '/admin/restaurant-stats',
              child: const RestaurantStatsScreen(),
            ),
        '/admin/user-management': (context) => RoleLayout(
              route: '/admin/user-management',
              child: const UserManagementScreen(),
            ),
      },
    );
  }
}