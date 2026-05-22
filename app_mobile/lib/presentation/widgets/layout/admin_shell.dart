import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme_extensions.dart';
import 'admin_sidebar.dart';
import 'admin_topbar.dart';

class AdminShell extends StatelessWidget {
  final String currentRoute;
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? topbarActions;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;
  final bool scrollable;

  const AdminShell({
    super.key,
    required this.currentRoute,
    required this.title,
    this.subtitle,
    required this.body,
    this.topbarActions,
    this.floatingActionButton,
    this.onRefresh,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: floatingActionButton,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool showSidebar = constraints.maxWidth >= 1100;
          final bool tabletSidebar = constraints.maxWidth >= 900;

          final Widget content = Column(
            children: [
              AdminTopbar(
                title: title,
                subtitle: subtitle,
                actions: topbarActions,
                showMenuButton: !showSidebar,
              ),
              Expanded(
                child: _AdminContentContainer(
                  onRefresh: onRefresh,
                  scrollable: scrollable,
                  child: body,
                ),
              ),
            ],
          );

          if (showSidebar) {
            return Row(
              children: [
                AdminSidebar(currentRoute: currentRoute),
                Expanded(
                  child: SafeArea(child: content),
                ),
              ],
            );
          }

          if (tabletSidebar) {
            return Row(
              children: [
                AdminSidebar(
                  currentRoute: currentRoute,
                  compact: true,
                ),
                Expanded(
                  child: SafeArea(child: content),
                ),
              ],
            );
          }

          return SafeArea(
            child: Scaffold(
              backgroundColor: colors.background,
              drawer: Drawer(
                backgroundColor: colors.surface,
                child: AdminSidebar(
                  currentRoute: currentRoute,
                  isDrawer: true,
                ),
              ),
              body: content,
            ),
          );
        },
      ),
    );
  }
}

class _AdminContentContainer extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;
  final bool scrollable;

  const _AdminContentContainer({
    required this.child,
    required this.onRefresh,
    required this.scrollable,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (scrollable) {
      content = ListView(
        physics: onRefresh != null
            ? const AlwaysScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: child,
            ),
          ),
        ],
      );

      if (onRefresh != null) {
        content = RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: onRefresh!,
          child: content,
        );
      }
    } else {
      content = Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: child,
          ),
        ),
      );
    }

    return content;
  }
}

class AdminNavigationItem {
  final String label;
  final String route;
  final IconData icon;

  const AdminNavigationItem({
    required this.label,
    required this.route,
    required this.icon,
  });
}

List<AdminNavigationItem> adminNavigationItems(BuildContext context) => [
      AdminNavigationItem(
        label: context.t.text('nav.dashboard'),
        route: RouteNames.dashboard,
        icon: Icons.dashboard_rounded,
      ),
      AdminNavigationItem(
        label: context.t.text('nav.parking'),
        route: RouteNames.adminParking,
        icon: Icons.local_parking_rounded,
      ),
      AdminNavigationItem(
        label: context.t.text('nav.vehicles'),
        route: RouteNames.adminVehicles,
        icon: Icons.directions_car_filled_rounded,
      ),
      AdminNavigationItem(
        label: context.t.text('nav.alerts'),
        route: RouteNames.adminAlerts,
        icon: Icons.warning_amber_rounded,
      ),
      AdminNavigationItem(
        label: context.t.text('nav.payments'),
        route: RouteNames.adminPayments,
        icon: Icons.payments_rounded,
      ),
      AdminNavigationItem(
        label: context.t.text('nav.statistics'),
        route: RouteNames.adminStatistics,
        icon: Icons.insights_rounded,
      ),
      AdminNavigationItem(
        label: context.t.text('IoT'),
        route: RouteNames.adminIotDashboard,
        icon: Icons.sensors_rounded,
        ),
      AdminNavigationItem(
        label: context.t.text('nav.settings'),
        route: RouteNames.adminSettings,
        icon: Icons.settings_rounded,
      ),
    ];
