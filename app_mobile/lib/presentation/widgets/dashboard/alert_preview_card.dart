import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../status/status_badge.dart';

class AlertPreviewCard extends StatelessWidget {
  final String title;
  final String message;
  final String level;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;

  const AlertPreviewCard({
    super.key,
    required this.title,
    required this.message,
    required this.level,
    this.onTap,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final Color levelColor = _levelColor(level);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: levelColor.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: levelColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    StatusBadge(
                      label: level,
                      variant: _variant(level),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (onTap != null || onResolve != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (onTap != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onTap,
                            icon: const Icon(Icons.visibility_rounded, size: 16),
                            label: const Text('Voir'),
                          ),
                        ),
                      if (onTap != null && onResolve != null)
                        const SizedBox(width: AppSpacing.sm),
                      if (onResolve != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onResolve,
                            icon: const Icon(Icons.task_alt_rounded, size: 16),
                            label: const Text('Résoudre'),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusBadgeVariant _variant(String value) {
    switch (value.toLowerCase()) {
      case 'critique':
        return StatusBadgeVariant.danger;
      case 'warning':
        return StatusBadgeVariant.warning;
      case 'info':
        return StatusBadgeVariant.info;
      default:
        return StatusBadgeVariant.neutral;
    }
  }

  Color _levelColor(String value) {
    switch (value.toLowerCase()) {
      case 'critique':
        return AppColors.alertCritical;
      case 'warning':
        return AppColors.alertWarning;
      case 'info':
        return AppColors.alertInfo;
      default:
        return AppColors.warning;
    }
  }
}
