import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/quiz_result.dart';
import '../services/local_storage_service.dart';
import '../services/profile_service.dart';
import '../services/quiz_attempt_service.dart';
import 'auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(
    this._authProvider,
    this._storage,
    this._profileService,
    this._attemptService,
  );

  final AuthProvider _authProvider;
  final LocalStorageService _storage;
  final ProfileService _profileService;
  final QuizAttemptService _attemptService;
  bool _isLoading = false;
  String? _error;
  String? _syncError;

  AppUser get user => _authProvider.user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get syncError => _syncError;

  Future<void> updateName(String value) async {
    final name = value.trim();
    if (name.isEmpty || name == user.name) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (!_authProvider.isDemo && _profileService.isConfigured) {
        await _profileService.updateDisplayName(user.id, name);
      }
      await _authProvider.updateUser(user.copyWith(name: name));
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordResult(QuizResult result) async {
    final attemptId = result.attemptId;
    if (attemptId != null && _storage.isAttemptProcessed(attemptId)) return;

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
    if (attemptId != null) await _storage.markAttemptProcessed(attemptId);

    _syncError = null;
    if (!_authProvider.isDemo && _attemptService.isConfigured) {
      try {
        await _attemptService.recordAttempt(result);
      } catch (error) {
        _syncError =
            'El resultado quedó guardado localmente, pero no se pudo sincronizar: $error';
      }
    }
    notifyListeners();
  }

  void _setBest(Map<String, int> records, String key, int score) {
    if (score > (records[key] ?? 0)) records[key] = score;
  }

  Future<void> resetProgress() async {
    if (!_authProvider.isDemo) return;
    await _authProvider.resetUser();
    notifyListeners();
  }
}
