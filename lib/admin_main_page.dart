import 'package:flutter/material.dart';
import 'admin_result.dart';
import 'admin_login.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginPage()), //need to change
              );
            },
          )
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.list),
          label: const Text('View Quiz Results'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminResult()),
            );
          },
        ),
      ),
    );
  }
}
