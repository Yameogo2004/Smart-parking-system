import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/alerte.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/layout/dashboard_shell.dart';
import '../../../widgets/status/status_badge.dart';

class AdminAlertsScreen extends StatefulWidget {
  const AdminAlertsScreen({super.key});

  @override
  State<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends State<AdminAlertsScreen> {
  String _selectedLevel = 'Toutes';

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAlertes();
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
      context.read<AdminProvider>().loadAlertes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.alertes.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final filtered = _filterAlertes(provider.alertes);

        final totalWarning = provider.alertes
            .where((a) => a.niveau.toLowerCase() == 'warning')
            .length;
        final totalInfo = provider.alertes
            .where((a) => a.niveau.toLowerCase() == 'info')
            .length;

        return AdminModuleShell(
          currentRoute: RouteNames.adminAlerts,
          title: 'Command Center / Alerts',
          subtitle:
              'Supervision détaillée des incidents, anomalies et événements du système.',
          onRefresh: provider.loadAlertes,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  int count = 4;
                  if (constraints.maxWidth < 1000) count = 2;
                  if (constraints.maxWidth < 620) count = 1;

                  return GridView.count(
                    crossAxisCount: count,
                    crossAxisSpacing: AppSpacing.dashboardGridGap,
                    mainAxisSpacing: AppSpacing.dashboardGridGap,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: count == 1 ? 2.4 : 1.8,
                    children: [
                      _AlertSummaryCard(
                        title: 'Total',
                        value: '${provider.alertes.length}',
                        color: AppColors.info,
                      ),
                      _AlertSummaryCard(
                        title: 'Critiques',
                        value: '${provider.totalAlertesCritiques}',
                        color: AppColors.alertCritical,
                      ),
                      _AlertSummaryCard(
                        title: 'Warning',
                        value: '$totalWarning',
                        color: AppColors.warning,
                      ),
                      _AlertSummaryCard(
                        title: 'Info',
                        value: '$totalInfo',
                        color: AppColors.primary,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _FilterChip(
                    label: 'Toutes',
                    selected: _selectedLevel == 'Toutes',
                    onTap: () => setState(() => _selectedLevel = 'Toutes'),
                  ),
                  _FilterChip(
                    label: 'Critique',
                    selected: _selectedLevel == 'Critique',
                    onTap: () => setState(() => _selectedLevel = 'Critique'),
                  ),
                  _FilterChip(
                    label: 'Warning',
                    selected: _selectedLevel == 'Warning',
                    onTap: () => setState(() => _selectedLevel = 'Warning'),
                  ),
                  _FilterChip(
                    label: 'Info',
                    selected: _selectedLevel == 'Info',
                    onTap: () => setState(() => _selectedLevel = 'Info'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              if (filtered.isEmpty)
                const _EmptyState(message: 'Aucune alerte trouvée.')
              else
                Column(
                  children: filtered
                      .map(
                        (alerte) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _AlerteCard(
                            alerte: alerte,
                            onResolve: () async {
                              await context.read<AdminProvider>().resolveAlerte(
                                    alerteId: alerte.id,
                                  );
                            },
                            onView: () {
                              _showAlertDetailsSheet(context, alerte);
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Alerte> _filterAlertes(List<Alerte> source) {
    if (_selectedLevel == 'Toutes') return source;
    return source
        .where((a) => a.niveau.toLowerCase() == _selectedLevel.toLowerCase())
        .toList();
  }

  void _showAlertDetailsSheet(BuildContext context, Alerte alerte) {
    final detail = _buildAlertDetail(alerte);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alerte.type,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: alerte.niveau,
                        variant: _variant(alerte.niveau),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    alerte.message,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DetailInfoCard(
                    title: 'Description automatique',
                    content: detail,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DetailMetaGrid(alerte: alerte),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Fermer'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await context.read<AdminProvider>().resolveAlerte(
                                  alerteId: alerte.id,
                                );
                          },
                          icon: const Icon(Icons.task_alt_rounded),
                          label: const Text('Résoudre'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildAlertDetail(Alerte alerte) {
    final type = alerte.type.toLowerCase();

    if (type.contains('capteur') || type.contains('sensor')) {
      return 'Une anomalie a été détectée sur le capteur ${alerte.capteurNom ?? 'inconnu'} au ${alerte.parkingLevel ?? 'niveau non précisé'}, zone ${alerte.spotCode ?? 'non précisée'}. Le système recommande une vérification physique du capteur, du câblage et de l’alimentation afin de rétablir la remontée correcte des données.';
    }

    if (type.contains('vehicle mismatch') ||
        type.contains('vehicule') ||
        type.contains('intrusion')) {
      return 'Le véhicule ${alerte.vehiculeMatricule ?? 'non identifié'} a été signalé dans la zone ${alerte.spotCode ?? 'non précisée'} au ${alerte.parkingLevel ?? 'niveau non précisé'}. Cette alerte suggère soit une tentative d’accès non autorisée, soit un stationnement sur un emplacement non assigné. Une vérification visuelle et un contrôle de l’affectation de place sont recommandés.';
    }

    if (type.contains('paiement')) {
      return 'Une anomalie de paiement a été détectée pour le véhicule ${alerte.vehiculeMatricule ?? 'concerné'} dans la zone ${alerte.spotCode ?? 'associée'}. Le système recommande de vérifier le statut de transaction, la méthode de paiement utilisée et la session liée avant de clôturer l’incident.';
    }

    return 'Une alerte système a été remontée depuis ${alerte.source ?? 'une source non précisée'}. Une analyse du contexte opérationnel, de la zone concernée et des équipements associés est recommandée avant validation de résolution.';
  }

  StatusBadgeVariant _variant(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'critique':
        return StatusBadgeVariant.danger;
      case 'warning':
        return StatusBadgeVariant.warning;
      case 'info':
        return StatusBadgeVariant.info;
      default:
        return StatusBadgeVariant.neutral;
    }
  }
}

class _AlerteCard extends StatelessWidget {
  final Alerte alerte;
  final VoidCallback onResolve;
  final VoidCallback onView;

  const _AlerteCard({
    required this.alerte,
    required this.onResolve,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final color = _alertColor(alerte.niveau);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      alerte.type,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    StatusBadge(
                      label: alerte.niveau,
                      variant: _variant(alerte.niveau),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  alerte.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (alerte.parkingLevel != null)
                      _InlineMetaChip(
                        icon: Icons.layers_rounded,
                        label: alerte.parkingLevel!,
                      ),
                    if (alerte.spotCode != null)
                      _InlineMetaChip(
                        icon: Icons.place_outlined,
                        label: alerte.spotCode!,
                      ),
                    if (alerte.timestamp != null)
                      _InlineMetaChip(
                        icon: Icons.schedule_rounded,
                        label: _formatTimeLabel(alerte.timestamp!),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onView,
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: const Text('Voir'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onResolve,
                        icon: const Icon(Icons.task_alt_rounded, size: 18),
                        label: const Text('Résoudre'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTimeLabel(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  StatusBadgeVariant _variant(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'critique':
        return StatusBadgeVariant.danger;
      case 'warning':
        return StatusBadgeVariant.warning;
      case 'info':
        return StatusBadgeVariant.info;
      default:
        return StatusBadgeVariant.neutral;
    }
  }

  Color _alertColor(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'critique':
        return AppColors.alertCritical;
      case 'warning':
        return AppColors.alertWarning;
      case 'info':
        return AppColors.alertInfo;
      default:
        return AppColors.warning;
    }
  }
}

class _InlineMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InlineMetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailInfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _DetailInfoCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMetaGrid extends StatelessWidget {
  final Alerte alerte;

  const _DetailMetaGrid({required this.alerte});

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<String, String>>[
      if (alerte.source != null) MapEntry('Source', alerte.source!),
      if (alerte.parkingLevel != null)
        MapEntry('Niveau', alerte.parkingLevel!),
      if (alerte.spotCode != null) MapEntry('Zone / Place', alerte.spotCode!),
      if (alerte.vehiculeMatricule != null)
        MapEntry('Véhicule', alerte.vehiculeMatricule!),
      if (alerte.capteurNom != null)
        MapEntry('Capteur', alerte.capteurNom!),
      if (alerte.timestamp != null) MapEntry('Horodatage', alerte.timestamp!),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: items
          .map(
            (item) => Container(
              width: 260,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.key,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AlertSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _AlertSummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.surfaceLight;

    final fg = selected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: fg),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
