import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'MoodModel.dart';
import 'MoodDatabase.dart';

class describeMood extends StatefulWidget {
  final DateTime date;
  final String moodAssetPath;
  final int userId;


  const describeMood({
    super.key,
    required this.date,
    required this.moodAssetPath,
    required this.userId,
  });

  @override
  State<describeMood> createState() => _describeMoodState();
}

class _describeMoodState extends State<describeMood> {
  //controller
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final moodDB = MoodDatabase();

  late String _currentMoodAssetPath;

  final Map<String, String> _allMoods = {
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
    _currentMoodAssetPath = widget.moodAssetPath;
  }

  int _getScaleFromMoodAsset(String assetPath) {
    final moodName = assetPath
        .split('/')
        .last
        .split('.')
        .first;
    switch (moodName) {
      case 'Great':
        return 5;
      case 'Good':
        return 4;
      case 'Okay':
        return 3;
      case 'No_Great':
        return 2;
      case 'Bad':
        return 1;
      case 'Angry':
        return 0;
      default:
        return 3;
    }
  }

  String _getMoodNameFromAsset(String assetPath) {
    return assetPath
        .split('/')
        .last
        .split('.')
        .first
        .replaceAll('_', ' ');
  }

  void _saveMood() async {
    final int scale = _getScaleFromMoodAsset(_currentMoodAssetPath);
    final String title = _titleCtrl.text.trim();
    final String description = _descriptionCtrl.text.trim();
    if (title.isEmpty && description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title or description.')),
      );
      return;
    }

    final newMood = MoodModel(
      id: 0,
      userId: widget.userId,
      scale: scale,
      title: title,
      description: description,
      createdOn: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      isFavorite: 0,
    );
    await moodDB.insertMood(newMood);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mood saved successfully!')));

    Navigator.of(context).pop();
  }

  Widget _buildMoodEmojiTile(String moodName, String assetPath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMoodAssetPath = assetPath;
        });
        Navigator.of(context).pop();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetPath, width: 48, height: 48),
          const SizedBox(height: 4),
          Text(moodName, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to permanently delete this entry?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Record deleted!')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showMoodSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Your Mood'),
          content: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: _allMoods.entries.map((entry) {
              return _buildMoodEmojiTile(entry.key, entry.value);
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String moodName = _getMoodNameFromAsset(_currentMoodAssetPath);
    final String formattedDate = DateFormat('dd/MM/yyyy EEEE').format(
        widget.date);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDAE5FF),
        elevation: 0,
        title: const Text(
            "Describe Mood", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),

            Center(
              child: GestureDetector(
                onTap: _showMoodSelectionDialog,
                child: Column(
                  children: [
                    Image.asset(_currentMoodAssetPath, width: 90, height: 90),
                    const SizedBox(height: 10),
                    Text(
                      moodName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 14, color: Colors.grey),
                        Text(" Tap to change", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Title...',
                border: InputBorder.none,
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 20),

            TextField(
              controller: _descriptionCtrl,
              maxLines: null,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Write something here...',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF91B1E0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _showDeleteConfirmationDialog,
              child: const Text('CLEAR', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF91B1E0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveMood,
              child: const Text('SUBMIT', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
