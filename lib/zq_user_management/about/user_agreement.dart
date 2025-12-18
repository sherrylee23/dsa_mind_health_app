import 'package:flutter/material.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Agreement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF9FB7D9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small header icon + title (optional)
            Row(
              children: const [
                CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.description_outlined),
                ),
                SizedBox(width: 12),
                Text(
                  'DSA MindHealth\nUser Agreement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card with scrollable text
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agreement Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This app is developed for students to support awareness and '
                            'self‑management of mental well‑being. It is not a replacement '
                            'for professional counselling or medical treatment.\n',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'By using this app, you agree that:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text('• You use the app voluntarily for your own well‑being.\n'
                          '• Information and suggestions in the app are general guidance only.\n'
                          '• You will seek help from counselling or medical professionals when needed.\n'
                          '• You are responsible for keeping your account and device secure.\n'),
                      SizedBox(height: 12),
                      Text(
                        'Emergency and Crisis Support',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'If you feel at risk of harming yourself or others, or you are in a crisis, '
                            'do not rely on this app. Contact emergency services or your university '
                            'counselling service immediately.',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Data and Privacy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'This app may store your information on your device to provide its features. '
                            'More details about how data is handled are described in the Privacy Policy.',
                      ),
                      SizedBox(height: 16),
                      Text(
                        'By continuing to use DSA MindHealth, you confirm that you have read and '
                            'understood this User Agreement.',
                      ),
                    ],
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
