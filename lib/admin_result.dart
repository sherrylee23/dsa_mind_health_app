import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'MoodDatabase.dart';

class AdminResult extends StatefulWidget {
  const AdminResult({super.key});

  @override
  State<AdminResult> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminResult> {
  List<Map<String, dynamic>> _dbResults = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final data = await MoodDatabase().getQuizResultsWithUser();
    setState(() {
      _dbResults = data;
    });
  }

  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateString; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Results',
            onPressed: () async {
              await MoodDatabase().clearResults();
              await _loadResults();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _dbResults.isEmpty
            ? const Center(child: Text('No quiz results yet'))
            : ListView.builder(
          itemCount: _dbResults.length,
          itemBuilder: (context, index) {
            final result = _dbResults[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.assignment),
                title: Text(result['username'] ?? 'Unknown User'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Result: ${result['result']}'),
                    Text('Score: ${result['score']}'),
                    Text('Date: ${formatDate(result['created_at'])}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
