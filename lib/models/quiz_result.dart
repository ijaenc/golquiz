import 'quiz_question.dart';

class QuizResult {
  const QuizResult({
    required this.categoryId,
    required this.categoryName,
    required this.difficulty,
    required this.questionCount,
    required this.score,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.bestStreak,
  });

  final String categoryId;
  final String categoryName;
  final QuizDifficulty difficulty;
  final int questionCount;
  final int score;
  final int correctAnswers;
  final int incorrectAnswers;
  final int bestStreak;

  double get accuracy =>
      questionCount == 0 ? 0 : correctAnswers / questionCount;
  String get recordKey => '${categoryId}_${difficulty.name}_$questionCount';
}
