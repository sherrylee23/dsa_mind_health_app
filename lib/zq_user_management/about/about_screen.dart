import 'package:flutter/material.dart';
import 'user_agreement.dart';
import 'privacy_policy.dart';
import 'ux_programme.dart';
import 'rate.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _logoPath = 'assets/images/brain_logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About this app'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xFF9FB7D9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFD5E6FF),
                borderRadius: BorderRadius.circular(32),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  _logoPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
                'DSA MindHealth',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD5E6FF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _AboutItem(
                    text: 'User Agreement',
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserAgreementScreen(),
                          ),
                      );
                    },
                  ),
                  _AboutItem(
                    text: 'Privacy Policy',
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _AboutItem(
                    text: 'User Experience Programme',
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UXProgrammeScreen(),
                        ),
                      );
                    },
                  ),
                  _AboutItem(
                    text: 'Rate',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RateScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AboutItem({
   required this.text,
   required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 0,
    );
  }
}

