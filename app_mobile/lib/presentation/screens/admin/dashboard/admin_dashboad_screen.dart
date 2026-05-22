import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/dashboard/metric_card.dart';
import '../../../widgets/dashboard/summary_banner.dart';
import '../../../widgets/layout/admin_shell.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      context.read<AdminProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        if (adminProvider.isLoading && adminProvider.dashboardData.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (adminProvider.errorMessage != null &&
            adminProvider.dashboardData.isEmpty) {
          return _AdminErrorState(
            message: adminProvider.errorMessage!,
            onRetry: adminProvider.loadDashboard,
          );
        }

        final dashboard = adminProvider.dashboardData;

        final int totalPlaces = _toInt(dashboard['total_places']);
        final int occupiedPlaces = _toInt(dashboard['occupied_places']);
        final int freePlaces = _toInt(dashboard['free_places']);
        final int reservedPlaces = _toInt(dashboard['reserved_places']);

        final int totalVehicles = adminProvider.vehicules.length;
        final int totalPayments = adminProvider.paiements.length;
        final int totalSensors = adminProvider.capteurs.length;
        final int activeStationnements =
            _toInt(dashboard['active_stationnements']);

        final double occupancyRate = totalPlaces > 0
            ? (occupiedPlaces / totalPlaces) * 100
            : 0;

        return AdminShell(
          currentRoute: RouteNames.dashboard,
          title: 'Operations Dashboard',
          subtitle: 'Supervision en temps réel du parking intelligent',
          onRefresh: adminProvider.refreshDashboard,
          topbarActions: [
            _SystemStatusPill(
              isRefreshing: adminProvider.isRefreshing,
            ),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SummaryBanner(
                badge: 'LIVE OVERVIEW',
                title: 'Pilotage temps réel du parking',
                subtitle:
                    'Vue synthétique des capacités, du taux d’occupation, des équipements critiques et de l’activité en cours.',
                loading: adminProvider.isRefreshing,
                trailing: _HeroMetricsPanel(
                  freePlaces: freePlaces,
                  occupiedPlaces: occupiedPlaces,
                  occupancyRate: occupancyRate,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              const Text(
                'Indicateurs principaux',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              _ResponsiveMetricGrid(
                children: [
                  MetricCard(
                    title: 'Places libres',
                    value: '$freePlaces',
                    subtitle: 'Disponibles immédiatement',
                    icon: Icons.check_circle_rounded,
                    accentColor: AppColors.parkingFree,
                  ),
                  MetricCard(
                    title: 'Places occupées',
                    value: '$occupiedPlaces',
                    subtitle: '${occupancyRate.toStringAsFixed(1)}% d’occupation',
                    icon: Icons.directions_car_filled_rounded,
                    accentColor: AppColors.parkingOccupied,
                  ),
                  MetricCard(
                    title: 'Places réservées',
                    value: '$reservedPlaces',
                    subtitle: 'Affectées avant arrivée',
                    icon: Icons.bookmark_rounded,
                    accentColor: AppColors.warning,
                  ),
                  MetricCard(
                    title: 'Capacité totale',
                    value: '$totalPlaces',
                    subtitle: 'Ensemble des emplacements',
                    icon: Icons.local_parking_rounded,
                    accentColor: AppColors.primary,
                  ),
                  MetricCard(
                    title: 'Véhicules détectés',
                    value: '$totalVehicles',
                    subtitle: 'Présence et activité globale',
                    icon: Icons.directions_car_rounded,
                    accentColor: AppColors.info,
                  ),
                  MetricCard(
                    title: 'Capteurs actifs',
                    value: '$totalSensors',
                    subtitle:
                        '${adminProvider.totalCapteursOffline} en anomalie',
                    icon: Icons.sensors_rounded,
                    accentColor: AppColors.secondary,
                  ),
                  MetricCard(
                    title: 'Alertes critiques',
                    value: '${adminProvider.totalAlertesCritiques}',
                    subtitle: 'Incidents nécessitant attention',
                    icon: Icons.warning_amber_rounded,
                    accentColor: AppColors.alertCritical,
                  ),
                  MetricCard(
                    title: 'Ascenseur',
                    value: adminProvider.elevator?.statut ?? 'N/A',
                    subtitle: adminProvider.elevator != null
                        ? 'Niveau ${adminProvider.elevator!.niveauActuel}'
                        : 'État indisponible',
                    icon: Icons.elevator_rounded,
                    accentColor: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              const Text(
                'Vue opérationnelle',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              _OperationalOverviewSection(
                activeStationnements: activeStationnements,
                totalPayments: totalPayments,
                totalCriticalAlerts: adminProvider.totalAlertesCritiques,
                totalSensorsOffline: adminProvider.totalCapteursOffline,
                occupancyRate: occupancyRate,
                freePlaces: freePlaces,
                occupiedPlaces: occupiedPlaces,
                totalPlaces: totalPlaces,
                onOpenAlerts: () {
                  Navigator.pushNamed(context, RouteNames.adminAlerts);
                },
                onOpenParking: () {
                  Navigator.pushNamed(context, RouteNames.adminParking);
                },
                onOpenPayments: () {
                  Navigator.pushNamed(context, RouteNames.adminPayments);
                },
                onOpenStatistics: () {
                  Navigator.pushNamed(context, RouteNames.adminStatistics);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class _SystemStatusPill extends StatelessWidget {
  final bool isRefreshing;

  const _SystemStatusPill({
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isRefreshing ? AppColors.warning : AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isRefreshing ? 'Actualisation...' : 'Système en ligne',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricsPanel extends StatelessWidget {
  final int freePlaces;
  final int occupiedPlaces;
  final double occupancyRate;

  const _HeroMetricsPanel({
    required this.freePlaces,
    required this.occupiedPlaces,
    required this.occupancyRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroMiniCard(
          title: 'Disponibles',
          value: '$freePlaces',
          subtitle: 'Prêtes maintenant',
          accentColor: AppColors.parkingFree,
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        _HeroMiniCard(
          title: 'Occupation',
          value: '${occupancyRate.toStringAsFixed(1)}%',
          subtitle: '$occupiedPlaces places utilisées',
          accentColor: AppColors.parkingOccupied,
          icon: Icons.analytics_rounded,
        ),
      ],
    );
  }
}

class _HeroMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accentColor;
  final IconData icon;

  const _HeroMiniCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveMetricGrid extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveMetricGrid({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int count = 4;
        if (constraints.maxWidth < 1250) count = 3;
        if (constraints.maxWidth < 860) count = 2;
        if (constraints.maxWidth < 560) count = 1;

        final double ratio = count == 1 ? 2.7 : 1.18;

        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: AppSpacing.dashboardGridGap,
          mainAxisSpacing: AppSpacing.dashboardGridGap,
          childAspectRatio: ratio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

class _OperationalOverviewSection extends StatelessWidget {
  final int activeStationnements;
  final int totalPayments;
  final int totalCriticalAlerts;
  final int totalSensorsOffline;
  final double occupancyRate;
  final int freePlaces;
  final int occupiedPlaces;
  final int totalPlaces;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenParking;
  final VoidCallback onOpenPayments;
  final VoidCallback onOpenStatistics;

  const _OperationalOverviewSection({
    required this.activeStationnements,
    required this.totalPayments,
    required this.totalCriticalAlerts,
    required this.totalSensorsOffline,
    required this.occupancyRate,
    required this.freePlaces,
    required this.occupiedPlaces,
    required this.totalPlaces,
    required this.onOpenAlerts,
    required this.onOpenParking,
    required this.onOpenPayments,
    required this.onOpenStatistics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stacked = constraints.maxWidth < 1100;

        if (stacked) {
          return Column(
            children: [
              _OperationsControlCard(
                activeStationnements: activeStationnements,
                totalPayments: totalPayments,
                totalCriticalAlerts: totalCriticalAlerts,
                totalSensorsOffline: totalSensorsOffline,
                onOpenAlerts: onOpenAlerts,
                onOpenPayments: onOpenPayments,
                onOpenStatistics: onOpenStatistics,
              ),
              const SizedBox(height: AppSpacing.lg),
              _CapacityStatusCard(
                occupancyRate: occupancyRate,
                freePlaces: freePlaces,
                occupiedPlaces: occupiedPlaces,
                totalPlaces: totalPlaces,
                onOpenParking: onOpenParking,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _OperationsControlCard(
                activeStationnements: activeStationnements,
                totalPayments: totalPayments,
                totalCriticalAlerts: totalCriticalAlerts,
                totalSensorsOffline: totalSensorsOffline,
                onOpenAlerts: onOpenAlerts,
                onOpenPayments: onOpenPayments,
                onOpenStatistics: onOpenStatistics,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              flex: 5,
              child: _CapacityStatusCard(
                occupancyRate: occupancyRate,
                freePlaces: freePlaces,
                occupiedPlaces: occupiedPlaces,
                totalPlaces: totalPlaces,
                onOpenParking: onOpenParking,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OperationsControlCard extends StatelessWidget {
  final int activeStationnements;
  final int totalPayments;
  final int totalCriticalAlerts;
  final int totalSensorsOffline;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenPayments;
  final VoidCallback onOpenStatistics;

  const _OperationsControlCard({
    required this.activeStationnements,
    required this.totalPayments,
    required this.totalCriticalAlerts,
    required this.totalSensorsOffline,
    required this.onOpenAlerts,
    required this.onOpenPayments,
    required this.onOpenStatistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilotage opérationnel',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Lecture rapide des signaux les plus utiles pour agir immédiatement sur l’exploitation.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _OverviewRow(
            title: 'Sessions actives',
            value: '$activeStationnements',
            helper: 'Stationnements en cours',
            icon: Icons.local_activity_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          _OverviewRow(
            title: 'Transactions',
            value: '$totalPayments',
            helper: 'Flux paiement observé',
            icon: Icons.payments_rounded,
            color: AppColors.parkingElectric,
          ),
          const SizedBox(height: AppSpacing.md),
          _OverviewRow(
            title: 'Alertes critiques',
            value: '$totalCriticalAlerts',
            helper: 'Escalade immédiate recommandée',
            icon: Icons.warning_amber_rounded,
            color: AppColors.alertCritical,
            trailing: TextButton(
              onPressed: onOpenAlerts,
              child: const Text('Ouvrir'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _OverviewRow(
            title: 'Capteurs offline',
            value: '$totalSensorsOffline',
            helper: 'Diagnostic matériel requis',
            icon: Icons.sensors_off_rounded,
            color: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ActionButtonCard(
                  title: 'Voir les alertes',
                  subtitle: 'Contrôle sécurité',
                  icon: Icons.shield_outlined,
                  color: AppColors.alertCritical,
                  onTap: onOpenAlerts,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionButtonCard(
                  title: 'Voir les paiements',
                  subtitle: 'Suivi financier',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.parkingElectric,
                  onTap: onOpenPayments,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionButtonCard(
                  title: 'Statistiques',
                  subtitle: 'Tendances & analyse',
                  icon: Icons.insights_rounded,
                  color: AppColors.info,
                  onTap: onOpenStatistics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapacityStatusCard extends StatelessWidget {
  final double occupancyRate;
  final int freePlaces;
  final int occupiedPlaces;
  final int totalPlaces;
  final VoidCallback onOpenParking;

  const _CapacityStatusCard({
    required this.occupancyRate,
    required this.freePlaces,
    required this.occupiedPlaces,
    required this.totalPlaces,
    required this.onOpenParking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Capacité & occupation',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Lecture synthétique de la charge actuelle du parking.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${occupancyRate.toStringAsFixed(1)}%',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Taux d’occupation actuel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (occupancyRate / 100).clamp(0, 1),
                    minHeight: 10,
                    backgroundColor: AppColors.card,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _MiniStatusLine(
            label: 'Places libres',
            value: '$freePlaces',
            color: AppColors.parkingFree,
          ),
          const SizedBox(height: AppSpacing.sm),
          _MiniStatusLine(
            label: 'Places occupées',
            value: '$occupiedPlaces',
            color: AppColors.parkingOccupied,
          ),
          const SizedBox(height: AppSpacing.sm),
          _MiniStatusLine(
            label: 'Capacité totale',
            value: '$totalPlaces',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenParking,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Ouvrir le module parking'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final Color color;
  final Widget? trailing;

  const _OverviewRow({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  helper,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButtonCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatusLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStatusLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AdminErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _AdminErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                    size: 56,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Impossible de charger le dashboard',
                    style: AppTextStyles.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
