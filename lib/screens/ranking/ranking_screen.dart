import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/responsive_layout.dart';
import '../../data/local_questions.dart';
import '../../models/leaderboard_user.dart';
import '../../models/quiz_question.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ranking_provider.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RankingProvider>().refreshGlobal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.background,
              child: ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ranking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        auth.isDemo
                            ? 'Datos locales de demostración'
                            : 'Compite con la comunidad GolQuiz',
                        style: const TextStyle(color: Color(0xFFCBD5E1)),
                      ),
                      const SizedBox(height: 16),
                      const TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Color(0xFF94A3B8),
                        indicatorColor: AppColors.secondary,
                        tabs: [
                          Tab(text: 'Puntaje total'),
                          Tab(text: 'Mejor quiz'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [_GlobalRankingTab(), _QuizRankingTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalRankingTab extends StatelessWidget {
  const _GlobalRankingTab();

  @override
  Widget build(BuildContext context) {
    final ranking = context.watch<RankingProvider>();
    return _RankingBody(
      users: ranking.globalUsers,
      isLoading: ranking.isLoading,
      error: ranking.error,
      onRefresh: ranking.refreshGlobal,
      emptyMessage: 'Todavía no hay jugadores en el ranking.',
    );
  }
}

class _QuizRankingTab extends StatefulWidget {
  const _QuizRankingTab();

  @override
  State<_QuizRankingTab> createState() => _QuizRankingTabState();
}

class _QuizRankingTabState extends State<_QuizRankingTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RankingProvider>().refreshQuiz();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ranking = context.watch<RankingProvider>();
    return Column(
      children: [
        ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DropdownButton<String>(
                  value: ranking.categoryId,
                  items: quizCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) ranking.setFilters(categoryId: value);
                  },
                ),
                DropdownButton<QuizDifficulty>(
                  value: ranking.difficulty,
                  items: QuizDifficulty.values
                      .map(
                        (difficulty) => DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) ranking.setFilters(difficulty: value);
                  },
                ),
                DropdownButton<int>(
                  value: ranking.questionCount,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 preguntas')),
                    DropdownMenuItem(value: 10, child: Text('10 preguntas')),
                  ],
                  onChanged: (value) {
                    if (value != null) ranking.setFilters(questionCount: value);
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _RankingBody(
            users: ranking.quizUsers,
            isLoading: ranking.isLoading,
            error: ranking.error,
            onRefresh: ranking.refreshQuiz,
            showDate: true,
            emptyMessage: 'No hay intentos para esta combinación.',
          ),
        ),
      ],
    );
  }
}

class _RankingBody extends StatelessWidget {
  const _RankingBody({
    required this.users,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.emptyMessage,
    this.showDate = false,
  });

  final List<LeaderboardUser> users;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final String emptyMessage;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    if (isLoading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && users.isEmpty) {
      return _RankingMessage(
        icon: Icons.cloud_off_rounded,
        message: error!,
        onRetry: onRefresh,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: users.isEmpty
          ? ListView(
              children: [
                SizedBox(height: 220, child: Center(child: Text(emptyMessage))),
              ],
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                ResponsiveLayout.pagePadding(context),
                18,
                ResponsiveLayout.pagePadding(context),
                28,
              ),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _RankingTile(
                user: users[index],
                position: index + 1,
                showDate: showDate,
              ),
            ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({
    required this.user,
    required this.position,
    required this.showDate,
  });
  final LeaderboardUser user;
  final int position;
  final bool showDate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: user.isCurrentUser ? const Color(0xFFE7ECFF) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: user.isCurrentUser ? AppColors.primary : AppColors.outline,
      ),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            '$position',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: position <= 3
                  ? AppColors.warning
                  : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          backgroundColor: user.isCurrentUser
              ? AppColors.primary
              : AppColors.backgroundLight,
          child: Text(
            user.initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
              if (showDate && user.completedAt != null)
                Text(
                  '${user.completedAt!.day}/${user.completedAt!.month}/${user.completedAt!.year}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Text(
          '${user.score} pts',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _RankingMessage extends StatelessWidget {
  const _RankingMessage({
    required this.icon,
    required this.message,
    required this.onRetry,
  });
  final IconData icon;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 46, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}
