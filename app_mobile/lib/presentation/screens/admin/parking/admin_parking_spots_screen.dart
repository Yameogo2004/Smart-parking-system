import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/parking_spot.dart';
import '../../../../data/services/api_service.dart';
import '../../../widgets/layout/dashboard_shell.dart';
import '../../../widgets/status/status_badge.dart';

class AdminParkingSpotsScreen extends StatefulWidget {
  const AdminParkingSpotsScreen({super.key});

  @override
  State<AdminParkingSpotsScreen> createState() =>
      _AdminParkingSpotsScreenState();
}

class _AdminParkingSpotsScreenState extends State<AdminParkingSpotsScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedStatus = 'Tous';
  int _selectedLevel = 0;

  List<ParkingSpot> _allSpots = [];

  @override
  void initState() {
    super.initState();
    _loadParkingSpots();
  }

  Future<void> _loadParkingSpots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(ApiConstants.adminParkingSpots);
      final List<ParkingSpot> parsedSpots = _parseParkingSpots(response);

      setState(() {
        _allSpots = parsedSpots;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les places de parking.\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshParkingSpots() async {
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(ApiConstants.adminParkingSpots);
      final List<ParkingSpot> parsedSpots = _parseParkingSpots(response);

      setState(() {
        _allSpots = parsedSpots;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible d’actualiser les places.\n$e';
      });
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  List<ParkingSpot> _parseParkingSpots(dynamic response) {
    if (response is List) {
      return response
          .map((item) => ParkingSpot.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map) {
      if (response['places'] is List) {
        return (response['places'] as List)
            .map(
              (item) => ParkingSpot.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      if (response['parking_spots'] is List) {
        return (response['parking_spots'] as List)
            .map(
              (item) => ParkingSpot.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      if (response['data'] is List) {
        return (response['data'] as List)
            .map(
              (item) => ParkingSpot.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
    }

    return [];
  }

  int _levelFromSpot(ParkingSpot spot) {
    final numero = spot.numero.toUpperCase();
    if (numero.startsWith('P0-')) return 0;
    if (numero.startsWith('P1-')) return 1;
    if (numero.startsWith('P2-')) return 2;
    return 0;
  }

  String _normalizeStatus(String value) {
    return value
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e');
  }

  List<ParkingSpot> get _filteredSpots {
    return _allSpots.where((spot) {
      final matchesSearch =
          spot.numero.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              spot.id.toString().contains(_searchQuery);

      final matchesStatus = _selectedStatus == 'Tous'
          ? true
          : _normalizeStatus(spot.statut) == _normalizeStatus(_selectedStatus);

      final matchesLevel = _levelFromSpot(spot) == _selectedLevel;

      return matchesSearch && matchesStatus && matchesLevel;
    }).toList();
  }

  int get _freeCount =>
      _allSpots.where((spot) => _normalizeStatus(spot.statut) == 'libre').length;

  int get _occupiedCount => _allSpots
      .where((spot) => _normalizeStatus(spot.statut) == 'occupee')
      .length;

  int get _reservedCount => _allSpots
      .where((spot) => _normalizeStatus(spot.statut) == 'reservee')
      .length;

  int get _otherCount =>
      _allSpots.length - _freeCount - _occupiedCount - _reservedCount;

  @override
  Widget build(BuildContext context) {
    final filteredSpots = _filteredSpots;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null && _allSpots.isEmpty) {
      return AdminModuleShell(
        currentRoute: RouteNames.adminParkingSpots,
        title: 'Parking Grid',
        subtitle: 'Visualisation temps réel des places du parking.',
        onRefresh: _refreshParkingSpots,
        child: _ParkingSpotsErrorState(
          message: _errorMessage!,
          onRetry: _loadParkingSpots,
        ),
      );
    }

    return AdminModuleShell(
      currentRoute: RouteNames.adminParkingSpots,
      title: 'Parking Grid',
      subtitle:
          'Visualisez les places par niveau, filtrez l’occupation et suivez les réservations.',
      onRefresh: _refreshParkingSpots,
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              RouteNames.adminParking,
            );
          },
          icon: const Icon(Icons.analytics_rounded),
          label: const Text('Vue globale'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ParkingSpotsHeaderCard(
            total: _allSpots.length,
            free: _freeCount,
            occupied: _occupiedCount,
            reserved: _reservedCount,
            other: _otherCount,
            isRefreshing: _isRefreshing,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const Text(
            'Niveaux',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _LevelChip(
                label: 'Rez-de-chaussée',
                selected: _selectedLevel == 0,
                onTap: () => setState(() => _selectedLevel = 0),
              ),
              _LevelChip(
                label: 'Niveau 1',
                selected: _selectedLevel == 1,
                onTap: () => setState(() => _selectedLevel = 1),
              ),
              _LevelChip(
                label: 'Niveau 2',
                selected: _selectedLevel == 2,
                onTap: () => setState(() => _selectedLevel = 2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;

              if (compact) {
                return Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Rechercher par numéro ou ID...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _StatusFilters(
                      selectedStatus: _selectedStatus,
                      onChanged: (value) {
                        setState(() => _selectedStatus = value);
                      },
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Rechercher par numéro ou ID...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 4,
                    child: _StatusFilters(
                      selectedStatus: _selectedStatus,
                      onChanged: (value) {
                        setState(() => _selectedStatus = value);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const _ParkingLegend(),
          const SizedBox(height: AppSpacing.sectionGap),
          if (_errorMessage != null && _allSpots.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                _errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          if (filteredSpots.isEmpty)
            const _ParkingSpotsEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int count = 6;
                if (constraints.maxWidth < 1300) count = 5;
                if (constraints.maxWidth < 1050) count = 4;
                if (constraints.maxWidth < 820) count = 3;
                if (constraints.maxWidth < 560) count = 2;

                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: filteredSpots.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    crossAxisSpacing: AppSpacing.dashboardGridGap,
                    mainAxisSpacing: AppSpacing.dashboardGridGap,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final spot = filteredSpots[index];
                    return _ParkingSpotTile(spot: spot);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ParkingSpotsHeaderCard extends StatelessWidget {
  final int total;
  final int free;
  final int occupied;
  final int reserved;
  final int other;
  final bool isRefreshing;

  const _ParkingSpotsHeaderCard({
    required this.total,
    required this.free,
    required this.occupied,
    required this.reserved,
    required this.other,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supervision des places',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Consultez l’état détaillé de chaque place de parking.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (isRefreshing) ...[
            const SizedBox(height: AppSpacing.sm),
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Actualisation...',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MiniOverviewBadge(
                label: 'Total',
                value: '$total',
                color: AppColors.primary,
              ),
              _MiniOverviewBadge(
                label: 'Libres',
                value: '$free',
                color: AppColors.parkingFree,
              ),
              _MiniOverviewBadge(
                label: 'Occupées',
                value: '$occupied',
                color: AppColors.parkingOccupied,
              ),
              _MiniOverviewBadge(
                label: 'Réservées',
                value: '$reserved',
                color: AppColors.parkingReserved,
              ),
              if (other > 0)
                _MiniOverviewBadge(
                  label: 'Autres',
                  value: '$other',
                  color: AppColors.grey400,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniOverviewBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniOverviewBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LevelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? AppColors.primary.withValues(alpha: 0.16)
        : AppColors.surfaceLight;

    final Color textColor =
        selected ? AppColors.primary : AppColors.textSecondary;

    final Color borderColor =
        selected ? AppColors.primary : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onChanged;

  const _StatusFilters({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _StatusFilterChip(
          label: 'Tous',
          selected: selectedStatus == 'Tous',
          onTap: () => onChanged('Tous'),
        ),
        _StatusFilterChip(
          label: 'Libre',
          selected: selectedStatus == 'Libre',
          onTap: () => onChanged('Libre'),
        ),
        _StatusFilterChip(
          label: 'Occupée',
          selected: selectedStatus == 'Occupée',
          onTap: () => onChanged('Occupée'),
        ),
        _StatusFilterChip(
          label: 'Réservée',
          selected: selectedStatus == 'Réservée',
          onTap: () => onChanged('Réservée'),
        ),
      ],
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? AppColors.primary.withValues(alpha: 0.16)
        : AppColors.surfaceLight;

    final Color textColor =
        selected ? AppColors.primary : AppColors.textSecondary;

    final Color borderColor =
        selected ? AppColors.primary : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ParkingLegend extends StatelessWidget {
  const _ParkingLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: const [
        _LegendItem(label: 'Libre', color: AppColors.parkingFree),
        _LegendItem(label: 'Occupée', color: AppColors.parkingOccupied),
        _LegendItem(label: 'Réservée', color: AppColors.parkingReserved),
        _LegendItem(label: 'Indisponible', color: AppColors.parkingDisabled),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _ParkingSpotTile extends StatelessWidget {
  final ParkingSpot spot;

  const _ParkingSpotTile({
    required this.spot,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(spot.statut);
    final IconData statusIcon = _statusIcon(spot.statut);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spot.numero,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 26,
            ),
          ),
          const Spacer(),
          Text(
            'ID ${spot.id}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(
            label: spot.statut,
            variant: _statusVariant(spot.statut),
          ),
        ],
      ),
    );
  }

  StatusBadgeVariant _statusVariant(String status) {
    switch (status.toLowerCase()) {
      case 'libre':
        return StatusBadgeVariant.success;
      case 'occupée':
      case 'occupee':
        return StatusBadgeVariant.danger;
      case 'réservée':
      case 'reservee':
        return StatusBadgeVariant.info;
      default:
        return StatusBadgeVariant.neutral;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'libre':
        return AppColors.parkingFree;
      case 'occupée':
      case 'occupee':
        return AppColors.parkingOccupied;
      case 'réservée':
      case 'reservee':
        return AppColors.parkingReserved;
      case 'disabled':
      case 'indisponible':
        return AppColors.parkingDisabled;
      default:
        return AppColors.grey400;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'libre':
        return Icons.check_circle_rounded;
      case 'occupée':
      case 'occupee':
        return Icons.directions_car_filled_rounded;
      case 'réservée':
      case 'reservee':
        return Icons.bookmark_rounded;
      case 'disabled':
      case 'indisponible':
        return Icons.block_rounded;
      default:
        return Icons.local_parking_rounded;
    }
  }
}

class _ParkingSpotsErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ParkingSpotsErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Impossible de charger les places',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParkingSpotsEmptyState extends StatelessWidget {
  const _ParkingSpotsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_parking_outlined,
            size: 44,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Aucune place trouvée',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Essaie de changer le filtre ou le texte de recherche.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
