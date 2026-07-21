import 'dart:math';

import '../data/local_questions.dart';
import '../models/quiz_question.dart';
import 'local_storage_service.dart';

class QuestionService {
  QuestionService(this._storage, {Random? random})
    : _random = random ?? Random();

  final LocalStorageService _storage;
  final Random _random;

  Future<List<QuizQuestion>> getQuestions({
    required String categoryId,
    required QuizDifficulty difficulty,
    required int count,
  }) async {
    final pool = localQuestions
        .where(
          (question) =>
              question.isActive &&
              question.categoryId == categoryId &&
              question.difficulty == difficulty,
        )
        .toList();
    if (pool.length < count) {
      throw StateError('No hay suficientes preguntas para esta configuración.');
    }

    final storageKey = '${categoryId}_${difficulty.name}';
    final usedByPool = _storage.loadUsedQuestionIds();
    final used = usedByPool[storageKey] ?? <String>[];
    final available =
        pool.where((question) => !used.contains(question.id)).toList()
          ..shuffle(_random);
    final selected = <QuizQuestion>[];

    if (available.length >= count) {
      selected.addAll(available.take(count));
      used.addAll(selected.map((question) => question.id));
    } else {
      selected.addAll(available);
      final selectedIds = selected.map((question) => question.id).toSet();
      final newCycle =
          pool.where((question) => !selectedIds.contains(question.id)).toList()
            ..shuffle(_random);
      final fromNewCycle = newCycle.take(count - selected.length).toList();
      selected.addAll(fromNewCycle);
      used
        ..clear()
        ..addAll(fromNewCycle.map((question) => question.id));
    }

    usedByPool[storageKey] = used;
    await _storage.saveUsedQuestionIds(usedByPool);
    return selected;
  }
}
