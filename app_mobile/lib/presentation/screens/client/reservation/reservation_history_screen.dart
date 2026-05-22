import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../data/models/reservation_history.dart';
import '../../../../data/services/api_service.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  List<ReservationHistory> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('/api/reservations/historique');
      final rawList = (response['reservations'] as List?) ?? [];

      final reservations = rawList
          .map(
            (json) => ReservationHistory.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _reservations = _getMockReservations();
        _isLoading = false;
      });
    }
  }

  List<ReservationHistory> _getMockReservations() {
    return [
      ReservationHistory(
        id: 1,
        codeConfirmation: 'RES1001',
        dateReservation: DateTime.now().subtract(const Duration(days: 5)),
        dateDebut: DateTime.now().subtract(const Duration(days: 3)),
        dateFin: DateTime.now()
            .subtract(const Duration(days: 3))
            .add(const Duration(hours: 4)),
        plaque: 'AB-123-CD',
        modele: 'Tesla Model 3',
        charge: 200,
        montant: 12.50,
        statut: 'confirmée',
        emplacement: 'Niveau 1 - Box A2',
      ),
      ReservationHistory(
        id: 2,
        codeConfirmation: 'RES1002',
        dateReservation: DateTime.now().subtract(const Duration(days: 10)),
        dateDebut: DateTime.now().subtract(const Duration(days: 8)),
        dateFin: DateTime.now()
            .subtract(const Duration(days: 8))
            .add(const Duration(hours: 2)),
        plaque: 'EF-456-GH',
        modele: 'Renault Zoe',
        charge: 100,
        montant: 6.50,
        statut: 'terminée',
        emplacement: 'Niveau 0 - Box B3',
      ),
      ReservationHistory(
        id: 3,
        codeConfirmation: 'RES1003',
        dateReservation: DateTime.now().subtract(const Duration(days: 1)),
        dateDebut: DateTime.now().add(const Duration(hours: 2)),
        dateFin: DateTime.now().add(const Duration(hours: 5)),
        plaque: 'XY-789-ZW',
        modele: 'Peugeot 208',
        charge: 150,
        montant: 7.50,
        statut: 'confirmée',
        emplacement: 'Non assigné',
      ),
    ];
  }

  Future<void> _annulerReservation(ReservationHistory reservation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text(
          'Voulez-vous vraiment annuler la réservation ${reservation.codeConfirmation} ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(
        '/api/reservation/${reservation.id}/annuler',
        {},
      );

      if (response['success'] == true) {
        final index =
            _reservations.indexWhere((item) => item.id == reservation.id);

        if (index != -1) {
          _reservations[index] = reservation.copyWith(
            statut: 'annulée',
          );
        }

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée avec succès'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception(
          response['message'] ?? 'Erreur lors de l’annulation',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _reservations.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = _reservations[index];
                      return _buildHistoryCard(context, reservation);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: colors.textMuted.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos réservations apparaîtront ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    ReservationHistory reservation,
  ) {
    final colors = context.appColors;

    final statusConfig = _getStatusConfig(reservation.statut);
    final statusColor = statusConfig.color;
    final statusText = statusConfig.label;

    final startHour =
        '${reservation.dateDebut.hour.toString().padLeft(2, '0')}h${reservation.dateDebut.minute.toString().padLeft(2, '0')}';
    final endHour =
        '${reservation.dateFin.hour.toString().padLeft(2, '0')}h${reservation.dateFin.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showReservationDetails(context, reservation),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reservation.codeConfirmation,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${reservation.plaque} - ${reservation.modele}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(reservation.dateDebut),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$startHour - $endHour',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${reservation.montant.toStringAsFixed(2)} DH',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const Spacer(),
                    if (reservation.estConfirmee)
                      TextButton.icon(
                        onPressed: () => _annulerReservation(reservation),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Annuler'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReservationDetails(
    BuildContext context,
    ReservationHistory reservation,
  ) {
    final colors = context.appColors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            Center(
              child: Text(
                'Détails de la réservation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 18),
            _buildDetailRow(
              context,
              'Code',
              reservation.codeConfirmation,
            ),
            _buildDetailRow(
              context,
              'Date réservation',
              DateFormat('dd/MM/yyyy à HH:mm').format(
                reservation.dateReservation,
              ),
            ),
            _buildDetailRow(
              context,
              'Période',
              '${DateFormat('dd/MM/yyyy HH:mm').format(reservation.dateDebut)} → ${DateFormat('HH:mm').format(reservation.dateFin)}',
            ),
            _buildDetailRow(
              context,
              'Véhicule',
              '${reservation.plaque} - ${reservation.modele}',
            ),
            _buildDetailRow(
              context,
              'Charge',
              '${reservation.charge.toStringAsFixed(0)} kg',
            ),
            _buildDetailRow(
              context,
              'Emplacement',
              reservation.emplacement,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              'Montant total',
              '${reservation.montant.toStringAsFixed(2)} DH',
              isBold: true,
            ),
            const SizedBox(height: 20),
            if (reservation.estConfirmee)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _annulerReservation(reservation);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Annuler la réservation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                    color: isBold
                        ? Theme.of(context).colorScheme.primary
                        : colors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  _ReservationStatusConfig _getStatusConfig(String rawStatus) {
    final status = rawStatus.trim().toLowerCase();

    switch (status) {
      case 'confirmée':
      case 'confirmee':
        return const _ReservationStatusConfig(
          label: 'Confirmée',
          color: Colors.green,
        );
      case 'terminée':
      case 'terminee':
        return const _ReservationStatusConfig(
          label: 'Terminée',
          color: Colors.blue,
        );
      case 'annulée':
      case 'annulee':
        return const _ReservationStatusConfig(
          label: 'Annulée',
          color: Colors.red,
        );
      case 'en_attente':
      case 'en attente':
      case 'pending':
        return const _ReservationStatusConfig(
          label: 'En attente',
          color: Colors.orange,
        );
      default:
        return const _ReservationStatusConfig(
          label: 'En attente',
          color: Colors.orange,
        );
    }
  }
}

class _ReservationStatusConfig {
  final String label;
  final Color color;

  const _ReservationStatusConfig({
    required this.label,
    required this.color,
  });
}
