import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'questions.dart';
import 'end.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> settings;

  const QuizScreen({super.key, required this.settings});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  Timer? _timer;
  int _remainingTime = 10;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final url = 'https://opentdb.com/api.php?amount=5&category=9&difficulty=easy&type=multiple';


    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['results'] != null &&
        data['results'].isNotEmpty) {
      setState(() {
        _questions = data['results']
            .map<Question>((json) => Question.fromJson(json))
            .toList();
        _isLoading = false;
      });
      _startTimer();
    } else {
      setState(() {
        _isLoading = false;
      });
      _showNoQuestionsDialog();
    }
  }


  void _showNoQuestionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Questions Found'),
        content: const Text(
            'The selected quiz settings returned no questions. Please try different settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _remainingTime = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          // Time's up logic
          timer.cancel();
          _feedbackMessage =
              "Time's up! The correct answer is: ${_questions[_currentQuestionIndex].correctAnswer}";
          Future.delayed(const Duration(seconds: 2), _nextQuestion);
        }
      });
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 < _questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _feedbackMessage = null;
        _remainingTime = 10;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      _showSummary();
    }
  }

  void _showSummary() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EndScreen(score: _score, total: _questions.length),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No questions available. Please go back and try again.'),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Question ${_currentQuestionIndex + 1}/${_questions.length}'),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Real-time Score Display
            Text(
              'Score: $_score',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Question Text
            Text(
              question.questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Answer Options
            ...question.shuffledAnswers.map((option) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (option == question.correctAnswer) {
                          _score++;
                          _feedbackMessage = 'Correct!';
                        } else {
                          _feedbackMessage =
                              'Incorrect! The correct answer is: ${question.correctAnswer}';
                        }
                      });
                      Future.delayed(const Duration(seconds: 2), _nextQuestion);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),

            // Feedback Message
            if (_feedbackMessage != null)
              Text(
                _feedbackMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _feedbackMessage == 'Correct!'
                      ? Colors.green
                      : Colors.red,
                ),
              ),

            const Spacer(),

            // Timer Display
            Text(
              'Time Remaining: $_remainingTime seconds',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
