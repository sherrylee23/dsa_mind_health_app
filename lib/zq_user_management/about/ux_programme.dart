import 'package:flutter/material.dart';

class UXProgrammeScreen extends StatefulWidget {
  const UXProgrammeScreen({super.key});

  @override
  State<UXProgrammeScreen> createState() => _UXProgrammeScreenState();
}

class _UXProgrammeScreenState extends State<UXProgrammeScreen> {
  bool _isJoined = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Experience Programme'),
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
                  child: Icon(Icons.feedback_outlined),
                ),
                SizedBox(width: 12),
                Text(
                  'Help us improve\nDSA MindHealth',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What is the User Experience Programme?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The User Experience (UX) Programme allows anonymous usage '
                            'information or feedback to be used to improve the app. '
                            'This can include things like which features are used most '
                            'often or general app performance.\n',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your data and privacy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '• Participation is optional.\n'
                            '• Data is used only for improving this app.\n'
                            '• No counselling notes or personal reflections are shared.\n',
                      ),
                      const SizedBox(height: 16),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Join UX Programme',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Allow anonymous usage data / feedback to help improve the app.',
                        ),
                        value: _isJoined,
                        onChanged: (value) {
                          setState(() {
                            _isJoined = value;
                          });
                        },
                      ),

                      const SizedBox(height: 8),
                      Text(
                        _isJoined
                            ? 'You are currently participating in the User Experience Programme.'
                            : 'You are not participating in the User Experience Programme.',
                        style: const TextStyle(fontStyle: FontStyle.italic),
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
