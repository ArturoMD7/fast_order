import 'package:flutter/material.dart';
import '../../screens/client/client_layout.dart';
import '../../screens/worker/worker_layout.dart';
import '../../screens/admin/admin_layout.dart';

class RoleLayout extends StatelessWidget {
  final Widget child;
  final String route;
  
  const RoleLayout({
    super.key,
    required this.child,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    if (route.startsWith('/client/')) {
      return ClientLayout(
        child: child,
        currentRoute: route,
      );
    } else if (route.startsWith('/worker/')) {
      return WorkerLayout(
        child: child,
        currentRoute: route,
      );
    } else if (route.startsWith('/admin/')) {
      return AdminLayout(
        child: child,
        currentRoute: route,
      );
    }
    return Scaffold(body: child); // Para rutas sin layout específico (login, register)
  }
}