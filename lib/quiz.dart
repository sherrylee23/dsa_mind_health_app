import 'package:dsa_mind_health/MoodDatabase.dart';
import 'package:flutter/material.dart';


class Quiz extends StatefulWidget {
  const Quiz({super.key, required this.userId});

  final int userId;

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int _questionIndex = 0;
  int _totalScore = 0;
  int _selectedAnswer = -1;
  bool _isSubmitted = false;
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

    await MoodDatabase().insertResult(widget.userId, finalResult, _totalScore);

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

  //USER QUIZ UI
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

  // USER RESULT UI
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

  // MAIN BUILD
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
      ),
        body: _isSubmitted ? _buildUserResult() : _buildQuiz(),
    );
  }
}
