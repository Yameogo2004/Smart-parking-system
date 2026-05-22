import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/layout/admin_shell.dart';
import '../../../widgets/status/status_badge.dart';
import '../../../widgets/tables/app_data_table.dart';

class AdminParkingPaymentsScreen extends StatefulWidget {
  const AdminParkingPaymentsScreen({super.key});

  @override
  State<AdminParkingPaymentsScreen> createState() =>
      _AdminParkingPaymentsScreenState();
}

class _AdminParkingPaymentsScreenState
    extends State<AdminParkingPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPaiements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final payments =
            provider.paiements.where((payment) => payment.id.isOdd).toList();

        return AdminShell(
          currentRoute: RouteNames.adminParkingPayments,
          title: 'Parking Payments',
          subtitle: 'Transactions liées au stationnement classique.',
          onRefresh: provider.loadPaiements,
          body: AppDataTable(
            emptyLabel: 'Aucun paiement parking trouvé.',
            columns: const [
              AppDataTableColumn(label: 'Référence', flex: 2),
              AppDataTableColumn(label: 'Montant', flex: 2),
              AppDataTableColumn(label: 'Type', flex: 2),
              AppDataTableColumn(label: 'Statut', flex: 2),
            ],
            rows: payments
                .map(
                  (payment) => AppDataTableRowData(
                    cells: [
                      AppDataTableCell(
                        flex: 2,
                        child: Text(
                          '#${payment.id}',
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                      AppDataTableCell(
                        flex: 2,
                        child: Text(
                          '${payment.montant.toStringAsFixed(2)} MAD',
                        ),
                      ),
                      const AppDataTableCell(
                        flex: 2,
                        child: Text('Parking'),
                      ),
                      AppDataTableCell(
                        flex: 2,
                        child: StatusBadge(
                          label: payment.statut,
                          variant: _variant(payment.statut),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        );
      },
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
}
