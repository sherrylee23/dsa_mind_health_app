import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar.dart';
import 'describeMood.dart';

class Mood extends StatefulWidget {
  final int userId;
  const Mood({super.key, required this.userId});

  @override
  State<Mood> createState() => _MoodState();
}

class _MoodState extends State<Mood> {
  String? selectedMoodAsset;

  final Map<String, String> moodAssets = {
    'Great': 'assets/images/Great.png',
    'Good': 'assets/images/Good.png',
    'Okay': 'assets/images/Okay.png',
    'Not Great': 'assets/images/No_Great.png',
    'Bad': 'assets/images/Bad.png',
    'Angry': 'assets/images/Angry.png',
  };

  @override
  void initState() {
    super.initState();
  }

  void _selectedMood(String moodAssetsPath) {
    setState(() {
      selectedMoodAsset = (selectedMoodAsset == moodAssetsPath)
          ? null
          : moodAssetsPath;
    });
  }

  Widget _buildMoodEmoji(String moodName, String assetPath) {
    final bool isSelected = selectedMoodAsset == assetPath;
    final double opacity = isSelected || selectedMoodAsset == null ? 1.0 : 0.4;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _selectedMood(assetPath),
          child: Opacity(
            opacity: opacity,
            child: Image.asset(assetPath, width: 60, height: 60),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          moodName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final String formattedDate = DateFormat('EEEE, dd MMM').format(today);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Mood'),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => calendar(userId: widget.userId,)));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 40),
              const Text(
                'How are you feeling?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: moodAssets.entries.map((entry) {
                  return _buildMoodEmoji(entry.key, entry.value);
                }).toList(),
              ),
              const Divider(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: selectedMoodAsset != null
                      ? () {
                          print('Selected Date: $today');
                          print('Selected Mood: $selectedMoodAsset');

                          if (selectedMoodAsset != null &&
                              selectedMoodAsset != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => describeMood(
                                  date: today,
                                  moodAssetPath: selectedMoodAsset!,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (selectedMoodAsset == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please select an emotion to continue.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
