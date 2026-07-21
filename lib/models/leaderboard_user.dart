class LeaderboardUser {
  const LeaderboardUser({
    required this.id,
    required this.name,
    required this.score,
    required this.initial,
    this.isCurrentUser = false,
  });

  final String id;
  final String name;
  final int score;
  final String initial;
  final bool isCurrentUser;
}
