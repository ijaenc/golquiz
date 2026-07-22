import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/local_questions.dart';
import '../models/leaderboard_user.dart';
import '../models/quiz_question.dart';
import '../services/ranking_service.dart';
import 'auth_provider.dart';
import 'profile_provider.dart';

class RankingProvider extends ChangeNotifier {
  RankingProvider(
    this._profileProvider,
    this._authProvider,
    this._rankingService,
  ) {
    _seenRankingRevision = _profileProvider.rankingRevision;
    _profileProvider.addListener(_onProfileChanged);
    _authProvider.addListener(_onAuthChanged);
  }

  final ProfileProvider _profileProvider;
  final AuthProvider _authProvider;
  final RankingService _rankingService;

  bool _isLoading = false;
  String? _error;
  List<LeaderboardUser> _globalUsers = [];
  List<LeaderboardUser> _quizUsers = [];
  String _categoryId = quizCategories.first.id;
  QuizDifficulty _difficulty = QuizDifficulty.easy;
  int _questionCount = 5;
  int _seenRankingRevision = 0;

  static const _mockUsers = <LeaderboardUser>[
    LeaderboardUser(id: 'mock-1', name: 'SofiGol', score: 1850, initial: 'S'),
    LeaderboardUser(id: 'mock-2', name: 'ElDiez', score: 1420, initial: 'E'),
    LeaderboardUser(id: 'mock-3', name: 'CapitánFC', score: 980, initial: 'C'),
    LeaderboardUser(id: 'mock-4', name: 'LaRoja', score: 640, initial: 'L'),
    LeaderboardUser(id: 'mock-5', name: 'TikiTaka', score: 310, initial: 'T'),
  ];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get categoryId => _categoryId;
  QuizDifficulty get difficulty => _difficulty;
  int get questionCount => _questionCount;
  List<LeaderboardUser> get globalUsers =>
      _useLocalFallback ? _localGlobalUsers : List.unmodifiable(_globalUsers);
  List<LeaderboardUser> get quizUsers =>
      _useLocalFallback ? _localQuizUsers : List.unmodifiable(_quizUsers);
  List<LeaderboardUser> get users => globalUsers;
  bool get _useLocalFallback =>
      _authProvider.isDemo || !_rankingService.isConfigured;

  List<LeaderboardUser> get _localGlobalUsers {
    final user = _profileProvider.user;
    return [
      ..._mockUsers,
      LeaderboardUser(
        id: user.id,
        name: user.name,
        score: user.totalScore,
        initial: user.initial,
        isCurrentUser: true,
      ),
    ]..sort((a, b) => b.score.compareTo(a.score));
  }

  List<LeaderboardUser> get _localQuizUsers {
    final user = _profileProvider.user;
    final recordKey = '${_categoryId}_${_difficulty.name}_$_questionCount';
    final currentScore = user.bestScores[recordKey] ?? 0;
    final base = <LeaderboardUser>[
      const LeaderboardUser(
        id: 'quiz-1',
        name: 'GolMaster',
        score: 315,
        initial: 'G',
      ),
      const LeaderboardUser(
        id: 'quiz-2',
        name: 'LaCapitana',
        score: 270,
        initial: 'L',
      ),
      const LeaderboardUser(
        id: 'quiz-3',
        name: 'FanáticoFC',
        score: 225,
        initial: 'F',
      ),
      LeaderboardUser(
        id: user.id,
        name: user.name,
        score: currentScore,
        initial: user.initial,
        isCurrentUser: true,
      ),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return base;
  }

  int get currentUserPosition =>
      globalUsers.indexWhere((user) => user.isCurrentUser) + 1;

  Future<void> initialize() => refreshGlobal();

  Future<void> refreshGlobal() async {
    if (_useLocalFallback) {
      notifyListeners();
      return;
    }
    await _load(() async {
      _globalUsers = await _rankingService.fetchGlobal(_authProvider.user.id);
    });
  }

  Future<void> refreshQuiz() async {
    if (_useLocalFallback) {
      notifyListeners();
      return;
    }
    await _load(() async {
      _quizUsers = await _rankingService.fetchBestQuiz(
        currentUserId: _authProvider.user.id,
        categoryId: _categoryId,
        difficulty: _difficulty,
        questionCount: _questionCount,
      );
    });
  }

  Future<void> setFilters({
    String? categoryId,
    QuizDifficulty? difficulty,
    int? questionCount,
  }) async {
    _categoryId = categoryId ?? _categoryId;
    _difficulty = difficulty ?? _difficulty;
    _questionCount = questionCount ?? _questionCount;
    await refreshQuiz();
  }

  Future<void> _load(Future<void> Function() operation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await operation();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onProfileChanged() {
    _updateCurrentUserSnapshots();
    final revision = _profileProvider.rankingRevision;
    if (revision != _seenRankingRevision) {
      _seenRankingRevision = revision;
      unawaited(_refreshAfterSuccessfulSync());
    }
    notifyListeners();
  }

  void _updateCurrentUserSnapshots() {
    if (_useLocalFallback) return;
    final user = _profileProvider.user;
    _upsertCurrentUser(
      _globalUsers,
      score: user.totalScore,
      includeIfMissing: true,
    );
    final recordKey = '${_categoryId}_${_difficulty.name}_$_questionCount';
    final bestScore = user.bestScores[recordKey] ?? 0;
    _upsertCurrentUser(
      _quizUsers,
      score: bestScore,
      includeIfMissing: bestScore > 0,
    );
  }

  void _upsertCurrentUser(
    List<LeaderboardUser> users, {
    required int score,
    required bool includeIfMissing,
  }) {
    final profile = _profileProvider.user;
    final index = users.indexWhere((user) => user.id == profile.id);
    if (index < 0 && !includeIfMissing) return;
    final previous = index < 0 ? null : users[index];
    final updated = LeaderboardUser(
      id: profile.id,
      name: profile.name,
      score: score,
      initial: profile.initial,
      isCurrentUser: true,
      completedAt: previous?.completedAt,
    );
    if (index < 0) {
      users.add(updated);
    } else {
      users[index] = updated;
    }
    users.sort((a, b) => b.score.compareTo(a.score));
  }

  Future<void> _refreshAfterSuccessfulSync() async {
    if (_useLocalFallback) return;
    await _load(() async {
      _globalUsers = await _rankingService.fetchGlobal(_authProvider.user.id);
      _quizUsers = await _rankingService.fetchBestQuiz(
        currentUserId: _authProvider.user.id,
        categoryId: _categoryId,
        difficulty: _difficulty,
        questionCount: _questionCount,
      );
    });
  }

  void _onAuthChanged() {
    if (!_authProvider.isAuthenticated) {
      _globalUsers = [];
      _quizUsers = [];
      _error = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _profileProvider.removeListener(_onProfileChanged);
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}
