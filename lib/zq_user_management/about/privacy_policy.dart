import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
            Row(
              children: const [
                CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.privacy_tip_outlined),
                ),
                SizedBox(width: 12),
                Text(
                  'DSA MindHealth\nPrivacy Policy',
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
                        'Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This Privacy Policy explains how the DSA MindHealth app handles '
                            'your information. The app is designed for students and focuses '
                            'on protecting your privacy as much as possible.\n',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'What data we collect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Depending on how the app is implemented, it may collect:\n'
                            '• Basic profile details you provide (e.g. name, email, age).\n'
                            '• Mood logs or reflections you enter in the app.\n'
                            '• App settings or preferences (e.g. notification, theme).\n',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'How your data is stored',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'For this prototype, your data is stored locally on your device '
                            '(for example using a local database) and is not shared with external '
                            'servers by default.\n',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'How your data is used',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'The app uses your data only to provide features such as mood tracking, '
                            'statistics, and personalised recommendations. It is not used for '
                            'advertising.\n',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your choices',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '• You may stop using the app at any time.\n'
                            '• You may clear or reset your data in the app settings (if provided).\n',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Contact',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'For questions about this Privacy Policy, please contact the Department '
                            'of Student Affairs (DSA) or your course tutor.',
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
