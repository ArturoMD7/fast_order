import 'package:flutter/material.dart';
import '../../widgets/common/worker_navbar.dart';

class WorkerLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const WorkerLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<WorkerLayout> createState() => _WorkerLayoutState();
}

class _WorkerLayoutState extends State<WorkerLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex();
  }

  @override
  void didUpdateWidget(WorkerLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateCurrentIndex();
    }
  }

  void _updateCurrentIndex() {
    switch (widget.currentRoute) {
      case '/worker/home':
        setState(() => _currentIndex = 0);
        break;
      case '/worker/qr-generator':
        setState(() => _currentIndex = 1);
        break;
      case '/worker/active-orders':
      case '/worker/order-detail':
        setState(() => _currentIndex = 2);
        break;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/worker/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/worker/qr-generator');
        break;
      case 2:
        Navigator.pushNamed(context, '/worker/active-orders');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: WorkerNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}