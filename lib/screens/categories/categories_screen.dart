import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/local_questions.dart';
import '../../models/quiz_category.dart';
import '../../providers/profile_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/category_card.dart';
import '../../widgets/quiz_settings_sheet.dart';
import '../../widgets/score_badge.dart';
import '../quiz/quiz_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isStarting = false;

  Future<void> _openSettings(QuizCategory category) async {
    final settings = await QuizSettingsSheet.show(context, category.name);
    if (settings == null || !mounted) return;
    setState(() => _isStarting = true);
    try {
      await context.read<QuizProvider>().startQuiz(
        category: category,
        difficulty: settings.difficulty,
        questionCount: settings.questionCount,
      );
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = context.watch<ProfileProvider>().user.totalScore;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ScoreBadge(score: score),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            itemCount: quizCategories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Elige una categoría',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Selecciona el tema sobre el que quieres jugar.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }
              final category = quizCategories[index - 1];
              return CategoryCard(
                category: category,
                onTap: () => _openSettings(category),
              );
            },
          ),
          if (_isStarting)
            const ColoredBox(
              color: Color(0x55000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
