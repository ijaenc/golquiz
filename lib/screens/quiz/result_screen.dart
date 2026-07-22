import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/responsive_layout.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/primary_button.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLoading = false;

  Future<void> _replay() async {
    setState(() => _isLoading = true);
    await context.read<QuizProvider>().replay();
    if (!mounted) return;
    setState(() => _isLoading = false);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
  }

  void _goHome() => Navigator.of(context).popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    final result = context.watch<QuizProvider>().lastResult;
    final finishError = context.watch<QuizProvider>().finishError;
    final syncError = context.watch<ProfileProvider>().syncError;
    if (result == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: _goHome,
            child: const Text('Volver al inicio'),
          ),
        ),
      );
    }
    final percentage = (result.accuracy * 100).round();
    final message = percentage >= 80
        ? '¡Muy bien!'
        : percentage >= 50
        ? '¡Buen intento!'
        : '¡Sigue practicando!';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ResponsiveContent(
          padding: EdgeInsets.zero,
          child: ListView(
            padding: EdgeInsets.all(ResponsiveLayout.pagePadding(context)),
            children: [
              const SizedBox(height: 12),
              const Text(
                'Resultados',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 28),
              Center(
                child: SizedBox.square(
                  dimension: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.square(
                        dimension: 190,
                        child: CircularProgressIndicator(
                          value: result.accuracy,
                          strokeWidth: 15,
                          backgroundColor: AppColors.outline,
                          color: AppColors.secondary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: AppColors.warning,
                            size: 34,
                          ),
                          Text(
                            '${result.correctAnswers}/${result.questionCount}',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${result.score} pts',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${result.categoryName} · ${result.difficulty.label} · $percentage% de acierto',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _ResultMetric(
                      icon: Icons.check_rounded,
                      value: '${result.correctAnswers}',
                      label: 'Correctas',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ResultMetric(
                      icon: Icons.close_rounded,
                      value: '${result.incorrectAnswers}',
                      label: 'Incorrectas',
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ResultMetric(
                      icon: Icons.local_fire_department_rounded,
                      value: '${result.bestStreak}',
                      label: 'Mejor racha',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (finishError != null || syncError != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Text(finishError ?? syncError!),
                ),
                const SizedBox(height: 14),
              ],
              PrimaryButton(
                label: 'Jugar de nuevo',
                icon: Icons.replay_rounded,
                isLoading: _isLoading,
                onPressed: _replay,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.home_rounded),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.outline),
    ),
    child: Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
