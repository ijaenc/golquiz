import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/responsive_layout.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/answer_option_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/score_badge.dart';
import 'result_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  Future<void> _continue(BuildContext context) async {
    final finished = await context.read<QuizProvider>().nextQuestion();
    if (finished && context.mounted) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final question = quiz.currentQuestion;
    if (question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isCorrect =
        quiz.isAnswered &&
        quiz.selectedAnswerIndex == question.correctAnswerIndex;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Pregunta ${quiz.currentIndex + 1} de ${quiz.questions.length}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ScoreBadge(score: quiz.score, suffix: ''),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          padding: EdgeInsets.zero,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              ResponsiveLayout.pagePadding(context),
              8,
              ResponsiveLayout.pagePadding(context),
              28,
            ),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: quiz.progress,
                  minHeight: 10,
                  backgroundColor: AppColors.outline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Chip(
                    avatar: const Icon(Icons.sports_soccer, size: 16),
                    label: Text(quiz.category?.name ?? 'GolQuiz'),
                  ),
                  const Spacer(),
                  Text(
                    quiz.difficulty.label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                constraints: const BoxConstraints(minHeight: 150),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      question.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (quiz.currentStreak >= 2) ...[
                      const SizedBox(height: 16),
                      Text(
                        '🔥 Racha x${quiz.currentStreak}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < question.options.length; index++) ...[
                AnswerOptionCard(
                  index: index,
                  text: question.options[index],
                  isSelected: quiz.selectedAnswerIndex == index,
                  isAnswered: quiz.isAnswered,
                  isCorrect: question.correctAnswerIndex == index,
                  onTap: () => context.read<QuizProvider>().selectAnswer(index),
                ),
                const SizedBox(height: 10),
              ],
              if (quiz.isAnswered) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? const Color(0xFFECFDF3)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect ? AppColors.success : AppColors.error,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: isCorrect
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCorrect
                                ? '¡Respuesta correcta!'
                                : 'Respuesta incorrecta',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isCorrect
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(question.explanation),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: quiz.currentIndex == quiz.questions.length - 1
                      ? 'Ver resultados'
                      : 'Siguiente pregunta',
                  isLoading: quiz.isLoading,
                  onPressed: () => _continue(context),
                ),
              ] else
                PrimaryButton(
                  label: 'Responder',
                  icon: Icons.check_rounded,
                  onPressed: quiz.selectedAnswerIndex == null
                      ? null
                      : context.read<QuizProvider>().submitAnswer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
