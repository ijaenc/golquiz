import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../categories/categories_screen.dart';
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

  void _changeCategory() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = context.watch<QuizProvider>().lastResult;
    final finishError = context.watch<QuizProvider>().finishError;
    final profile = context.watch<ProfileProvider>();
    final syncError = profile.syncError;
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
    final maximumBaseScore =
        result.questionCount * result.difficulty.basePoints;

    final pointsDifference = maximumBaseScore - result.score;

    final performanceMessage = switch (percentage) {
      >= 90 => 'Dominaste esta categoría',
      >= 70 => 'Tu rendimiento fue muy bueno',
      >= 50 => 'Vas por buen camino',
      _ => 'Sigue jugando para mejorar',
    };

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
                performanceMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
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
              _ResultSummaryCard(
                percentage: percentage,
                score: result.score,
                baseScore: maximumBaseScore,
                pointsDifference: pointsDifference,
              ),
              const SizedBox(height: 20),
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
              if (profile.isSyncing) ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Sincronizando progreso...'),
                  ],
                ),
                const SizedBox(height: 14),
              ],
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
                if (syncError != null)
                  TextButton.icon(
                    onPressed: profile.isSyncing
                        ? null
                        : () => context.read<ProfileProvider>().syncResult(
                            result,
                          ),
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Reintentar sincronización'),
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
                onPressed: _changeCategory,
                icon: const Icon(Icons.category_rounded),
                label: const Text('Cambiar categoría'),
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

class _ResultSummaryCard extends StatelessWidget {
  const _ResultSummaryCard({
    required this.percentage,
    required this.score,
    required this.baseScore,
    required this.pointsDifference,
  });

  final int percentage;
  final int score;
  final int baseScore;
  final int pointsDifference;

  @override
  Widget build(BuildContext context) {
    final earnedBonus = score > baseScore;
    final difference = pointsDifference.abs();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, color: AppColors.primary),
              SizedBox(width: 9),
              Text(
                'Resumen de la partida',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SummaryRow(label: 'Precisión', value: '$percentage%'),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Puntaje obtenido', value: '$score pts'),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Puntos base posibles', value: '$baseScore pts'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: earnedBonus
                  ? const Color(0xFFECFDF3)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              earnedBonus
                  ? 'Obtuviste $difference puntos extra gracias a tus rachas.'
                  : difference == 0
                  ? 'Conseguiste todos los puntos base disponibles.'
                  : 'Te faltaron $difference puntos para completar el puntaje base.',
              style: TextStyle(
                color: earnedBonus
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
