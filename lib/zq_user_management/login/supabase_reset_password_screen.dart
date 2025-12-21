import 'package:dsa_mind_health/MoodDatabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class SupabaseResetPasswordScreen extends StatefulWidget {
  const SupabaseResetPasswordScreen({super.key});

  @override
  State<SupabaseResetPasswordScreen> createState() => _SupabaseResetPasswordScreenState();
}

class _SupabaseResetPasswordScreenState extends State<SupabaseResetPasswordScreen> {
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final moodDb = MoodDatabase();
  String? _errorText;
  bool _isLoading = false;

  @override
  void dispose() {
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
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

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // update Supabase Auth password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: pass),
      );

      // update local SQLite password (find user by email)
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser?.email != null) {
        final localUser = await moodDb.getUserByEmail(authUser!.email!);
        if (localUser != null) {
          await moodDb.updatePassword(localUser.id, pass);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successful! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      // back to login screen
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Failed to reset password: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9FB7D9),
        title: const Text('Reset Password'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create your new password:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text('New Password:'),
            const SizedBox(height: 6),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter new password',
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
                hintText: 'Confirm new password',
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FB7D9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'RESET PASSWORD',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
