import 'package:flutter/material.dart';
import '../../widgets/common/client_navbar.dart';

class ClientLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const ClientLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<ClientLayout> createState() => _ClientLayoutState();
}

class _ClientLayoutState extends State<ClientLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex();
  }

  @override
  void didUpdateWidget(ClientLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateCurrentIndex();
    }
  }

  void _updateCurrentIndex() {
    switch (widget.currentRoute) {
      case '/client/restaurants':
      case '/client/restaurant-detail':
      case '/client/menu':
        setState(() => _currentIndex = 0);
        break;
      case '/client/qr-scanner':
        setState(() => _currentIndex = 1);
        break;
      case '/client/cart':
      case '/client/order-confirmation':
        setState(() => _currentIndex = 2);
        break;
      case '/client/order-status':
        setState(() => _currentIndex = 3);
        break;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/client/restaurants');
        break;
      case 1:
        Navigator.pushNamed(context, '/client/qr-scanner');
        break;
      case 2:
        Navigator.pushNamed(context, '/client/cart');
        break;
      case 3:
        Navigator.pushNamed(context, '/client/order-status');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: ClientNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}