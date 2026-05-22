import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../status/status_badge.dart';

class ParkingSpotTile extends StatelessWidget {
  final String numero;
  final String statut;
  final int? id;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ParkingSpotTile({
    super.key,
    required this.numero,
    required this.statut,
    this.id,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(statut);
    final IconData statusIcon = _statusIcon(statut);

    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  numero,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 26,
            ),
          ),
          const Spacer(),
          if (id != null) ...[
            Text(
              'ID $id',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
          ],
          if (subtitle != null) ...[
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          StatusBadge(
            label: statut,
            variant: _statusVariant(statut),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: content,
      ),
    );
  }

  StatusBadgeVariant _statusVariant(String status) {
    switch (status.toLowerCase()) {
      case 'libre':
        return StatusBadgeVariant.success;
      case 'occupée':
      case 'occupee':
        return StatusBadgeVariant.danger;
      case 'réservée':
      case 'reservee':
        return StatusBadgeVariant.info;
      case 'indisponible':
      case 'disabled':
        return StatusBadgeVariant.neutral;
      default:
        return StatusBadgeVariant.neutral;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'libre':
        return AppColors.parkingFree;
      case 'occupée':
      case 'occupee':
        return AppColors.parkingOccupied;
      case 'réservée':
      case 'reservee':
        return AppColors.parkingReserved;
      case 'indisponible':
      case 'disabled':
        return AppColors.parkingDisabled;
      default:
        return AppColors.grey400;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'libre':
        return Icons.check_circle_rounded;
      case 'occupée':
      case 'occupee':
        return Icons.directions_car_filled_rounded;
      case 'réservée':
      case 'reservee':
        return Icons.bookmark_rounded;
      case 'indisponible':
      case 'disabled':
        return Icons.block_rounded;
      default:
        return Icons.local_parking_rounded;
    }
  }
}
