import 'package:flutter/material.dart';
import 'database_service.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int _questionIndex = 0;
  int _totalScore = 0;
  int _selectedAnswer = -1;
  bool _isSubmitted = false;
  bool _isAdmin = false;
  String _result = '';

  final List<String> _questions = [
    'I feel nervous or anxious',
    'I have trouble relaxing',
    'I feel overwhelmed by my responsibilities',
    'I have difficulty sleeping',
    'I feel down or hopeless',
  ];

  final List<String> _options = [
    'Not at all',
    'Several days',
    'More than half the days',
    'Nearly every day',
  ];

  List<Map<String, dynamic>> _dbResults = [];

  // Load admin results from database
  Future<void> _loadAdminResults() async {
    final data = await DatabaseService.instance.getResults();
    setState(() {
      _dbResults = data;
    });
  }

  void _nextQuestion() {
    setState(() {
      _totalScore += _selectedAnswer; // scoring 0–3
      _selectedAnswer = -1;

      if (_questionIndex < _questions.length - 1) {
        _questionIndex++;
      } else {
        _calculateResult();
      }
    });
  }

  Future<void> _calculateResult() async {
    String finalResult;

    if (_totalScore <= 5) {
      finalResult = 'Low stress level';
    } else if (_totalScore <= 10) {
      finalResult = 'Moderate stress level';
    } else {
      finalResult = 'High stress level\nConsider seeking support.';
    }

    setState(() {
      _isSubmitted = true;
      _result = finalResult;
    });

    await DatabaseService.instance.insertResult(finalResult, _totalScore);
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
      _selectedAnswer = -1;
      _isSubmitted = false;
      _result = '';
    });
  }

  // ================= USER QUIZ UI =================
  Widget _buildQuiz() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Question ${_questionIndex + 1} of ${_questions.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            _questions[_questionIndex],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ...List.generate(4, (index) {
            return RadioListTile<int>(
              title: Text(_options[index]),
              value: index,
              groupValue: _selectedAnswer,
              onChanged: (value) {
                setState(() {
                  _selectedAnswer = value!;
                });
              },
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectedAnswer == -1 ? null : _nextQuestion,
            child: Text(
              _questionIndex == _questions.length - 1 ? 'Submit' : 'Next',
            ),
          ),
        ],
      ),
    );
  }

  // ================= USER RESULT UI =================
  Widget _buildUserResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Your Result',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            _result,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _resetQuiz,
            child: const Text('Restart Quiz'),
          ),
        ],
      ),
    );
  }

  // ================= ADMIN DASHBOARD =================
  Widget _buildAdminView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Admin Dashboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _dbResults.isEmpty
                ? const Center(child: Text('No quiz results yet'))
                : ListView.builder(
              itemCount: _dbResults.length,
              itemBuilder: (context, index) {
                final result = _dbResults[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment),
                    title: Text('User ${index + 1}'),
                    subtitle: Text(
                      '${result['result']} (Score: ${result['score']})',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= MAIN BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        title: const Text(
          'Mental Health Quiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isAdmin ? Icons.admin_panel_settings : Icons.person,
            ),
            tooltip: 'Switch User / Admin',
            onPressed: () async {
              setState(() {
                _isAdmin = !_isAdmin;
              });
              if (_isAdmin) {
                await _loadAdminResults();
              }
            },
          ),
        ],
      ),
      body: _isAdmin
          ? _buildAdminView()
          : _isSubmitted
          ? _buildUserResult()
          : _buildQuiz(),
    );
  }
}
