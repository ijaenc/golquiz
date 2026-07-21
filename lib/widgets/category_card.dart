import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/quiz_category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.onTap});
  final QuizCategory category;
  final VoidCallback onTap;

  IconData get _icon => switch (category.iconName) {
    'trophy' => Icons.emoji_events_rounded,
    'person' => Icons.sports_rounded,
    'flag' => Icons.flag_rounded,
    'public' => Icons.public_rounded,
    _ => Icons.sports_soccer_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return Card(
      child: InkWell(
        onTap: category.isActive ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
