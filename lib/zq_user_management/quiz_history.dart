import 'package:flutter/material.dart';
import 'package:dsa_mind_health/MoodDatabase.dart';

class QuizHistoryScreen extends StatefulWidget {
  final int userId;

  const QuizHistoryScreen({super.key, required this.userId});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final _db = MoodDatabase();
  late Future<List<Map<String, dynamic>>> _futureResults;

  @override
  void initState() {
    super.initState();
    _futureResults = _db.getQuizResultsForUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9FB7D9),
        title: const Text('Quiz History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load history'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('No quiz history yet.'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final row = data[index];
              final result = row['result'] as String?;
              final score = row['score']?.toString() ?? '';
              final createdAt = row['created_at'] as String?;

              // Simple date formatting from ISO string
              String displayTime = createdAt ?? '';
              if (createdAt != null && createdAt.isNotEmpty) {
                try {
                  final dt = DateTime.parse(createdAt);
                  displayTime = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
                      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                } catch (_) {
                  // keep raw string if parse fails
                }
              }

              return ListTile(
                title: Text(result ?? 'No result'),
                subtitle: Text('Score: $score\n$displayTime'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
