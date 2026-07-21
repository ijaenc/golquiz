import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score, this.suffix = 'pts'});
  final int score;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            '$score $suffix',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
