import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';

class ParkingLegend extends StatelessWidget {
  final bool showDisabled;

  const ParkingLegend({
    super.key,
    this.showDisabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_LegendData>[
      const _LegendData(
        label: 'Libre',
        color: AppColors.parkingFree,
      ),
      const _LegendData(
        label: 'Occupée',
        color: AppColors.parkingOccupied,
      ),
      const _LegendData(
        label: 'Réservée',
        color: AppColors.parkingReserved,
      ),
      if (showDisabled)
        const _LegendData(
          label: 'Indisponible',
          color: AppColors.parkingDisabled,
        ),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: items
          .map(
            (item) => _LegendItem(
              label: item.label,
              color: item.color,
            ),
          )
          .toList(),
    );
  }
}

class _LegendData {
  final String label;
  final Color color;

  const _LegendData({
    required this.label,
    required this.color,
  });
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
