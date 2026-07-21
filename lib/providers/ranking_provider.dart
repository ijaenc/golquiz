import 'package:flutter/foundation.dart';

import '../models/leaderboard_user.dart';
import 'profile_provider.dart';

class RankingProvider extends ChangeNotifier {
  RankingProvider(this._profileProvider) {
    _profileProvider.addListener(_onProfileChanged);
  }

  final ProfileProvider _profileProvider;

  static const _mockUsers = <LeaderboardUser>[
    LeaderboardUser(id: 'mock-1', name: 'SofiGol', score: 1850, initial: 'S'),
    LeaderboardUser(id: 'mock-2', name: 'ElDiez', score: 1420, initial: 'E'),
    LeaderboardUser(id: 'mock-3', name: 'CapitánFC', score: 980, initial: 'C'),
    LeaderboardUser(id: 'mock-4', name: 'LaRoja', score: 640, initial: 'L'),
    LeaderboardUser(id: 'mock-5', name: 'TikiTaka', score: 310, initial: 'T'),
  ];

  List<LeaderboardUser> get users {
    final user = _profileProvider.user;
    final ranking = [
      ..._mockUsers,
      LeaderboardUser(
        id: user.id,
        name: user.name,
        score: user.totalScore,
        initial: user.initial,
        isCurrentUser: true,
      ),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return ranking;
  }

  int get currentUserPosition =>
      users.indexWhere((user) => user.isCurrentUser) + 1;

  void _onProfileChanged() => notifyListeners();

  @override
  void dispose() {
    _profileProvider.removeListener(_onProfileChanged);
    super.dispose();
  }
}
