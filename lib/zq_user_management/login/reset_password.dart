import 'package:dsa_mind_health/MoodDatabase.dart';
import 'package:flutter/material.dart';
import '../service/user_database.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final int userId;

  const ResetPasswordScreen({super.key, required this.userId});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final userDb = MoodDatabase();
  String? _errorText;

  @override
  void dispose() {
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final pass = passCtrl.text;
    final confirm = confirmCtrl.text;

    if (pass.isEmpty || confirm.isEmpty) {
      setState(() => _errorText = 'Please fill all fields');
      return;
    }
    if (pass != confirm) {
      setState(() => _errorText = 'Passwords do not match');
      return;
    }
    if (pass.length < 8) {
    setState(() => _errorText = 'Password must be at least 8 characters');
    return;
    }

    await userDb.updatePassword(widget.userId, pass);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Password reset successful. Please login.'),
    backgroundColor: Colors.green,
    ),
    );

    // Go back to login screen
    Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: const Color(0xFF9FB7D9),
        title: const Text('Reset Password'),
    ),
      body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      const Text('New Password:'),
      const SizedBox(height: 6),
      TextField(
      controller: passCtrl,
      obscureText: true,
      decoration: const InputDecoration(
      border: OutlineInputBorder(),
      ),
      ),
      const SizedBox(height: 16),
      const Text('Confirm Password:'),
      const SizedBox(height: 6),
      TextField(
      controller: confirmCtrl,
      obscureText: true,
      decoration: const InputDecoration(
      border: OutlineInputBorder(),
      ),
      ),
      if (_errorText != null) ...[
      const SizedBox(height: 8),
      Text(_errorText!, style: const TextStyle(color: Colors.red)),
      ],
      const SizedBox(height: 24),
      Center(
      child: SizedBox(
      width: 180,
      child: ElevatedButton(
      onPressed: _reset,
      style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF9FB7D9),
      ),
      child: const Text(
      'RESET PASSWORD',
      style: TextStyle(color: Colors.white),
           ),
          ),
         ),
        ),
       ],
      ),
     ),
    );
  }
}
