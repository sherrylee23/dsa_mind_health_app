import 'package:dsa_mind_health/MoodDatabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final userDb = MoodDatabase();
  String? _errorText;
  String? _selectedGender;
  bool _isLoading = false;

  // Email format validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    ageCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final ageText = ageCtrl.text.trim();
    final password = passCtrl.text;
    final confirmPass = confirmCtrl.text;

    // 1. Validate fields
    if (name.isEmpty ||
        email.isEmpty ||
        ageText.isEmpty ||
        password.isEmpty ||
        confirmPass.isEmpty) {
      setState(() => _errorText = 'Please fill all fields');
      return;
    }

    if (_selectedGender == null) {
      setState(() => _errorText = 'Please select gender');
      return;
    }

    if (password != confirmPass) {
      setState(() => _errorText = 'Passwords do not match');
      return;
    }

    if (password.length < 8) {
      setState(() => _errorText = 'Password must be at least 8 characters');
      return;
    }

    // Email format validation
    if (!_isValidEmail(email)) {
      setState(() => _errorText = 'Please enter a valid email address');
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      setState(() => _errorText = 'Please enter a valid age');
      return;
    }

    final gender = _selectedGender!;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // 2. Check if email already exists in local database
      final existingUser = await userDb.getUserByEmail(email);
      if (existingUser != null) {
        setState(() {
          _isLoading = false;
          _errorText = 'Email already registered';
        });
        return;
      }

      // 3. Register with Supabase Auth (enables password reset emails)
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (authResponse.user == null) {
        setState(() {
          _isLoading = false;
          _errorText = 'Registration failed. Please try again.';
        });
        return;
      }

      // 4. Create new user for local database
      final newUser = UserModel(
        id: 0,
        name: name,
        email: email,
        gender: gender,
        age: age,
        password: password,
        createdOn: DateTime.now().toIso8601String(),
      );

      // 5. Save to local SQLite and Supabase user_model table
      await userDb.registerUser(newUser);

      // 6. Sign out from Supabase Auth (user needs to login again)
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      // 7. Back to login screen
      Navigator.pop(context);
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Registration failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9FB7D9),
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
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

            // Name
            const Text('Name:'),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            const Text('Email:'),
            const SizedBox(height: 6),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                hintText: 'example@gmail.com',
              ),
            ),
            const SizedBox(height: 16),

            // Gender (dropdown)
            const Text('Gender:'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Girl'),
                ),
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Boy'),
                ),
                DropdownMenuItem(
                  value: 'Prefer not to say',
                  child: Text("Don't want to tell"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Age
            const Text('Age:'),
            const SizedBox(height: 6),
            TextField(
              controller: ageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            const Text('Password:'),
            const SizedBox(height: 6),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            const Text('Confirm Password:'),
            const SizedBox(height: 6),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                width: 160,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FB7D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                          'SIGN UP',
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
