import 'package:flutter/material.dart';
import 'quiz.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.userId});

  final int userId;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.psychology,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),

              const Text(
                'Mental Health App',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // ✅ GET STARTED → QUIZ PAGE
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Quiz(userId: userId),
                    ),
                  );
                },
                child: const Text('Get Started'),
              ),


              const SizedBox(height: 15),

              // ✅ SKIP QUIZ → STAY ON WELCOME PAGE
              TextButton(
                onPressed: () {
                  // Do nothing / remain on welcome page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You are already on the Welcome Page'),
                    ),
                  );
                },
                child: const Text(
                  'Skip Quiz',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
