import 'package:dsa_mind_health/MoodDatabase.dart';
import 'package:dsa_mind_health/mood.dart';
import 'package:flutter/material.dart';
import 'service/user_database.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;

  const ChangePasswordScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final userDb = MoodDatabase();

  String? _errorText;
  bool _isSaving = false;

  @override
  void dispose() {
    oldPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final oldPass = oldPassCtrl.text;
    final newPass = newPassCtrl.text;
    final confirm = confirmCtrl.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _errorText = 'Please fill all fields');
      return;
    }
    if (newPass != confirm) {
      setState(() => _errorText = 'New passwords do not match');
      return;
    }
    if (newPass.length < 8) {
    setState(() => _errorText = 'Password must be at least 8 characters');
    return;
    }

    // 1. Load user and check old password
    final user = await userDb.getUserById(widget.userId);
    if (user == null) {
    setState(() => _errorText = 'User not found');
    return;
    }
    if (user.password != oldPass) {
    setState(() => _errorText = 'Old password is incorrect');
    return;
    }

    // 2. Confirm dialog
    final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
    title: const Text('Confirm change'),
    content: const Text('Are you sure you want to change your password?'),
    actions: [
    TextButton(
    onPressed: () => Navigator.pop(context, false),
    child: const Text('Cancel'),
    ),
    TextButton(
    onPressed: () => Navigator.pop(context, true),
    child: const Text('Change'),
    ),
    ],
    ),
    );

    if (confirmed != true) return;

    setState(() {
    _isSaving = true;
    _errorText = null;
    });

    try {
    await userDb.updatePassword(widget.userId, newPass);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Password updated successfully'),
    backgroundColor: Colors.green,
    ),
    );
    Navigator.pop(context); // back to Profile
    } catch (e) {
    setState(() {
    _errorText = 'Failed to update password: $e';
    _isSaving = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: const Color(0xFF9FB7D9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Old Password:'),
            const SizedBox(height: 6),
            TextField(
              controller: oldPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('New Password:'),
            const SizedBox(height: 6),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Confirm New Password:'),
            const SizedBox(height: 6),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FB7D9),
                    padding:
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'CHANGE PASSWORD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
