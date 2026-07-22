import 'dart:async';

import '../models/quiz_result.dart';
import 'supabase_service.dart';

class QuizAttemptService {
  const QuizAttemptService(this._supabase);

  final SupabaseService _supabase;
  bool get isConfigured => _supabase.isConfigured;

  Future<bool> recordAttempt(QuizResult result) async {
    final attemptId = result.attemptId;
    if (!_supabase.isConfigured || attemptId == null) return false;
    if (_supabase.client!.auth.currentUser == null) {
      throw StateError('La sesión de Supabase no está activa.');
    }
    final response = await _supabase.client!
        .rpc(
          'record_quiz_attempt',
          params: {
            'p_client_attempt_id': attemptId,
            'p_category_id': result.categoryId,
            'p_difficulty': result.difficulty.name,
            'p_question_count': result.questionCount,
            'p_score': result.score,
            'p_correct_answers': result.correctAnswers,
            'p_incorrect_answers': result.incorrectAnswers,
            'p_best_streak': result.bestStreak,
          },
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw TimeoutException(
            'Supabase tardó demasiado en guardar la partida.',
          ),
        );
    return response == true;
  }
}
