import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/parking_spot.dart';
import '../../../../data/services/api_service.dart';
import '../../../widgets/layout/admin_shell.dart';
import '../../../widgets/parking/parking_legend.dart';
import '../../../widgets/parking/parking_level_tabs.dart';
import '../../../widgets/parking/parking_spot_tile.dart';
import '../../../widgets/tables/filter_bar.dart';
import '../../../widgets/tables/search_toolbar.dart';

class AdminParkingGridScreen extends StatefulWidget {
  const AdminParkingGridScreen({super.key});

  @override
  State<AdminParkingGridScreen> createState() => _AdminParkingGridScreenState();
}

class _AdminParkingGridScreenState extends State<AdminParkingGridScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  int _selectedLevel = 0;
  String _selectedStatus = 'all';
  String _search = '';

  List<ParkingSpot> _spots = [];

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(ApiConstants.adminParkingSpots);
      setState(() {
        _spots = _parseParkingSpots(response);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger la grille du parking.\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ParkingSpot> _parseParkingSpots(dynamic response) {
    if (response is List) {
      return response
          .map((item) => ParkingSpot.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['places'] is List) {
      return (response['places'] as List)
          .map((item) => ParkingSpot.fromJson(Map<String, dynamic>.from(item)))
          .toList();
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
    return _spots.where((spot) {
      final bool matchesLevel = _levelFromSpot(spot) == _selectedLevel;
      final bool matchesSearch = spot.numero.toLowerCase().contains(_search) ||
          spot.id.toString().contains(_search);

      final bool matchesStatus = _selectedStatus == 'all'
          ? true
          : _normalizeStatus(spot.statut) == _selectedStatus;

      return matchesLevel && matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AdminShell(
      currentRoute: RouteNames.adminParkingGrid,
      title: 'Parking Grid',
      subtitle: 'Visualisation temps réel des places par niveau.',
      onRefresh: _loadSpots,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ParkingLevelTabs(
            selectedLevel: _selectedLevel,
            items: const [
              ParkingLevelTabItem(value: 0, label: 'Rez-de-chaussée'),
              ParkingLevelTabItem(value: 1, label: 'Niveau 1'),
              ParkingLevelTabItem(value: 2, label: 'Niveau 2'),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLevel = value;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SearchToolbar(
            hintText: 'Rechercher par numéro ou ID...',
            onChanged: (value) {
              setState(() {
                _search = value.trim().toLowerCase();
              });
            },
            trailing: FilterBar(
              selectedValue: _selectedStatus,
              items: const [
                FilterBarItem(label: 'Tous', value: 'all'),
                FilterBarItem(label: 'Libre', value: 'libre'),
                FilterBarItem(label: 'Occupée', value: 'occupee'),
                FilterBarItem(label: 'Réservée', value: 'reservee'),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const ParkingLegend(),
          const SizedBox(height: AppSpacing.sectionGap),
          if (_filteredSpots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Aucune place trouvée pour ce filtre.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
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
                  itemCount: _filteredSpots.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    crossAxisSpacing: AppSpacing.dashboardGridGap,
                    mainAxisSpacing: AppSpacing.dashboardGridGap,
                    childAspectRatio: 0.92,
                  ),
                  itemBuilder: (context, index) {
                    final spot = _filteredSpots[index];
                    return ParkingSpotTile(
                      id: spot.id,
                      numero: spot.numero,
                      statut: spot.statut,
                      subtitle: 'Niveau ${_levelFromSpot(spot)}',
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
