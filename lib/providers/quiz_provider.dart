import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/local_questions.dart';
import '../models/quiz_category.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../services/question_service.dart';
import 'profile_provider.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider(this._questionService, this._profileProvider);

  final QuestionService _questionService;
  final ProfileProvider _profileProvider;

  QuizCategory? _category;
  QuizDifficulty _difficulty = QuizDifficulty.easy;
  int _questionCount = 5;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  bool _isLoading = false;
  int _score = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _correctAnswers = 0;
  QuizResult? _lastResult;
  Future<void>? _finishFuture;
  String? _finishError;

  QuizCategory? get category => _category;
  QuizDifficulty get difficulty => _difficulty;
  int get questionCount => _questionCount;
  List<QuizQuestion> get questions => List.unmodifiable(_questions);
  QuizQuestion? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentIndex];
  int get currentIndex => _currentIndex;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get isAnswered => _isAnswered;
  bool get isLoading => _isLoading;
  int get score => _score;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get correctAnswers => _correctAnswers;
  int get incorrectAnswers =>
      _currentIndex + (_isAnswered ? 1 : 0) - _correctAnswers;
  QuizResult? get lastResult => _lastResult;
  String? get finishError => _finishError;
  double get progress =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  Future<void> startQuiz({
    required QuizCategory category,
    required QuizDifficulty difficulty,
    required int questionCount,
  }) async {
    _isLoading = true;
    notifyListeners();
    _category = category;
    _difficulty = difficulty;
    _questionCount = questionCount;
    _questions = await _questionService.getQuestions(
      categoryId: category.id,
      difficulty: difficulty,
      count: questionCount,
    );
    _currentIndex = 0;
    _selectedAnswerIndex = null;
    _isAnswered = false;
    _score = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    _correctAnswers = 0;
    _lastResult = null;
    _finishFuture = null;
    _finishError = null;
    _isLoading = false;
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (_isAnswered) return;
    _selectedAnswerIndex = index;
    notifyListeners();
  }

  void submitAnswer() {
    final question = currentQuestion;
    if (question == null || _selectedAnswerIndex == null || _isAnswered) return;
    _isAnswered = true;
    if (_selectedAnswerIndex == question.correctAnswerIndex) {
      _correctAnswers++;
      _currentStreak++;
      _bestStreak = _currentStreak > _bestStreak ? _currentStreak : _bestStreak;
      _score += _difficulty.basePoints + _streakBonus(_currentStreak);
    } else {
      _currentStreak = 0;
    }
    notifyListeners();
  }

  int _streakBonus(int streak) {
    if (streak >= 4) return 15;
    if (streak == 3) return 10;
    if (streak == 2) return 5;
    return 0;
  }

  Future<bool> nextQuestion() async {
    if (!_isAnswered) return false;
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _selectedAnswerIndex = null;
      _isAnswered = false;
      notifyListeners();
      return false;
    }
    await _finishQuiz();
    return true;
  }

  Future<void> _finishQuiz() {
    if (_lastResult != null && _finishFuture == null) {
      return Future.value();
    }
    return _finishFuture ??= _completeQuiz();
  }

  Future<void> _completeQuiz() async {
    final category = _category;
    if (category == null) return;
    _isLoading = true;
    _finishError = null;
    final result = QuizResult(
      categoryId: category.id,
      categoryName: category.name,
      difficulty: _difficulty,
      questionCount: _questions.length,
      score: _score,
      correctAnswers: _correctAnswers,
      incorrectAnswers: _questions.length - _correctAnswers,
      bestStreak: _bestStreak,
      attemptId: _createAttemptId(),
    );
    _lastResult = result;
    notifyListeners();
    try {
      await _profileProvider.recordResult(result);
    } catch (error) {
      _finishError =
          'No se pudo guardar el resultado: '
          '${error.toString().replaceFirst('Bad state: ', '')}';
    } finally {
      _isLoading = false;
      _finishFuture = null;
      notifyListeners();
    }
  }

  String _createAttemptId() {
    final random = Random.secure().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}-$random';
  }

  Future<void> replay() async {
    final category = _category ?? quizCategories.first;
    await startQuiz(
      category: category,
      difficulty: _difficulty,
      questionCount: _questionCount,
    );
  }
}
