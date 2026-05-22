import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';

class ParkingLevelTabItem {
  final int value;
  final String label;

  const ParkingLevelTabItem({
    required this.value,
    required this.label,
  });
}

class ParkingLevelTabs extends StatelessWidget {
  final int selectedLevel;
  final List<ParkingLevelTabItem> items;
  final ValueChanged<int> onChanged;

  const ParkingLevelTabs({
    super.key,
    required this.selectedLevel,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items.map((item) {
        final bool selected = item.value == selectedLevel;

        return InkWell(
          onTap: () => onChanged(item.value),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.16)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              item.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
