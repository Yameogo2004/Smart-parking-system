import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/vehicle.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/layout/admin_shell.dart';
import '../../../widgets/status/status_badge.dart';
import '../../../widgets/tables/app_data_table.dart';
import '../../../widgets/tables/search_toolbar.dart';

class AdminBlacklistScreen extends StatefulWidget {
  const AdminBlacklistScreen({super.key});

  @override
  State<AdminBlacklistScreen> createState() => _AdminBlacklistScreenState();
}

class _AdminBlacklistScreenState extends State<AdminBlacklistScreen> {
  String _search = '';

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
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      context.read<AdminProvider>().loadVehicules();
    });
  }

  bool _isBlacklisted(Vehicle vehicle) => vehicle.id % 2 == 0;

  String _riskLevel(Vehicle vehicle) {
    if (vehicle.id % 4 == 0) return 'Élevé';
    if (vehicle.id % 3 == 0) return 'Moyen';
    return 'Faible';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final vehicles = provider.vehicules.where((vehicle) {
          if (!_isBlacklisted(vehicle)) return false;
          final key =
              '${vehicle.id} ${vehicle.matricule} ${vehicle.type}'.toLowerCase();
          return key.contains(_search.toLowerCase());
        }).toList();

        return AdminShell(
          currentRoute: RouteNames.adminBlacklist,
          title: 'Vehicle Blacklist',
          subtitle:
              'Véhicules sensibles, suspects ou interdits au sein du parking.',
          onRefresh: provider.loadVehicules,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchToolbar(
                hintText: 'Rechercher par plaque, type ou ID...',
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              AppDataTable(
                emptyLabel: 'Aucun véhicule blacklisté trouvé.',
                columns: const [
                  AppDataTableColumn(label: 'Plaque', flex: 3),
                  AppDataTableColumn(label: 'Type', flex: 2),
                  AppDataTableColumn(label: 'Risque', flex: 2),
                  AppDataTableColumn(label: 'Statut', flex: 2),
                ],
                rows: vehicles
                    .map(
                      (vehicle) => AppDataTableRowData(
                        cells: [
                          AppDataTableCell(
                            flex: 3,
                            child: Text(
                              vehicle.matricule,
                              style: AppTextStyles.titleMedium,
                            ),
                          ),
                          AppDataTableCell(
                            flex: 2,
                            child: Text(vehicle.type),
                          ),
                          AppDataTableCell(
                            flex: 2,
                            child: Text(_riskLevel(vehicle)),
                          ),
                          AppDataTableCell(
                            flex: 2,
                            child: const StatusBadge(
                              label: 'Blacklisté',
                              variant: StatusBadgeVariant.danger,
                            ),
                          ),
                        ],
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
}
