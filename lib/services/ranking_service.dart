import '../models/leaderboard_user.dart';
import '../models/quiz_question.dart';
import 'supabase_service.dart';

class RankingService {
  const RankingService(this._supabase);

  final SupabaseService _supabase;
  bool get isConfigured => _supabase.isConfigured;

  Future<List<LeaderboardUser>> fetchGlobal(String currentUserId) async {
    final rows = await _supabase.client!
        .from('profiles')
        .select('id, username, display_name, avatar_url, total_points')
        .order('total_points', ascending: false)
        .limit(100);
    return rows
        .map((row) => LeaderboardUser.fromSupabase(row, currentUserId))
        .toList();
  }

  Future<List<LeaderboardUser>> fetchBestQuiz({
    required String currentUserId,
    required String categoryId,
    required QuizDifficulty difficulty,
    required int questionCount,
  }) async {
    final response =
        await _supabase.client!.rpc(
              'get_quiz_leaderboard',
              params: {
                'p_category_id': categoryId,
                'p_difficulty': difficulty.name,
                'p_question_count': questionCount,
              },
            )
            as List<dynamic>;
    final users = response
        .map(
          (row) => LeaderboardUser.fromSupabase(
            Map<String, dynamic>.from(row as Map),
            currentUserId,
          ),
        )
        .toList();
    users.sort((a, b) => b.score.compareTo(a.score));
    return users;
  }
}
