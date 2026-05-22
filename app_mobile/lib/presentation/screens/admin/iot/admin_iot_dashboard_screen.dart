import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/capteur.dart';
import '../../../../providers/admin_provider.dart';
import '../../../widgets/layout/admin_shell.dart';

class AdminIotDashboardScreen extends StatefulWidget {
  const AdminIotDashboardScreen({super.key});

  @override
  State<AdminIotDashboardScreen> createState() =>
      _AdminIotDashboardScreenState();
}

class _AdminIotDashboardScreenState extends State<AdminIotDashboardScreen> {
  Timer? _pollingTimer;
  final Map<int, String> _previousStatuts = {};
  final Set<int> _recentlyChanged = {};
  static const Duration _pollInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAll();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollInterval, (_) => _fetchSilent());
  }

  Future<void> _fetchAll() async {
    if (!mounted) return;
    final provider = context.read<AdminProvider>();
    await Future.wait([
      provider.loadCapteurs(),
      provider.loadElevator(),
      provider.loadSensorAlerts(),
    ]);
    if (mounted) _detectChanges(provider.capteurs);
  }

  Future<void> _fetchSilent() async {
    if (!mounted) return;
    final provider = context.read<AdminProvider>();
    await Future.wait([
      provider.loadCapteurs(),
      provider.loadElevator(),
      provider.loadSensorAlerts(),
    ]);
    if (mounted) _detectChanges(provider.capteurs);
  }

  void _detectChanges(List<Capteur> capteurs) {
    final Set<int> changed = {};
    for (final c in capteurs) {
      final prev = _previousStatuts[c.id];
      if (prev != null && prev != c.statut) changed.add(c.id);
      _previousStatuts[c.id] = c.statut;
    }
    if (changed.isNotEmpty && mounted) {
      setState(() => _recentlyChanged.addAll(changed));
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _recentlyChanged.removeAll(changed));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final capteurs = provider.capteurs;
        final elevator = provider.elevator;
        final sensorAlerts = provider.sensorAlerts;
        final dashboard = provider.dashboardData;

        // Compteurs
        final int totalCapteurs = capteurs.length;
        final int onlineCapteurs =
            capteurs.where((c) => c.statut.toLowerCase() == 'online').length;
        final int offlineCapteurs =
            capteurs.where((c) => c.statut.toLowerCase() == 'offline').length;
        final int errorCapteurs =
            capteurs.where((c) => c.statut.toLowerCase() == 'error').length;

        // Grouper par type
        final Map<String, List<Capteur>> grouped = {};
        for (final c in capteurs) {
          final key = _normalizeType(c.type);
          grouped.putIfAbsent(key, () => []).add(c);
        }

        return AdminShell(
          currentRoute: RouteNames.adminIotDashboard,
          title: 'IoT Dashboard',
          subtitle:
              'Supervision en temps réel : capteurs, barrière, ascenseur et équipements terrain.',
          onRefresh: _fetchAll,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER BANNER ─────────────────────────────────
              _IotBanner(
                totalCapteurs: totalCapteurs,
                onlineCapteurs: onlineCapteurs,
                offlineCapteurs: offlineCapteurs,
                errorCapteurs: errorCapteurs,
                isRefreshing: provider.isRefreshing,
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // ── LIGNE 1 : BARRIÈRE + ASCENSEUR + POIDS ─────────
              const Text(
                'Équipements critiques',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              _ResponsiveRow(
                children: [
                  // Barrière
                  _EquipmentCard(
                    icon: Icons.sensor_door_rounded,
                    title: 'Barrière d\'entrée',
                    subtitle: 'Contrôle d\'accès automatique',
                    statusLabel: _barrierStatus(dashboard),
                    statusColor: _barrierColor(dashboard),
                    details: [
                      _DetailItem(
                        label: 'Capteur IR1',
                        value: _irValue(dashboard, 'IR1'),
                        icon: Icons.sensors_rounded,
                      ),
                      _DetailItem(
                        label: 'Capteur IR2',
                        value: _irValue(dashboard, 'IR2'),
                        icon: Icons.sensors_rounded,
                      ),
                    ],
                  ),

                  // Ascenseur
                  _EquipmentCard(
                    icon: Icons.elevator_rounded,
                    title: 'Ascenseur',
                    subtitle: 'Transport véhicules (Nano I2C)',
                    statusLabel: elevator?.statut ?? 'N/A',
                    statusColor: _elevatorColor(elevator?.statut),
                    details: [
                      _DetailItem(
                        label: 'Niveau actuel',
                        value: elevator != null
                            ? 'Étage ${elevator.niveauActuel}'
                            : '—',
                        icon: Icons.stairs_rounded,
                      ),
                      _DetailItem(
                        label: 'ID ascenseur',
                        value: elevator != null ? '#${elevator.id}' : '—',
                        icon: Icons.tag_rounded,
                      ),
                    ],
                  ),

                  // Capteur de poids
                  _EquipmentCard(
                    icon: Icons.monitor_weight_rounded,
                    title: 'Capteur de poids',
                    subtitle: 'Détection charge véhicule',
                    statusLabel: _weightStatus(dashboard),
                    statusColor: _weightColor(dashboard),
                    details: [
                      _DetailItem(
                        label: 'Dernière lecture',
                        value: _weightValue(dashboard),
                        icon: Icons.scale_rounded,
                      ),
                      _DetailItem(
                        label: 'Seuil critique',
                        value: '3 500 kg',
                        icon: Icons.warning_amber_rounded,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // ── LIGNE 2 : ANPR + RFID ──────────────────────────
              const Text(
                'Identification & accès',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              _ResponsiveRow(
                children: [
                  // ANPR caméra
                  _EquipmentCard(
                    icon: Icons.camera_alt_rounded,
                    title: 'Caméra ANPR',
                    subtitle: 'Lecture plaques immatriculation',
                    statusLabel: 'En ligne',
                    statusColor: AppColors.sensorOnline,
                    details: [
                      _DetailItem(
                        label: 'Protocole',
                        value: 'TCP Socket',
                        icon: Icons.lan_rounded,
                      ),
                      _DetailItem(
                        label: 'PC ANPR',
                        value: '192.168.111.22:5000',
                        icon: Icons.computer_rounded,
                      ),
                    ],
                  ),

                  // RFID
                  _EquipmentCard(
                    icon: Icons.contactless_rounded,
                    title: 'RFID / Badge',
                    subtitle: 'Accès abonnés et personnel',
                    statusLabel: _rfidStatus(capteurs),
                    statusColor: _rfidColor(capteurs),
                    details: [
                      _DetailItem(
                        label: 'Lecteurs détectés',
                        value: '${_rfidCount(capteurs)}',
                        icon: Icons.nfc_rounded,
                      ),
                      _DetailItem(
                        label: 'Protocole',
                        value: 'I2C (Uno 0x08)',
                        icon: Icons.memory_rounded,
                      ),
                    ],
                  ),

                  // Capteur présence
                  _EquipmentCard(
                    icon: Icons.visibility_rounded,
                    title: 'Capteurs de présence',
                    subtitle: 'Détection place occupée',
                    statusLabel: _presenceStatus(capteurs),
                    statusColor: _presenceColor(capteurs),
                    details: [
                      _DetailItem(
                        label: 'Capteurs présence',
                        value: '${_presenceCount(capteurs)}',
                        icon: Icons.sensors_rounded,
                      ),
                      _DetailItem(
                        label: 'Déclenchements actifs',
                        value: '${_activePresence(capteurs)}',
                        icon: Icons.directions_car_rounded,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // ── LISTE CAPTEURS ─────────────────────────────────
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tous les capteurs',
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  _StatusLegend(),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (provider.isLoading && capteurs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (capteurs.isEmpty)
                _EmptyCapteurs()
              else
                _CapteurGrid(capteurs: capteurs, grouped: grouped, recentlyChanged: _recentlyChanged),

              // ── ALERTES CAPTEURS RÉCENTES ──────────────────────
              if (sensorAlerts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sectionGap),
                const Text(
                  'Alertes capteurs actives',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                _SensorAlertsList(alerts: sensorAlerts),
              ],

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        );
      },
    );
  }

  // ── HELPERS ──────────────────────────────────────────────

  String _normalizeType(String type) {
    final t = type.toLowerCase();
    if (t.contains('ir') || t.contains('infrarouge')) return 'IR';
    if (t.contains('rfid') || t.contains('badge')) return 'RFID';
    if (t.contains('presence') || t.contains('présence')) return 'Présence';
    if (t.contains('poids') || t.contains('weight')) return 'Poids';
    if (t.contains('anpr') || t.contains('camera') || t.contains('caméra')) {
      return 'ANPR';
    }
    if (t.contains('barriere') || t.contains('barrière')) return 'Barrière';
    return type;
  }

  String _barrierStatus(Map<String, dynamic> d) {
    final v = d['barrier_status']?.toString().toLowerCase() ?? '';
    if (v.contains('open')) return 'Ouverte';
    if (v.contains('closed') || v.contains('close')) return 'Fermée';
    return 'Fermée';
  }

  Color _barrierColor(Map<String, dynamic> d) {
    final v = d['barrier_status']?.toString().toLowerCase() ?? '';
    return v.contains('open') ? AppColors.warning : AppColors.sensorOnline;
  }

  String _irValue(Map<String, dynamic> d, String key) {
    final v = d[key.toLowerCase()];
    if (v == null) return '—';
    return v.toString() == '0' ? 'Détecté' : 'Libre';
  }

  Color _elevatorColor(String? s) {
    if (s == null) return AppColors.grey400;
    final v = s.toLowerCase();
    if (v.contains('idle') || v.contains('attente')) return AppColors.sensorOnline;
    if (v.contains('moving') || v.contains('mouvement')) return AppColors.warning;
    if (v.contains('error')) return AppColors.sensorError;
    return AppColors.info;
  }

  String _weightValue(Map<String, dynamic> d) {
    final v = d['last_weight'] ?? d['poids'];
    return v != null ? '$v kg' : '— kg';
  }

  String _weightStatus(Map<String, dynamic> d) {
    final v = double.tryParse(d['last_weight']?.toString() ?? '');
    if (v == null) return 'Inactif';
    if (v > 3500) return 'Surcharge';
    if (v > 0) return 'Normal';
    return 'Inactif';
  }

  Color _weightColor(Map<String, dynamic> d) {
    final v = double.tryParse(d['last_weight']?.toString() ?? '');
    if (v == null || v == 0) return AppColors.grey400;
    if (v > 3500) return AppColors.sensorError;
    return AppColors.sensorOnline;
  }

  String _rfidStatus(List<Capteur> capteurs) {
    final rfid = capteurs.where((c) => c.type.toLowerCase().contains('rfid'));
    if (rfid.isEmpty) return 'Non configuré';
    return rfid.any((c) => c.statut.toLowerCase() == 'online')
        ? 'En ligne'
        : 'Hors ligne';
  }

  Color _rfidColor(List<Capteur> capteurs) {
    final rfid = capteurs.where((c) => c.type.toLowerCase().contains('rfid'));
    if (rfid.isEmpty) return AppColors.grey400;
    return rfid.any((c) => c.statut.toLowerCase() == 'online')
        ? AppColors.sensorOnline
        : AppColors.sensorOffline;
  }

  int _rfidCount(List<Capteur> capteurs) =>
      capteurs.where((c) => c.type.toLowerCase().contains('rfid')).length;

  String _presenceStatus(List<Capteur> capteurs) {
    final p =
        capteurs.where((c) => c.type.toLowerCase().contains('presence') ||
            c.type.toLowerCase().contains('présence'));
    if (p.isEmpty) return 'Actifs';
    return '${p.where((c) => c.statut.toLowerCase() == 'online').length}/${p.length} en ligne';
  }

  Color _presenceColor(List<Capteur> capteurs) {
    final p =
        capteurs.where((c) => c.type.toLowerCase().contains('presence') ||
            c.type.toLowerCase().contains('présence'));
    if (p.isEmpty) return AppColors.sensorOnline;
    final offline = p.where((c) => c.statut.toLowerCase() != 'online').length;
    if (offline == 0) return AppColors.sensorOnline;
    if (offline < p.length) return AppColors.warning;
    return AppColors.sensorError;
  }

  int _presenceCount(List<Capteur> capteurs) =>
      capteurs
          .where((c) =>
              c.type.toLowerCase().contains('presence') ||
              c.type.toLowerCase().contains('présence'))
          .length;

  int _activePresence(List<Capteur> capteurs) =>
      capteurs
          .where((c) =>
              (c.type.toLowerCase().contains('presence') ||
                  c.type.toLowerCase().contains('présence')) &&
              c.statut.toLowerCase() == 'online')
          .length;
}

// ══════════════════════════════════════════════════════════════
// WIDGETS INTERNES
// ══════════════════════════════════════════════════════════════

class _IotBanner extends StatelessWidget {
  final int totalCapteurs;
  final int onlineCapteurs;
  final int offlineCapteurs;
  final int errorCapteurs;
  final bool isRefreshing;

  const _IotBanner({
    required this.totalCapteurs,
    required this.onlineCapteurs,
    required this.offlineCapteurs,
    required this.errorCapteurs,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2238), Color(0xFF0D1320)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRefreshing)
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      else
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 6),
                      const Text(
                        'IoT LIVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Supervision des équipements',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'IR, RFID, présence, poids, barrière, ascenseur, ANPR — tout en un seul écran.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Actualisation automatique toutes les 5 s',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Column(
            children: [
              _BannerStat(
                label: 'Total',
                value: '$totalCapteurs',
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              _BannerStat(
                label: 'En ligne',
                value: '$onlineCapteurs',
                color: AppColors.sensorOnline,
              ),
              const SizedBox(height: AppSpacing.sm),
              _BannerStat(
                label: 'Offline',
                value: '$offlineCapteurs',
                color: AppColors.sensorOffline,
              ),
              if (errorCapteurs > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                _BannerStat(
                  label: 'Erreur',
                  value: '$errorCapteurs',
                  color: AppColors.sensorError,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BannerStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveRow({required this.children});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((child) => Expanded(child: child))
            .toList()
            .expand((w) => [w, const SizedBox(width: AppSpacing.md)])
            .toList()
          ..removeLast(),
      );
    }

    return Column(
      children: children
          .map((child) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: child,
              ))
          .toList(),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _EquipmentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final List<_DetailItem> details;

  const _EquipmentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: statusColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppSpacing.md),
            ...details.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(d.icon,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        d.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      d.value,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CapteurGrid extends StatelessWidget {
  final List<Capteur> capteurs;
  final Map<String, List<Capteur>> grouped;
  final Set<int> recentlyChanged;

  const _CapteurGrid({
    required this.capteurs,
    required this.grouped,
    required this.recentlyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: _CapteurTypeSection(
            typeName: entry.key,
            capteurs: entry.value,
            recentlyChanged: recentlyChanged,
          ),
        );
      }).toList(),
    );
  }
}

class _CapteurTypeSection extends StatelessWidget {
  final String typeName;
  final List<Capteur> capteurs;
  final Set<int> recentlyChanged;

  const _CapteurTypeSection({
    required this.typeName,
    required this.capteurs,
    required this.recentlyChanged,
  });

  IconData _iconForType(String t) {
    switch (t) {
      case 'IR':
        return Icons.sensors_rounded;
      case 'RFID':
        return Icons.contactless_rounded;
      case 'Présence':
        return Icons.visibility_rounded;
      case 'Poids':
        return Icons.monitor_weight_rounded;
      case 'ANPR':
        return Icons.camera_alt_rounded;
      case 'Barrière':
        return Icons.sensor_door_rounded;
      default:
        return Icons.memory_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = capteurs
        .where((c) => c.statut.toLowerCase() == 'online')
        .length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(_iconForType(typeName),
                    size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    typeName,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$online/${capteurs.length} en ligne',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: online == capteurs.length
                        ? AppColors.sensorOnline
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: capteurs.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.border, height: 1),
            itemBuilder: (context, index) {
              final c = capteurs[index];
              final color = _statusColor(c.statut);
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    color: recentlyChanged.contains(c.id)
                        ? color.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      // Dot avec pulse si changé
                      recentlyChanged.contains(c.id)
                          ? _PulseDot(color: color)
                          : Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Capteur #${c.id}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (recentlyChanged.contains(c.id))
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: Text(
                            'CHANGÉ',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      Text(
                        c.type,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          border: recentlyChanged.contains(c.id)
                              ? Border.all(color: color.withValues(alpha: 0.5))
                              : null,
                        ),
                        child: Text(
                          c.statut,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
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

class _SensorAlertsList extends StatelessWidget {
  final List<dynamic> alerts;

  const _SensorAlertsList({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final limited = alerts.take(5).toList();
    return Column(
      children: limited.map((alerte) {
        final String type = alerte.type ?? 'Alerte';
        final String niveau = alerte.niveau ?? 'info';
        final Color color = niveau.toLowerCase() == 'critique'
            ? AppColors.alertCritical
            : niveau.toLowerCase() == 'warning'
                ? AppColors.alertWarning
                : AppColors.alertInfo;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: color, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  type,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  niveau.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dot(color: AppColors.sensorOnline, label: 'En ligne'),
        const SizedBox(width: AppSpacing.md),
        _Dot(color: AppColors.sensorOffline, label: 'Offline'),
        const SizedBox(width: AppSpacing.md),
        _Dot(color: AppColors.sensorError, label: 'Erreur'),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;

  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _EmptyCapteurs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.sensors_off_rounded,
              size: 40, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucun capteur trouvé',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Vérifiez la connexion au Raspberry Pi.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PULSE DOT — animation pour capteur qui vient de changer
// ══════════════════════════════════════════════════════════════
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.7, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Opacity(
          opacity: _opacity.value,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
