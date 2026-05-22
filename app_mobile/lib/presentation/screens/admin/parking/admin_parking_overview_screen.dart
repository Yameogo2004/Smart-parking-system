import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/parking_statut.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/layout/dashboard_shell.dart';
import '../../../widgets/status/status_badge.dart';

class AdminParkingOverviewScreen extends StatefulWidget {
  const AdminParkingOverviewScreen({super.key});

  @override
  State<AdminParkingOverviewScreen> createState() =>
      _AdminParkingOverviewScreenState();
}

class _AdminParkingOverviewScreenState
    extends State<AdminParkingOverviewScreen> {
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
      builder: (context, provider, _) {
        if (provider.isLoading && provider.parkingLevels.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final levels = provider.parkingLevels;

        if (levels.isEmpty) {
          return AdminModuleShell(
            currentRoute: RouteNames.adminParking,
            title: 'Parking Overview',
            subtitle: 'Vue consolidée des niveaux et de l’occupation.',
            onRefresh: provider.refreshDashboard,
            child: Center(
              child: Text(
                'Aucune donnée parking disponible.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final ParkingStatut global = _aggregate(levels);
        final double occupancyRate =
            global.total > 0 ? global.occupes / global.total : 0;

        return AdminModuleShell(
          currentRoute: RouteNames.adminParking,
          title: 'Parking Overview',
          subtitle:
              'Suivi global des niveaux, capacité disponible et charge actuelle du parking.',
          onRefresh: provider.refreshDashboard,
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.adminParkingSpots,
                );
              },
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Voir la grille'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ParkingHeroCard(
                total: global.total,
                libres: global.libres,
                occupes: global.occupes,
                occupancyRate: occupancyRate,
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              const Text(
                'Résumé par niveau',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  int count = 3;
                  if (constraints.maxWidth < 1100) count = 2;
                  if (constraints.maxWidth < 700) count = 1;

                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: levels.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      crossAxisSpacing: AppSpacing.dashboardGridGap,
                      mainAxisSpacing: AppSpacing.dashboardGridGap,
                      childAspectRatio: count == 1 ? 2.6 : 1.15,
                    ),
                    itemBuilder: (context, index) {
                      return _ParkingLevelCard(
                        levelIndex: index,
                        statut: levels[index],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              const Text(
                'Indicateurs rapides',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  int count = 4;
                  if (constraints.maxWidth < 1100) count = 2;
                  if (constraints.maxWidth < 640) count = 1;

                  return GridView.count(
                    crossAxisCount: count,
                    crossAxisSpacing: AppSpacing.dashboardGridGap,
                    mainAxisSpacing: AppSpacing.dashboardGridGap,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: count == 1 ? 3.0 : 1.4,
                    children: [
                      _MiniIndicatorCard(
                        label: 'Places totales',
                        value: '${global.total}',
                        color: AppColors.primary,
                        icon: Icons.local_parking_rounded,
                      ),
                      _MiniIndicatorCard(
                        label: 'Places libres',
                        value: '${global.libres}',
                        color: AppColors.parkingFree,
                        icon: Icons.check_circle_rounded,
                      ),
                      _MiniIndicatorCard(
                        label: 'Places occupées',
                        value: '${global.occupes}',
                        color: AppColors.parkingOccupied,
                        icon: Icons.directions_car_filled_rounded,
                      ),
                      _MiniIndicatorCard(
                        label: 'Taux global',
                        value: '${(occupancyRate * 100).toStringAsFixed(1)}%',
                        color: AppColors.accent,
                        icon: Icons.analytics_rounded,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ParkingStatut _aggregate(List<ParkingStatut> levels) {
    int total = 0;
    int libres = 0;
    int occupes = 0;

    for (final level in levels) {
      total += level.total;
      libres += level.libres;
      occupes += level.occupes;
    }

    return ParkingStatut(
      total: total,
      libres: libres,
      occupes: occupes,
    );
  }
}

class _ParkingHeroCard extends StatelessWidget {
  final int total;
  final int libres;
  final int occupes;
  final double occupancyRate;

  const _ParkingHeroCard({
    required this.total,
    required this.libres,
    required this.occupes,
    required this.occupancyRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0C1626),
            Color(0xFF10233C),
            Color(0xFF12304D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Capacité réseau parking',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$total',
                      style: AppTextStyles.displayLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' places',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: occupancyRate.clamp(0, 1),
                  backgroundColor: Colors.black.withValues(alpha: 0.24),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Occupation globale : ${(occupancyRate * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );

          final right = Column(
            children: [
              _QuickHeroInfo(
                title: 'Disponibles',
                value: '$libres',
                color: AppColors.parkingFree,
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              _QuickHeroInfo(
                title: 'Occupées',
                value: '$occupes',
                color: AppColors.parkingOccupied,
                icon: Icons.directions_car_filled_rounded,
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                left,
                const SizedBox(height: AppSpacing.xl),
                right,
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 6, child: left),
              const SizedBox(width: AppSpacing.xl),
              Expanded(flex: 4, child: right),
            ],
          );
        },
      ),
    );
  }
}

class _QuickHeroInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _QuickHeroInfo({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.xl),
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
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: color),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParkingLevelCard extends StatelessWidget {
  final int levelIndex;
  final ParkingStatut statut;

  const _ParkingLevelCard({
    required this.levelIndex,
    required this.statut,
  });

  @override
  Widget build(BuildContext context) {
    final double occupation =
        statut.total > 0 ? statut.occupes / statut.total : 0;

    final String levelLabel =
        levelIndex == 0 ? 'Rez-de-chaussée' : 'Niveau $levelIndex';

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
          Text(levelLabel, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(
            label: '${(occupation * 100).toStringAsFixed(1)}% occupé',
            variant: StatusBadgeVariant.info,
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _LevelStat(
                  label: 'Total',
                  value: '${statut.total}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _LevelStat(
                  label: 'Libres',
                  value: '${statut.libres}',
                  color: AppColors.parkingFree,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _LevelStat(
                  label: 'Occupées',
                  value: '${statut.occupes}',
                  color: AppColors.parkingOccupied,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: occupation.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LevelStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _MiniIndicatorCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniIndicatorCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(label, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
