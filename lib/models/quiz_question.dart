enum QuizDifficulty {
  easy('Fácil', 10),
  medium('Media', 20),
  hard('Difícil', 30);

  const QuizDifficulty(this.label, this.basePoints);
  final String label;
  final int basePoints;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.categoryId,
    required this.difficulty,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.imageUrl,
    this.isActive = true,
  });

  final String id;
  final String categoryId;
  final QuizDifficulty difficulty;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? imageUrl;
  final bool isActive;
}
