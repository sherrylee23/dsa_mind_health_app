import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dsa_mind_health/MoodDatabase.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  
  String? _errorText;
  bool _isLoading = false;
  final moodDb = MoodDatabase();
  
  int _currentStep = 0; 
  String? _userEmail;

  @override
  void dispose() {
    emailCtrl.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  // Step 1: Verify email exists
  Future<void> _verifyEmail() async {
    final email = emailCtrl.text.trim();

    if (email.isEmpty) {
      setState(() => _errorText = 'Please enter your email');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final user = await moodDb.getUserByEmail(email);
      
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorText = 'Email not found. Please check and try again.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _userEmail = email;
        _currentStep = 1;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Error: ${e.toString()}';
      });
    }
  }

  // Step 2: Send reset email
  Future<void> _sendResetEmail() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await Supabase.instance.client.auth.signOut();
      
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _userEmail!,
        redirectTo: 'http://localhost:3000/reset-password',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $_userEmail!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Failed to send email: ${e.toString()}';
      });
    }
  }

  // Step 3: Update password
  Future<void> _updatePassword() async {
    final newPass = newPassCtrl.text;
    final confirmPass = confirmPassCtrl.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _errorText = 'Please fill all fields');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _errorText = 'Passwords do not match');
      return;
    }

    if (newPass.length < 8) {
      setState(() => _errorText = 'Password must be at least 8 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // Update password in Supabase Auth
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPass),
      );

      // Update in local SQLite
      final user = await moodDb.getUserByEmail(_userEmail!);
      if (user != null) {
        await moodDb.updatePassword(user.id, newPass);
      }

      // Sign out
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Failed to update password: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9FB7D9),
        title: const Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildSendEmailStep();
      case 2:
        return _buildNewPasswordStep();
      default:
        return _buildEmailStep();
    }
  }

  // Step 0: Enter Email
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.email_outlined, size: 64, color: Color(0xFF9FB7D9)),
        const SizedBox(height: 24),
        const Text(
          'Enter your email to reset password:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email',
            hintText: 'example@gmail.com',
            prefixIcon: Icon(Icons.email),
          ),
        ),
        _buildError(),
        const SizedBox(height: 24),
        _buildButton('CONTINUE', _verifyEmail),
      ],
    );
  }

  // Step 1: Send Email Instructions
  Widget _buildSendEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 64, color: Color(0xFF9FB7D9)),
        const SizedBox(height: 24),
        Text(
          'Reset password for:\n$_userEmail',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📧 Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Click "Send Reset Email" below'),
              Text('2. Check your email inbox'),
              Text('3. Click the link in the email'),
              Text('4. Come back here and click "I Clicked the Link"'),
            ],
          ),
        ),
        _buildError(),
        const SizedBox(height: 24),
        _buildButton('Send Reset Email', _sendResetEmail),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () {
              setState(() => _currentStep = 2);
            },
            icon: const Icon(Icons.check),
            label: const Text('I Clicked the Link → Enter New Password'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Text('← Back'),
          ),
        ),
      ],
    );
  }

  // Step 2: Enter New Password
  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lock_reset, size: 64, color: Color(0xFF9FB7D9)),
        const SizedBox(height: 24),
        const Text(
          'Enter your new password',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: newPassCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmPassCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        _buildError(),
        const SizedBox(height: 24),
        _buildButton('Update Password', _updatePassword),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: const Text('← Back'),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    if (_errorText == null) return const SizedBox.shrink();
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_errorText!, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9FB7D9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}