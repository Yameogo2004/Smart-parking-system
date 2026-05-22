import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/dashboard/alert_preview_card.dart';
import '../../../widgets/layout/admin_shell.dart';
import '../../../widgets/tables/filter_bar.dart';

class AdminVehicleAlertsScreen extends StatefulWidget {
  const AdminVehicleAlertsScreen({super.key});

  @override
  State<AdminVehicleAlertsScreen> createState() =>
      _AdminVehicleAlertsScreenState();
}

class _AdminVehicleAlertsScreenState extends State<AdminVehicleAlertsScreen> {
  String _filter = 'all';

  bool _isVehicleAlert(dynamic alerte) {
    final type = alerte.type.toString().toLowerCase();
    final message = alerte.message.toString().toLowerCase();

    return type.contains('intrusion') ||
        type.contains('vehicule') ||
        type.contains('véhicule') ||
        type.contains('paiement') ||
        message.contains('véhicule') ||
        message.contains('vehicule') ||
        message.contains('plaque') ||
        message.contains('stationnement');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAlertes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final alerts = provider.alertes.where((a) {
          if (!_isVehicleAlert(a)) return false;
          if (_filter == 'all') return true;
          return a.niveau.toLowerCase() == _filter;
        }).toList();

        return AdminShell(
          currentRoute: RouteNames.adminVehicleAlerts,
          title: 'Vehicle Alerts',
          subtitle:
              'Alertes liées aux véhicules, plaques et anomalies de stationnement.',
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
                const Text('Aucune alerte véhicule trouvée.')
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
