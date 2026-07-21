import 'leaderboard_user.dart';

class GroupMember {
  const GroupMember({
    required this.user,
    required this.role,
    required this.joinedAt,
  });

  final LeaderboardUser user;
  final String role;
  final DateTime joinedAt;
}
