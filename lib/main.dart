import 'dart:async'; // <--- FIX 1: Required for StreamSubscription
import 'dart:io';
import 'package:dsa_mind_health/admin_main_page.dart';
import 'package:dsa_mind_health/admin_result.dart';
import 'package:dsa_mind_health/describeMood.dart';
import 'package:dsa_mind_health/main_page_of_quiz.dart';
import 'package:dsa_mind_health/quiz.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dsa_mind_health/MoodDatabase.dart';
import 'package:dsa_mind_health/mood.dart';
import 'package:dsa_mind_health/zq_user_management/profile_screen.dart';
import 'zq_user_management/login/spash_screen.dart';
import 'todo_page.dart';
import 'package:dsa_mind_health/zq_user_management/update_password_screen.dart';

const String url = 'https://wefuzytgpzhtjurzeble.supabase.co';
const String key = 'sb_secret_Sxx5PvKAuHSK8NksYXpSIg_TzozaSJ4';

// Inside lib/main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: url,
    anonKey: key,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Required for secure mobile deep links
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9FB7D9)),
        scaffoldBackgroundColor: const Color(0xFFDAE5FF),
        useMaterial3: true,
      ),
      // Ensure your initial route leads to the SplashScreen/LoginScreen
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.currentUserId});
  final String title;
  final int? currentUserId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();

    // Listen for the recovery event as soon as the LoginScreen starts
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          // Navigate immediately to the update screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UpdatePasswordScreen(userId: 0),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel(); // Always clean up your listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Welcome Back !',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Center(
                child: Image.asset('assets/images/brain_logo.png', height: 180),
              ),
              const SizedBox(height: 30),
              const Text(
                'Recommended',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              _buildMenuItem('To Do List', '📒'),
              _buildMenuItem('Record Your Mood', '😆'),
              _buildMenuItem('Mental Quiz', '📝'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMenuItem(String title, String emoji) {
    final int effectiveUserId = widget.currentUserId ?? 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF91B1E0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title),
        onTap: () {
          if (title == 'To Do List') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TodoListHomePage(userId: effectiveUserId),
              ),
            );
          } else if (title == 'Record Your Mood') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Mood(userId: effectiveUserId),
              ),
            );
          } else if (title == 'Mental Quiz') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Quiz(userId: effectiveUserId),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    final int effectiveUserId = widget.currentUserId ?? 1;
    const double iconSize = 32;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFF91B1E0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Home
          GestureDetector(
            onTap: () {
              // Usually just pops to top or does nothing if already on home
            },
            child: const Icon(Icons.home_outlined, size: iconSize),
          ),

          // 2. To-Do List
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TodoListHomePage(userId: effectiveUserId)),
              );
            },
            child: const Icon(Icons.list_alt_rounded, size: iconSize),
          ),

          // 3. Mood Recording
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Mood(userId: effectiveUserId)),
              );
            },
            child: const Icon(Icons.sentiment_satisfied_alt_outlined, size: iconSize),
          ),

          // 4. Mental Quiz / Results (The missing icon)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Quiz(userId: effectiveUserId)),
              );
            },
            child: const Icon(Icons.description_outlined, size: iconSize), // Document icon for results/quiz
          ),

          // 5. Profile
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(userId: effectiveUserId)),
              );
            },
            child: const Icon(Icons.person_outline, size: iconSize),
          ),
        ],
      ),
    );
  }
}