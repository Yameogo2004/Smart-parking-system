import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/capteur.dart';
import '../../../../providers/admin_provider.dart';

class AdminCapteursScreen extends StatefulWidget {
  const AdminCapteursScreen({super.key});

  @override
  State<AdminCapteursScreen> createState() => _AdminCapteursScreenState();
}

class _AdminCapteursScreenState extends State<AdminCapteursScreen> {
  String _search = '';

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCapteurs();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      context.read<AdminProvider>().loadCapteurs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capteurs'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.capteurs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final capteurs = provider.capteurs.where((capteur) {
            final key =
                '${capteur.type} ${capteur.statut} ${capteur.id}'.toLowerCase();
            return key.contains(_search.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un capteur...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              Expanded(
                child: capteurs.isEmpty
                    ? const _CapteursEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: capteurs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final capteur = capteurs[index];
                          return _CapteurCard(capteur: capteur);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CapteurCard extends StatelessWidget {
  final Capteur capteur;

  const _CapteurCard({required this.capteur});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(capteur.statut);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.sensors_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capteur.type,
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'ID capteur: ${capteur.id}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          _StatusBadge(
            label: capteur.statut,
            color: statusColor,
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return AppColors.sensorOnline;
      case 'offline':
        return AppColors.sensorOffline;
      case 'error':
        return AppColors.sensorError;
      default:
        return AppColors.grey400;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: color),
      ),
    );
  }
}

class _CapteursEmptyState extends StatelessWidget {
  const _CapteursEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aucun capteur trouvé.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
