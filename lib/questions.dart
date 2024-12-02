import 'package:html/parser.dart' show parse;

class Question {
  String questionText;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  late final List<String> shuffledAnswers;

  Question({
    required this.questionText,
    required this.correctAnswer,
    required this.incorrectAnswers,
  }) {
    // Decode HTML entities
    final document = parse(questionText);
    final decodedText = document.body?.text ?? questionText;

    shuffledAnswers = List<String>.from(incorrectAnswers)
      ..add(correctAnswer)
      ..shuffle();

    questionText = decodedText;
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    final document = parse(json['question']);
    final decodedQuestionText = document.body?.text ?? json['question'];

    final correctAnswerDocument = parse(json['correct_answer']);
    final decodedCorrectAnswer =
        correctAnswerDocument.body?.text ?? json['correct_answer'];

    final incorrectAnswers =
        List<String>.from(json['incorrect_answers'].map((answer) {
      final answerDocument = parse(answer);
      return answerDocument.body?.text ?? answer;
    }));

    return Question(
      questionText: decodedQuestionText,
      correctAnswer: decodedCorrectAnswer,
      incorrectAnswers: incorrectAnswers,
    );
  }
}
