import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'admin_shell.dart';

class DashboardShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final Widget? headerTrailing;
  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry padding;
  final bool safeArea;
  final bool scrollable;

  const DashboardShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.headerTrailing,
    this.onRefresh,
    this.padding = const EdgeInsets.all(AppSpacing.screenHorizontal),
    this.safeArea = true,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = scrollable
        ? ListView(
            physics: onRefresh != null
                ? const AlwaysScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            padding: padding,
            children: [
              _DashboardShellHeader(
                title: title,
                subtitle: subtitle,
                actions: actions,
                trailing: headerTrailing,
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              child,
            ],
          )
        : Padding(
            padding: padding,
            child: Column(
              children: [
                _DashboardShellHeader(
                  title: title,
                  subtitle: subtitle,
                  actions: actions,
                  trailing: headerTrailing,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Expanded(child: child),
              ],
            ),
          );

    if (onRefresh != null && scrollable) {
      content = RefreshIndicator(
        color: AppColors.primary,
        onRefresh: onRefresh!,
        child: content,
      );
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: content,
    );
  }
}

class AdminModuleShell extends StatelessWidget {
  final String currentRoute;
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;
  final bool scrollable;

  const AdminModuleShell({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
    this.onRefresh,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: currentRoute,
      title: title,
      subtitle: subtitle,
      onRefresh: onRefresh,
      scrollable: scrollable,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardShellHeader(
            title: title,
            subtitle: subtitle,
            actions: actions,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          child,
        ],
      ),
    );
  }
}

class _DashboardShellHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? trailing;

  const _DashboardShellHeader({
    required this.title,
    this.subtitle,
    this.actions,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.displaySmall,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}
