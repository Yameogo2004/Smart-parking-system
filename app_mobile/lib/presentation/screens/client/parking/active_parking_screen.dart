import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../data/services/api_service.dart';

class ActiveParkingScreen extends StatefulWidget {
  final Map<String, dynamic>? stationnement;

  const ActiveParkingScreen({super.key, this.stationnement});

  @override
  State<ActiveParkingScreen> createState() => _ActiveParkingScreenState();
}

class _ActiveParkingScreenState extends State<ActiveParkingScreen> {
  Map<String, dynamic>? _stationnement;
  bool _isLoading = true;
  bool _showFullQr = false;
  Timer? _timer;
  Duration _duree = Duration.zero;
  final double _prixParHeure = 2.50;

  @override
  void initState() {
    super.initState();
    _chargerStationnement();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _duree += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _chargerStationnement() async {
    if (widget.stationnement != null) {
      setState(() {
        _stationnement = widget.stationnement;
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.get('/api/stationnement/actif');

      if (!mounted) return;
      setState(() {
        _stationnement = response['stationnement'];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _formatDuree(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  double _calculerMontant() {
    final heures = _duree.inMinutes / 60;
    return heures * _prixParHeure;
  }

  String _getQrData() {
    if (_stationnement == null) return 'PARKING:UNKNOWN';
    final String plaque = _stationnement!['plaque'] ?? 'AB-123-CD';
    final int niveau = _stationnement!['niveau'] ?? 1;
    final String box =
        '${_stationnement!['box'] ?? _stationnement!['place_numero'] ?? 'A2'}';
    return 'PARKING:$plaque:$niveau:$box:${DateTime.now().millisecondsSinceEpoch}';
  }

  void _showLocationDialog() {
    if (_stationnement == null) return;

    final int niveau = _stationnement!['niveau'] ?? 1;
    final String box =
        '${_stationnement!['box'] ?? _stationnement!['place_numero'] ?? 'A2'}';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Localisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 50),
            const SizedBox(height: 12),
            Text('Niveau ${niveau == 0 ? 'RDC' : niveau}'),
            Text('Place $box'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day}/${date.month} ${date.hour}h$minute';
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Stationnement actif'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stationnement == null
              ? Center(
                  child: Text(
                    'Aucun stationnement actif',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildQrCard(context),
                      const SizedBox(height: 16),
                      _buildTimerCard(context),
                      const SizedBox(height: 16),
                      _buildLocationCard(context),
                      const SizedBox(height: 16),
                      _buildVehicleCard(context),
                      const SizedBox(height: 16),
                      _buildActionButtons(context),
                      const SizedBox(height: 16),
                      _buildInfoMessage(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildQrCard(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Code de sortie',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFullQr = !_showFullQr;
                });
              },
              child: QrImageView(
                data: _getQrData(),
                version: QrVersions.auto,
                size: _showFullQr ? 210 : 130,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _metricText(
              context,
              label: 'Temps stationné',
              value: _formatDuree(_duree),
              valueSize: 24,
            ),
          ),
          Container(
            width: 1,
            height: 54,
            color: Colors.white.withValues(alpha: 0.20),
          ),
          Expanded(
            child: _metricText(
              context,
              label: 'Montant estimé',
              value: '${_calculerMontant().toStringAsFixed(2)} DH',
              subValue: '${_prixParHeure.toStringAsFixed(2)} DH / h',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    if (_stationnement == null) return const SizedBox.shrink();

    final colors = context.appColors;
    final int niveau = _stationnement!['niveau'] ?? 1;
    final String box =
        '${_stationnement!['box'] ?? _stationnement!['place_numero'] ?? 'A2'}';

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: _smallInfoCard(
                context,
                icon: Icons.layers_outlined,
                label: 'Niveau',
                value: niveau == 0 ? 'RDC' : '$niveau',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _smallInfoCard(
                context,
                icon: Icons.local_parking_outlined,
                label: 'Place',
                value: box,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context) {
    if (_stationnement == null) return const SizedBox.shrink();

    final colors = context.appColors;
    final String plaque = _stationnement!['plaque'] ?? 'AB-123-CD';
    final String rfidTicket = _stationnement!['rfid_ticket'] ?? 'RFID001';
    final String dateEntree =
        _stationnement!['date_entree'] ?? DateTime.now().toIso8601String();

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _detailRow(context, 'Plaque', plaque, Icons.badge_outlined),
            const SizedBox(height: 12),
            _detailRow(
              context,
              'Ticket RFID',
              rfidTicket,
              Icons.credit_card_outlined,
            ),
            const SizedBox(height: 12),
            _detailRow(
              context,
              'Entrée',
              _formatDate(dateEntree),
              Icons.access_time_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.timer_outlined),
            label: const Text('Prolonger'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showLocationDialog,
            icon: const Icon(Icons.navigation_outlined),
            label: const Text('Localiser'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Présentez votre QR code ou votre ticket RFID au terminal de sortie.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _metricText(
    BuildContext context, {
    required String label,
    required String value,
    String? subValue,
    double valueSize = 20,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: valueSize,
                fontWeight: FontWeight.w800,
              ),
        ),
        if (subValue != null) ...[
          const SizedBox(height: 4),
          Text(
            subValue,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ],
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colors = context.appColors;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
