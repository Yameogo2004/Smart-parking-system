import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../widgets/dashboard/metric_card.dart';
import '../../../widgets/layout/admin_shell.dart';

class AdminStatisticsScreen extends StatelessWidget {
  const AdminStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const weeklyTraffic = [
      {'day': 'Lun', 'value': 42},
      {'day': 'Mar', 'value': 55},
      {'day': 'Mer', 'value': 48},
      {'day': 'Jeu', 'value': 71},
      {'day': 'Ven', 'value': 88},
      {'day': 'Sam', 'value': 63},
      {'day': 'Dim', 'value': 37},
    ];

    return AdminShell(
      currentRoute: RouteNames.adminStatistics,
      title: 'Statistics Center',
      subtitle: 'Analyse trafic, revenus, charge parking et tendances.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vue analytique',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              int count = 4;
              if (constraints.maxWidth < 1100) count = 2;
              if (constraints.maxWidth < 620) count = 1;

              return GridView.count(
                crossAxisCount: count,
                crossAxisSpacing: AppSpacing.dashboardGridGap,
                mainAxisSpacing: AppSpacing.dashboardGridGap,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: count == 1 ? 2.4 : 1.45,
                children: const [
                  MetricCard(
                    title: 'Revenu hebdo',
                    value: '8 450 MAD',
                    subtitle: 'Cumul des transactions',
                    icon: Icons.payments_rounded,
                    accentColor: AppColors.primary,
                  ),
                  MetricCard(
                    title: 'Trafic moyen',
                    value: '57',
                    subtitle: 'Véhicules / jour',
                    icon: Icons.directions_car_rounded,
                    accentColor: AppColors.info,
                  ),
                  MetricCard(
                    title: 'Temps moyen',
                    value: '2h 14m',
                    subtitle: 'Durée stationnement',
                    icon: Icons.schedule_rounded,
                    accentColor: AppColors.warning,
                  ),
                  MetricCard(
                    title: 'Recharge EV',
                    value: '18',
                    subtitle: 'Sessions cette semaine',
                    icon: Icons.ev_station_rounded,
                    accentColor: AppColors.parkingElectric,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trafic hebdomadaire',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Répartition journalière pour repérer les pics d’activité.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...weeklyTraffic.map((item) {
                  final value = item['value'] as int;
                  final widthFactor = value / 100;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 42,
                          child: Text(
                            item['day'] as String,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: widthFactor,
                              minHeight: 12,
                              backgroundColor: AppColors.surfaceLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$value',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
