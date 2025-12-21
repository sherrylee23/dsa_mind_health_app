import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dsa_mind_health/MoodDatabase.dart'; // Correct merged database
import 'package:dsa_mind_health/main.dart'; // Import to access MyHomePage
import '../../admin_login.dart';
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
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // 1. Try to login with Supabase Auth
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: pass,
      );

      // 2. Get user from local SQLite database
      final user = await moodDb.getUserByEmail(email);

      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorText = 'User data not found. Please try again.';
        });
        return;
      }

      // 3. Sync user data and navigate
      await _proceedToHome(user);

    } on AuthException catch (e) {
      // Supabase Auth failed - check if it's a legacy user
      await _handleLegacyUser(email, pass, e);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Login failed. Please try again.';
      });
    }
  }

  // Handle legacy users who exist in local DB but not in Supabase Auth
  Future<void> _handleLegacyUser(String email, String pass, AuthException authError) async {
    // Check if user exists in local SQLite with matching password
    final localUser = await moodDb.getUserByEmail(email);

    if (localUser != null && localUser.password == pass) {
      // Legacy user found - create Supabase Auth account for them
      try {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: pass,
          data: {'name': localUser.name},
        );

        // Now login with the newly created account
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: pass,
        );

        // Proceed to home
        await _proceedToHome(localUser);
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorText = 'Failed to migrate account. Please try again.';
        });
      }
    } else {
      // Not a legacy user, show original error
      setState(() {
        _isLoading = false;
        _errorText = authError.message;
      });
    }
  }

  // Navigate to home after successful login
  Future<void> _proceedToHome(UserModel user) async {
    await moodDb.syncFromSupabase(user.id);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MyHomePage(
          title: 'DSA MindHealth',
          currentUserId: user.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9FB7D9),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminLoginPage(),
                ),
              );
            },
          ),
        ],
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