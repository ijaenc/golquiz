import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/quiz_result.dart';
import 'auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._authProvider);

  final AuthProvider _authProvider;

  AppUser get user => _authProvider.user;

  Future<void> updateName(String value) async {
    final name = value.trim();
    if (name.isEmpty || name == user.name) return;
    await _authProvider.updateUser(user.copyWith(name: name));
    notifyListeners();
  }

  Future<void> recordResult(QuizResult result) async {
    final records = Map<String, int>.from(user.bestScores);
    _setBest(records, result.recordKey, result.score);
    _setBest(records, 'category_${result.categoryId}', result.score);
    _setBest(records, 'difficulty_${result.difficulty.name}', result.score);
    _setBest(records, 'count_${result.questionCount}', result.score);

    await _authProvider.updateUser(
      user.copyWith(
        totalScore: user.totalScore + result.score,
        gamesPlayed: user.gamesPlayed + 1,
        correctAnswers: user.correctAnswers + result.correctAnswers,
        incorrectAnswers: user.incorrectAnswers + result.incorrectAnswers,
        bestStreak: result.bestStreak > user.bestStreak
            ? result.bestStreak
            : user.bestStreak,
        bestScores: records,
      ),
    );
    notifyListeners();
  }

  void _setBest(Map<String, int> records, String key, int score) {
    if (score > (records[key] ?? 0)) records[key] = score;
  }

  Future<void> resetProgress() async {
    await _authProvider.resetUser();
    notifyListeners();
  }
}
