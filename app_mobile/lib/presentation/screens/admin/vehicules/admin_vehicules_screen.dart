import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/vehicle.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/layout/dashboard_shell.dart';
import '../../../widgets/status/status_badge.dart';

class AdminVehiculesScreen extends StatefulWidget {
  const AdminVehiculesScreen({super.key});

  @override
  State<AdminVehiculesScreen> createState() => _AdminVehiculesScreenState();
}

class _AdminVehiculesScreenState extends State<AdminVehiculesScreen> {
  String _search = '';
  String _selectedFilter = 'Tous';

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadVehicules();
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
      context.read<AdminProvider>().loadVehicules();
    });
  }

  String _statusForVehicle(Vehicle vehicle) => vehicle.statut;

  String _parkingSpotForVehicle(Vehicle vehicle) =>
      vehicle.placeActuelle ?? '—';

  List<Vehicle> _filterVehicles(List<Vehicle> vehicles) {
    return vehicles.where((vehicle) {
      final key =
          '${vehicle.id} ${vehicle.matricule} ${vehicle.type}'.toLowerCase();
      final bool matchesSearch = key.contains(_search.toLowerCase());

      final String status = _statusForVehicle(vehicle);
      final bool matchesFilter =
          _selectedFilter == 'Tous' ? true : status == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.vehicules.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final vehicles = _filterVehicles(provider.vehicules);

        final int totalBlacklist = 0;
        final int totalSuspect = provider.vehicules
            .where((v) => v.suspect == 1)
            .length;

        return AdminModuleShell(
          currentRoute: RouteNames.adminVehicles,
          title: 'Vehicles Logs',
          subtitle:
              'Analyse des véhicules détectés, filtrage par statut et supervision rapide.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool compact = constraints.maxWidth < 950;

                  if (compact) {
                    return Column(
                      children: [
                        _VehiclesSummary(
                          total: provider.vehicules.length,
                          blacklist: totalBlacklist,
                          suspect: totalSuspect,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          onChanged: (value) => setState(() => _search = value),
                          decoration: const InputDecoration(
                            hintText: 'Rechercher par plaque, type ou ID...',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _VehiclesSummary(
                          total: provider.vehicules.length,
                          blacklist: totalBlacklist,
                          suspect: totalSuspect,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) => setState(() => _search = value),
                          decoration: const InputDecoration(
                            hintText: 'Rechercher par plaque, type ou ID...',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
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
                  _VehicleFilterChip(
                    label: 'Tous',
                    selected: _selectedFilter == 'Tous',
                    onTap: () => setState(() => _selectedFilter = 'Tous'),
                  ),
                  _VehicleFilterChip(
                    label: 'Normal',
                    selected: _selectedFilter == 'Normal',
                    onTap: () => setState(() => _selectedFilter = 'Normal'),
                  ),
                  _VehicleFilterChip(
                    label: 'Suspect',
                    selected: _selectedFilter == 'Suspect',
                    onTap: () => setState(() => _selectedFilter = 'Suspect'),
                  ),
                  _VehicleFilterChip(
                    label: 'Blacklisté',
                    selected: _selectedFilter == 'Blacklisté',
                    onTap: () => setState(() => _selectedFilter = 'Blacklisté'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              if (vehicles.isEmpty)
                const _EmptyVehiclesState()
              else
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadius.xxl),
                            topRight: Radius.circular(AppRadius.xxl),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Plaque',
                                style: AppTextStyles.titleSmall,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Type',
                                style: AppTextStyles.titleSmall,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Statut',
                                style: AppTextStyles.titleSmall,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Place',
                                style: AppTextStyles.titleSmall,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Action',
                                style: AppTextStyles.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...vehicles.map(
                        (vehicle) => _VehicleRow(
                          vehicle: vehicle,
                          status: _statusForVehicle(vehicle),
                          spot: _parkingSpotForVehicle(vehicle),
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

class _VehiclesSummary extends StatelessWidget {
  final int total;
  final int blacklist;
  final int suspect;

  const _VehiclesSummary({
    required this.total,
    required this.blacklist,
    required this.suspect,
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
          Expanded(
            child: _VehicleMetric(
              label: 'Total',
              value: '$total',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _VehicleMetric(
              label: 'Blacklistés',
              value: '$blacklist',
              color: AppColors.alertCritical,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _VehicleMetric(
              label: 'Suspects',
              value: '$suspect',
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _VehicleMetric({
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

class _VehicleFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = selected
        ? AppColors.primary.withValues(alpha: 0.16)
        : AppColors.surfaceLight;

    final Color fg = selected ? AppColors.primary : AppColors.textSecondary;

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

class _VehicleRow extends StatelessWidget {
  final Vehicle vehicle;
  final String status;
  final String spot;

  const _VehicleRow({
    required this.vehicle,
    required this.status,
    required this.spot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                vehicle.matricule,
                style: AppTextStyles.titleMedium.copyWith(
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              vehicle.type,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(
              label: status,
              variant: _variant(status),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              spot,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.visibility_rounded),
            ),
          ),
        ],
      ),
    );
  }

  StatusBadgeVariant _variant(String status) {
    switch (status) {
      case 'Blacklisté':
        return StatusBadgeVariant.danger;
      case 'Suspect':
        return StatusBadgeVariant.warning;
      default:
        return StatusBadgeVariant.success;
    }
  }
}

class _EmptyVehiclesState extends StatelessWidget {
  const _EmptyVehiclesState();

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
      child: Column(
        children: [
          const Icon(
            Icons.directions_car_outlined,
            size: 42,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Aucun véhicule trouvé',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Essaie de modifier la recherche ou le filtre.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
