import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'category.dart';
import 'quiz_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<int> _numQuestionsOptions = [5, 10, 15];
  final List<String> _difficultyOptions = ['easy', 'medium', 'hard'];
  final List<String> _typeOptions = ['Multiple', 'True/False'];

  int _selectedNumQuestions = 5;
  String _selectedDifficulty = 'easy';
  String _selectedType = 'Multiple'; // Changed this to 'Multiple'
  Category? _selectedCategory;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response =
        await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['trivia_categories'] as List;
      setState(() {
        _categories = data.map((json) => Category.fromJson(json)).toList();
      });
      // DEBUG fetched categories
      print('Categories fetched: ${_categories.map((c) => c.name).toList()}');
    }
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Input'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Container(
        color: Colors.lightGreen[50],
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Center(
              child: Text(
                'Customize Your Quiz!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Number of Questions
            DropdownButtonFormField<int>(
              value: _selectedNumQuestions,
              onChanged: (value) =>
                  setState(() => _selectedNumQuestions = value!),
              items: _numQuestionsOptions
                  .map((num) => DropdownMenuItem(
                      value: num, child: Text('$num Questions')))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Number of Questions',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Difficulty
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              onChanged: (value) => setState(() => _selectedDifficulty = value!),
              items: _difficultyOptions
                  .map((difficulty) => DropdownMenuItem(
                value: difficulty,
                child: Text(difficulty[0].toUpperCase() + difficulty.substring(1)),
              ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Type of Question
            DropdownButtonFormField<String>(
              value: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value!),
              items: _typeOptions
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Question Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Start Quiz Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCategory == null) {
                    _showValidationError('Please select a category.');
                  } else if (_selectedCategory!.id == 0) {
                    _showValidationError('Invalid category selected.');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          settings: {
                            'numQuestions': _selectedNumQuestions,
                            'difficulty': _selectedDifficulty,
                            'type': _selectedType,
                            'category': _selectedCategory?.id,
                          },
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Quiz',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
