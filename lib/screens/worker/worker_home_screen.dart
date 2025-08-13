// lib/screens/worker/worker_home_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
      Future<void> _signOut(BuildContext context) async {
        try {
          await Supabase.instance.client.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio del Trabajador'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.work, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/worker/qr-generator'),
                icon: const Icon(Icons.qr_code),
                label: const Text('Generar QR para mesa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/worker/active-orders'),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Ver pedidos activos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
