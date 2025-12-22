import 'dart:async'; // Required for StreamSubscription
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dsa_mind_health/MoodDatabase.dart';
import 'package:dsa_mind_health/main.dart';
import 'package:dsa_mind_health/zq_user_management/update_password_screen.dart'; // Ensure this is imported
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
  final moodDb = MoodDatabase();

  // Auth listener subscription
  late final StreamSubscription<AuthState> _authSubscription;

  String? _errorText;
  bool _deleteMessageShown = false;

  @override
  void initState() {
    super.initState();

    // Catch the password recovery event globally at the login gate
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      log('Auth Event in LoginScreen: $event');

      if (event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          // When the recovery link is clicked, navigate to the UPDATE screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UpdatePasswordScreen(
                userId: 0, // We will handle finding the correct ID inside the screen using the session email
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel(); // Stop listening when leaving the page
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
      final user = await moodDb.getUserByEmail(email);

      if (user != null && user.password == pass) {
        await moodDb.syncFromSupabase(user.id);
        if (!mounted) return;

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
        setState(() => _errorText = 'Invalid email or password');
      }
    } catch (e) {
      setState(() => _errorText = 'Login failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... rest of your build method remains the same
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9FB7D9),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginPage())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Center(child: Text('Welcome!\nPlease enter your detail !', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 32),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                child: const Text('Forgot password?'),
              ),
            ),
            if (_errorText != null) Text(_errorText!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: const Text('SIGN IN')),
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Don\'t have an account? Sign up')),
          ],
        ),
      ),
    );
  }
}