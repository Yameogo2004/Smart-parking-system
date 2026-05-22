import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_extensions.dart';

class AdminTopbar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showMenuButton;

  const AdminTopbar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showMenuButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: AppSpacing.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(color: colors.border),
        ),
      ),
      child: Row(
        children: [
          if (showMenuButton) ...[
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu_rounded, color: colors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actions!,
            ),
          ],
          const SizedBox(width: AppSpacing.md),
          _TopbarIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _TopbarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopbarIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: colors.border),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
