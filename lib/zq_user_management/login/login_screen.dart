import 'package:flutter/material.dart';
import '../service/user_database.dart';  // Database service
import '../models/user_model.dart';     // User model
import 'register_screen.dart';
import 'forgot_password.dart';
import '../profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final userDb = UserDatabaseService();  // Database instance
  String? _errorText;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {  // Now ASYNC for database
    final email = emailCtrl.text.trim();
    final pass = passwordCtrl.text;

    // Basic validation
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorText = 'Please enter email and password');
      return;
    }

    try {
      // Check real database
      final user = await userDb.getUserByEmail(email);

      if (user != null && user.password == pass) {
        // LOGIN SUCCESS → use REAL user ID from database
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: user.id),
          ),
        );
      } else {
        setState(() {
          _errorText = 'Invalid email or password';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'Login failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9FB7D9),
        title: const Text(''),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Welcome!\nPlease enter your detail !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Email:'),
            const SizedBox(height: 6),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Password:'),
            const SizedBox(height: 6),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text('Forgot password?'),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 4),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: _login,  // Now calls database login
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FB7D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
