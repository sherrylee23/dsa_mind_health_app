import 'package:dsa_mind_health/MoodDatabase.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'about/about_screen.dart';
import 'update_password_screen.dart';
import '../zq_user_management/models/user_model.dart';
import 'login/login_screen.dart';
import 'quiz_history.dart';

class ProfileScreen extends StatefulWidget {
  final int userId; // passed from the login module

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userDb = MoodDatabase();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await userDb.getUserById(widget.userId);

    setState(() {
      _user = user ??
          UserModel(
            id: widget.userId,
            name: 'Nomihaha',
            email: 'student@tarumt.edu.my',
            gender: 'Female',
            age: 21,
            password: '123456',
            createdOn: '',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xFF9FB7D9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Section
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  child: Icon(Icons.person, size: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${_user!.gender} | ${_user!.age}'),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            // Menu Items Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD5E6FF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _ProfileItem(
                    icon: Icons.person_outline,
                    text: 'Edit Profile',
                    onTap: () async {
                      final updated = await Navigator.push<UserModel>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(user: _user!),
                        ),
                      );
                      if (updated != null) {
                        setState(() {
                          _user = updated;
                        });
                      }
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.info_outline,
                    text: 'About',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.lock_outline,
                    text: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdatePasswordScreen(userId: _user!.id),
                        ),
                      );
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.history,
                    text: 'Quiz History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizHistoryScreen(userId: _user!.id),
                        ),
                      );
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.logout,
                    text: 'Logout',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      (route) => false,
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
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

// Private helper widget for profile menu items
class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 24,
    );
  }
}