import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_extensions.dart';
import 'admin_shell.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final bool compact;
  final bool isDrawer;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    this.compact = false,
    this.isDrawer = false,
  });

  bool _isRouteActive(String route) {
    if (currentRoute == route) return true;

    // Dashboard doit matcher uniquement lui-même
    if (route == RouteNames.dashboard) {
      return currentRoute == RouteNames.dashboard;
    }

    // Parking doit rester actif pour overview + spots + grid
    if (route == RouteNames.adminParking) {
      return currentRoute == RouteNames.adminParking ||
          currentRoute == RouteNames.adminParkingSpots ||
          currentRoute == RouteNames.adminParkingGrid;
    }

    return currentRoute.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final double sidebarWidth = compact ? 92 : AppSpacing.sidebarWidth;
    final items = adminNavigationItems(context);

    return Container(
      width: isDrawer ? double.infinity : sidebarWidth,
      color: colors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Text(
              AppStrings.appName,
              style: AppTextStyles.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.t.text('sidebar.subtitle'),
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textMuted,
              ),
            ),
          ] else ...[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                Icons.local_parking_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = _isRouteActive(item.route);

                return _SidebarNavItem(
                  label: item.label,
                  icon: item.icon,
                  isActive: isActive,
                  compact: compact,
                  onTap: () {
                    if (isDrawer && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }

                    if (currentRoute == item.route) return;

                    Navigator.pushReplacementNamed(context, item.route);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: colors.border),
            ),
            child: compact
                ? Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'AD',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              context.t.text('sidebar.fullAccess'),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool compact;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;
    final Color color = isActive ? primary : colors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isActive
                  ? primary.withValues(alpha: 0.24)
                  : Colors.transparent,
            ),
          ),
          child: compact
              ? Center(
                  child: Icon(icon, color: color, size: 22),
                )
              : Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: color,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
