class LeaderboardUser {
  const LeaderboardUser({
    required this.id,
    required this.name,
    required this.score,
    required this.initial,
    this.isCurrentUser = false,
    this.completedAt,
  });

  final String id;
  final String name;
  final int score;
  final String initial;
  final bool isCurrentUser;
  final DateTime? completedAt;

  factory LeaderboardUser.fromSupabase(
    Map<String, dynamic> json,
    String? currentUserId,
  ) {
    final name =
        (json['display_name'] as String?) ??
        (json['username'] as String?) ??
        'Futbolero';
    final id = (json['user_id'] ?? json['id']) as String;
    final completedAt = json['completed_at'] as String?;
    return LeaderboardUser(
      id: id,
      name: name,
      score: (json['best_score'] ?? json['total_points'] ?? 0) as int,
      initial: name.trim().isEmpty ? 'G' : name.trim()[0].toUpperCase(),
      isCurrentUser: id == currentUserId,
      completedAt: completedAt == null ? null : DateTime.tryParse(completedAt),
    );
  }
}
