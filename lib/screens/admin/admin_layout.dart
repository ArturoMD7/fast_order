import 'package:flutter/material.dart';
import '../../widgets/common/admin_navbar.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex();
  }

  @override
  void didUpdateWidget(AdminLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateCurrentIndex();
    }
  }

  void _updateCurrentIndex() {
    switch (widget.currentRoute) {
      case '/admin/home':
        setState(() => _currentIndex = 0);
        break;
      case '/admin/user-management':
        setState(() => _currentIndex = 1);
        break;
      case '/admin/product-manager':
        setState(() => _currentIndex = 2);
        break;
      case '/admin/restaurant-stats':
        setState(() => _currentIndex = 3);
        break;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/admin/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/admin/user-management');
        break;
      case 2:
        Navigator.pushNamed(context, '/admin/product-manager');
        break;
      case 3:
        Navigator.pushNamed(context, '/admin/restaurant-stats');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: AdminNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}