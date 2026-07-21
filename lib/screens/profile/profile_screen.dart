import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/responsive_layout.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 28,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre visible'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && context.mounted) {
      await context.read<ProfileProvider>().updateName(name);
    }
  }

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reiniciar progreso'),
        content: const Text(
          'Se borrarán puntajes, métricas y el historial de preguntas. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ProfileProvider>().resetProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>().user;
    final auth = context.watch<AuthProvider>();
    final records =
        user.bestScores.entries
            .where(
              (entry) =>
                  !entry.key.startsWith('category_') &&
                  !entry.key.startsWith('difficulty_') &&
                  !entry.key.startsWith('count_'),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return SafeArea(
      child: ResponsiveContent(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveLayout.pagePadding(context),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        auth.isDemo
                            ? 'Usuario demo local'
                            : (user.email ?? 'Cuenta GolQuiz'),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editName(context, user.name),
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Editar nombre',
                ),
              ],
            ),
            const SizedBox(height: 26),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: [
                _ProfileMetric(
                  label: 'Puntos totales',
                  value: '${user.totalScore}',
                ),
                _ProfileMetric(label: 'Partidas', value: '${user.gamesPlayed}'),
                _ProfileMetric(
                  label: 'Correctas',
                  value: '${user.correctAnswers}',
                ),
                _ProfileMetric(
                  label: 'Incorrectas',
                  value: '${user.incorrectAnswers}',
                ),
                _ProfileMetric(
                  label: 'Acierto',
                  value: '${(user.accuracy * 100).round()}%',
                ),
                _ProfileMetric(
                  label: 'Mejor racha',
                  value: '${user.bestStreak}',
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Mejores resultados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (records.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Juega tu primer quiz para registrar un récord.'),
                ),
              )
            else
              ...records
                  .take(6)
                  .map(
                    (entry) => Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.warning,
                        ),
                        title: Text(_formatRecord(entry.key)),
                        trailing: Text(
                          '${entry.value} pts',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _editName(context, user.name),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Editar nombre'),
            ),
            if (auth.isDemo)
              OutlinedButton.icon(
                onPressed: () => _reset(context),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reiniciar datos locales'),
              ),
            if (context.watch<ProfileProvider>().error != null)
              Text(
                context.watch<ProfileProvider>().error!,
                style: const TextStyle(color: AppColors.error),
              ),
            TextButton.icon(
              onPressed: () => context.read<AuthProvider>().signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: Text(auth.isDemo ? 'Cerrar sesión demo' : 'Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRecord(String key) {
    final parts = key.split('_');
    if (parts.length < 3) return key;
    final count = parts.removeLast();
    final difficulty = parts.removeLast();
    final category = parts
        .join(' ')
        .replaceAll('world cups', 'Mundiales')
        .replaceAll('national teams', 'Selecciones')
        .replaceAll('world cup 2026', 'Mundial 2026')
        .replaceAll('players', 'Jugadores')
        .replaceAll('general', 'Fútbol general');
    final difficultyLabel = switch (difficulty) {
      'easy' => 'Fácil',
      'medium' => 'Media',
      _ => 'Difícil',
    };
    return '$category · $difficultyLabel · $count';
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.outline),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}
