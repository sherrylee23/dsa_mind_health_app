import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dsa_mind_health/MoodDatabase.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final int userId;
  const UpdatePasswordScreen({super.key, required this.userId});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  // 1. Define the missing controllers
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    newPassCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final newPass = newPassCtrl.text.trim();

    try {
      // 1. Get the email of the person who clicked the link
      final sessionEmail = Supabase.instance.client.auth.currentUser?.email;

      if (sessionEmail == null) {
        setState(() => _errorText = "Session expired. Please request a new link.");
        return;
      }

      // 2. Find the local ID based on that email
      final moodDb = MoodDatabase();
      final localUser = await moodDb.getUserByEmail(sessionEmail);

      if (localUser != null) {
        // 3. Update both Supabase and Local SQLite
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: newPass),
        );

        await moodDb.updatePassword(localUser.id, newPass);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated! You can now sign in.')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() => _errorText = "Update failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Password'),
        backgroundColor: const Color(0xFF9FB7D9),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your new password below:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FB7D9),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    'SAVE NEW PASSWORD',
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