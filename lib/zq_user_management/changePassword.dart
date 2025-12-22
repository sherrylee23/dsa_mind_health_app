import 'package:flutter/material.dart';
import 'package:dsa_mind_health/MoodDatabase.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;
  const ChangePasswordScreen({super.key, required this.userId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String? _errorText;

  Future<void> _changePassword() async {
    final oldPass = oldPassCtrl.text;
    final newPass = newPassCtrl.text;

    // 1. Verify old password locally [cite: 113, 122]
    final user = await MoodDatabase().getUserById(widget.userId);
    if (user == null || user.password != oldPass) {
      setState(() => _errorText = "Old password is incorrect");
      return;
    }

    // 2. Update local and remote [cite: 122]
    await MoodDatabase().updatePassword(widget.userId, newPass);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Old Password')),
            TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
            TextField(controller: confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
            if (_errorText != null) Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _changePassword, child: const Text('UPDATE')),
          ],
        ),
      ),
    );
  }
}