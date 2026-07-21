import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AnswerOptionCard extends StatelessWidget {
  const AnswerOptionCard({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.isAnswered,
    required this.isCorrect,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool isSelected;
  final bool isAnswered;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var borderColor = isSelected ? AppColors.primary : AppColors.outline;
    var background = Colors.white;
    IconData? trailing;
    if (isAnswered && isCorrect) {
      borderColor = AppColors.success;
      background = const Color(0xFFECFDF3);
      trailing = Icons.check_circle_rounded;
    } else if (isAnswered && isSelected) {
      borderColor = AppColors.error;
      background = const Color(0xFFFEF2F2);
      trailing = Icons.cancel_rounded;
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isAnswered ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: borderColor.withValues(alpha: .12),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: borderColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) Icon(trailing, color: borderColor),
            ],
          ),
        ),
      ),
    );
  }
}
