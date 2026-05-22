import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';

enum StatusBadgeVariant {
  success,
  warning,
  danger,
  info,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final _StatusStyle style = _resolveStyle();

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: style.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: style.foregroundColor,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: style.foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _resolveStyle() {
    switch (variant) {
      case StatusBadgeVariant.success:
        return _StatusStyle(
          backgroundColor: AppColors.success.withValues(alpha: 0.12),
          foregroundColor: AppColors.success,
          borderColor: AppColors.success.withValues(alpha: 0.24),
        );

      case StatusBadgeVariant.warning:
        return _StatusStyle(
          backgroundColor: AppColors.warning.withValues(alpha: 0.12),
          foregroundColor: AppColors.warning,
          borderColor: AppColors.warning.withValues(alpha: 0.24),
        );

      case StatusBadgeVariant.danger:
        return _StatusStyle(
          backgroundColor: AppColors.danger.withValues(alpha: 0.12),
          foregroundColor: AppColors.danger,
          borderColor: AppColors.danger.withValues(alpha: 0.24),
        );

      case StatusBadgeVariant.info:
        return _StatusStyle(
          backgroundColor: AppColors.info.withValues(alpha: 0.12),
          foregroundColor: AppColors.info,
          borderColor: AppColors.info.withValues(alpha: 0.24),
        );

      case StatusBadgeVariant.neutral:
        return _StatusStyle(
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textSecondary,
          borderColor: AppColors.border,
        );
    }
  }
}

class _StatusStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  _StatusStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });
}
