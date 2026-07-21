import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/quiz_question.dart';
import 'primary_button.dart';

class QuizSettings {
  const QuizSettings(this.difficulty, this.questionCount);
  final QuizDifficulty difficulty;
  final int questionCount;
}

class QuizSettingsSheet extends StatefulWidget {
  const QuizSettingsSheet({super.key, required this.categoryName});
  final String categoryName;

  static Future<QuizSettings?> show(
    BuildContext context,
    String categoryName,
  ) => showModalBottomSheet<QuizSettings>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => QuizSettingsSheet(categoryName: categoryName),
  );

  @override
  State<QuizSettingsSheet> createState() => _QuizSettingsSheetState();
}

class _QuizSettingsSheetState extends State<QuizSettingsSheet> {
  QuizDifficulty _difficulty = QuizDifficulty.easy;
  int _count = 5;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.categoryName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text('Configura tu desafío'),
            const SizedBox(height: 24),
            const Text(
              'Dificultad',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: QuizDifficulty.values
                  .map(
                    (difficulty) => ChoiceChip(
                      label: Text(
                        '${difficulty.label} · ${difficulty.basePoints} pts',
                      ),
                      selected: _difficulty == difficulty,
                      selectedColor: const Color(0xFFE7ECFF),
                      onSelected: (_) =>
                          setState(() => _difficulty = difficulty),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cantidad de preguntas',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 5, label: Text('5 preguntas')),
                ButtonSegment(value: 10, label: Text('10 preguntas')),
              ],
              selected: {_count},
              onSelectionChanged: (value) =>
                  setState(() => _count = value.first),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Comenzar quiz',
              icon: Icons.play_arrow_rounded,
              onPressed: () =>
                  Navigator.pop(context, QuizSettings(_difficulty, _count)),
            ),
          ],
        ),
      ),
    );
  }
}
