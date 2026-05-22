import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';

class SummaryBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;
  final Widget? trailing;
  final bool loading;

  const SummaryBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge,
    this.trailing,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D1A2B),
            Color(0xFF10253C),
            Color(0xFF123252),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 900;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                title,
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (loading) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Actualisation en cours...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );

          if (compact || trailing == null) {
            return left;
          }

          return Row(
            children: [
              Expanded(flex: 6, child: left),
              const SizedBox(width: AppSpacing.xl),
              Expanded(flex: 4, child: trailing!),
            ],
          );
        },
      ),
    );
  }
}
