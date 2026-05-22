import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/dashboard/alert_preview_card.dart';
import '../../../widgets/layout/admin_shell.dart';
import '../../../widgets/tables/filter_bar.dart';

class AdminSensorAlertsScreen extends StatefulWidget {
  const AdminSensorAlertsScreen({super.key});

  @override
  State<AdminSensorAlertsScreen> createState() =>
      _AdminSensorAlertsScreenState();
}

class _AdminSensorAlertsScreenState extends State<AdminSensorAlertsScreen> {
  String _filter = 'all';

  bool _isSensorAlert(dynamic alerte) {
    final type = alerte.type.toString().toLowerCase();
    return type.contains('capteur') ||
        type.contains('sensor') ||
        type.contains('barrière');
  }

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
        final alerts = provider.alertes.where((a) {
          if (!_isSensorAlert(a)) return false;
          if (_filter == 'all') return true;
          return a.niveau.toLowerCase() == _filter;
        }).toList();

        return AdminShell(
          currentRoute: RouteNames.adminSensorAlerts,
          title: 'Sensor Alerts',
          subtitle: 'Surveillance des capteurs, caméras et équipements terrain.',
          onRefresh: provider.loadAlertes,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilterBar(
                selectedValue: _filter,
                items: const [
                  FilterBarItem(label: 'Toutes', value: 'all'),
                  FilterBarItem(label: 'Critique', value: 'critique'),
                  FilterBarItem(label: 'Warning', value: 'warning'),
                  FilterBarItem(label: 'Info', value: 'info'),
                ],
                onChanged: (value) {
                  setState(() {
                    _filter = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              if (alerts.isEmpty)
                const Text('Aucune alerte capteur trouvée.')
              else
                Column(
                  children: alerts
                      .map(
                        (alert) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AlertPreviewCard(
                            title: alert.type,
                            message: alert.message,
                            level: alert.niveau,
                            onResolve: () async {
                              await provider.resolveAlerte(
                                alerteId: alert.id,
                              );
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
}
