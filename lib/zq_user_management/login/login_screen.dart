import 'package:flutter/material.dart';
import 'package:dsa_mind_health/MoodDatabase.dart'; // Correct merged database
import 'package:dsa_mind_health/main.dart'; // Import to access MyHomePage
import '../models/user_model.dart';
import 'register_screen.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // UPDATED: Use the merged MoodDatabase class
  final moodDb = MoodDatabase();
  String? _errorText;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailCtrl.text.trim();
    final pass = passwordCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorText = 'Please enter email and password');
      return;
    }

    try {
      // 1. First, fetch the user object from the database [cite: 311]
      final user = await moodDb.getUserByEmail(email);

      // 2. Check if user exists and password is correct [cite: 312]
      if (user != null && user.password == pass) {

        // 3. Now that 'user' is defined, you can safely sync their data [cite: 17]
        await moodDb.syncFromSupabase(user.id);

        if (!mounted) return;

        // 4. Navigate to home with the confirmed user.id [cite: 313]
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyHomePage(
              title: 'DSA MindHealth',
              currentUserId: user.id,
            ),
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
        elevation: 0,
      ),
      body: SingleChildScrollView( // Added scroll for smaller screens
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text('Forgot password?'),
              ),
            ),
            if (_errorText != null)
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FB7D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
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