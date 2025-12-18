import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'service/user_database.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController ageCtrl;
  String? _selectedGender;
  String? _errorText;
  bool _isSaving = false;

  final userDb = UserDatabaseService();

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.name);
    ageCtrl = TextEditingController(text: widget.user.age.toString());
    _selectedGender = widget.user.gender;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = nameCtrl.text.trim();
    final ageText = ageCtrl.text.trim();
    final gender = _selectedGender;

    if (name.isEmpty || ageText.isEmpty || gender == null) {
      setState(() => _errorText = 'Please fill all fields');
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      setState(() => _errorText = 'Please enter a valid age');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      final updatedUser = UserModel(
        id: widget.user.id,
        name: name,
        email: widget.user.email,      // email not editable here
        gender: gender,
        age: age,
        password: widget.user.password,
        createdOn: widget.user.createdOn,
      );

      await userDb.updateUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, updatedUser); // return updated user
    } catch (e) {
      setState(() {
        _errorText = 'Failed to update profile: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF9FB7D9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name:'),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Gender:'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedGender?.isEmpty == true ? null : _selectedGender,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
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

            const Text('Age:'),
            const SizedBox(height: 6),
            TextField(
              controller: ageCtrl,
              keyboardType: TextInputType.number,
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
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FB7D9),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                    'SAVE',
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
