import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/payment.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/layout/dashboard_shell.dart';
import '../../../widgets/status/status_badge.dart';

class AdminPaiementsScreen extends StatefulWidget {
  const AdminPaiementsScreen({super.key});

  @override
  State<AdminPaiementsScreen> createState() => _AdminPaiementsScreenState();
}

class _AdminPaiementsScreenState extends State<AdminPaiementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPaiements();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      context.read<AdminProvider>().loadPaiements();
    });
  }

  List<Payment> _parkingPayments(List<Payment> items) {
    return items.where((p) => p.id.isOdd).toList();
  }

  List<Payment> _evPayments(List<Payment> items) {
    return items.where((p) => p.id.isEven).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.paiements.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.errorMessage != null && provider.paiements.isEmpty) {
          return AdminModuleShell(
            currentRoute: RouteNames.adminPayments,
            title: 'Payments Center',
            subtitle: 'Suivi financier parking et recharge électrique.',
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
            ),
          );
        }

        final double totalAmount = provider.paiements.fold<double>(
          0,
          (sum, payment) => sum + payment.montant,
        );

        final parkingPayments = _parkingPayments(provider.paiements);
        final evPayments = _evPayments(provider.paiements);

        return AdminModuleShell(
          currentRoute: RouteNames.adminPayments,
          title: 'Payments Center',
          subtitle:
              'Tableaux de paiement parking et recharge électrique en temps réel.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  int count = 3;
                  if (constraints.maxWidth < 900) count = 2;
                  if (constraints.maxWidth < 620) count = 1;

                  return GridView.count(
                    crossAxisCount: count,
                    crossAxisSpacing: AppSpacing.dashboardGridGap,
                    mainAxisSpacing: AppSpacing.dashboardGridGap,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: count == 1 ? 3.2 : 1.4,
                    children: [
                      _PaymentSummaryCard(
                        title: 'Montant total',
                        value: '${totalAmount.toStringAsFixed(2)} MAD',
                        color: AppColors.primary,
                        icon: Icons.payments_rounded,
                      ),
                      _PaymentSummaryCard(
                        title: 'Paiements parking',
                        value: '${parkingPayments.length}',
                        color: AppColors.success,
                        icon: Icons.local_parking_rounded,
                      ),
                      _PaymentSummaryCard(
                        title: 'Sessions recharge EV',
                        value: '${evPayments.length}',
                        color: AppColors.parkingElectric,
                        icon: Icons.ev_station_rounded,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      tabs: const [
                        Tab(text: 'Parking'),
                        Tab(text: 'Recharge EV'),
                      ],
                    ),
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _PaymentsList(
                            payments: parkingPayments,
                            emptyLabel: 'Aucun paiement parking trouvé.',
                          ),
                          _PaymentsList(
                            payments: evPayments,
                            emptyLabel: 'Aucun paiement EV trouvé.',
                            isEv: true,
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
      },
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _PaymentSummaryCard({
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
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
                Text(value, style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(title, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsList extends StatelessWidget {
  final List<Payment> payments;
  final String emptyLabel;
  final bool isEv;

  const _PaymentsList({
    required this.payments,
    required this.emptyLabel,
    this.isEv = false,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _PaymentCard(
          payment: payment,
          isEv: isEv,
        );
      },
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  final bool isEv;

  const _PaymentCard({
    required this.payment,
    this.isEv = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(payment.statut);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              isEv ? Icons.ev_station_rounded : Icons.payments_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payment.montant.toStringAsFixed(2)} MAD',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  isEv
                      ? 'Session recharge #${payment.id}'
                      : 'Paiement parking #${payment.id}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          StatusBadge(
            label: payment.statut,
            variant: _variant(payment.statut),
          ),
        ],
      ),
    );
  }

  StatusBadgeVariant _variant(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
      case 'completed':
        return StatusBadgeVariant.success;
      case 'pending':
        return StatusBadgeVariant.warning;
      case 'failed':
      case 'error':
        return StatusBadgeVariant.danger;
      default:
        return StatusBadgeVariant.info;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
      case 'error':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }
}
