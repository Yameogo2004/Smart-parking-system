import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/stationnement.dart';
import '../../../../providers/admin_provider.dart';

class AdminStationnementsScreen extends StatefulWidget {
  const AdminStationnementsScreen({super.key});

  @override
  State<AdminStationnementsScreen> createState() =>
      _AdminStationnementsScreenState();
}

class _AdminStationnementsScreenState extends State<AdminStationnementsScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStationnements();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      context.read<AdminProvider>().loadStationnements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stationnements'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.stationnements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.stationnements.isEmpty) {
            return Center(
              child: Text(
                'Aucun stationnement trouvé.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: provider.stationnements.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final stationnement = provider.stationnements[index];
              return _StationnementCard(stationnement: stationnement);
            },
          );
        },
      ),
    );
  }
}

class _StationnementCard extends StatelessWidget {
  final Stationnement stationnement;

  const _StationnementCard({
    required this.stationnement,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = stationnement.sortie == null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Session #${stationnement.id}',
                  style: AppTextStyles.cardTitle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: (active ? AppColors.success : AppColors.grey500)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  active ? 'En cours' : 'Terminée',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: active ? AppColors.success : AppColors.grey400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(label: 'Vehicle ID', value: '${stationnement.vehicleId}'),
          _InfoRow(label: 'Place ID', value: '${stationnement.parkingSpotId}'),
          _InfoRow(
            label: 'Entrée',
            value: stationnement.entree.toString(),
          ),
          _InfoRow(
            label: 'Sortie',
            value: stationnement.sortie?.toString() ?? '—',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
