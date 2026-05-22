import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../data/services/api_service.dart';
import '../../../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _hasActiveParking = false;
  Map<String, dynamic>? _activeParking;
  List<dynamic> _placesParNiveau = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tous';
  late AnimationController _animationController;

  final List<String> _filters = const [
    'Tous',
    'VIP',
    'Électrique',
    'Handicapé',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      _checkActiveParking(),
      _loadPlacesLibres(),
    ]);

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _checkActiveParking() async {
    try {
      final response = await ApiService.get('/api/stationnement/actif');
      if (!mounted) return;

      final stationnement = response['stationnement'];
      final hasActive = response['has_active'] == true && stationnement != null;

      setState(() {
        _hasActiveParking = hasActive;
        _activeParking = hasActive ? Map<String, dynamic>.from(stationnement) : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasActiveParking = false;
        _activeParking = null;
      });
    }
  }

  Future<void> _loadPlacesLibres() async {
    try {
      final response = await ApiService.get('/api/parking/statut-par-niveau');
      if (!mounted) return;

      setState(() {
        _placesParNiveau = response is List ? response : [];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _placesParNiveau = [
          {
            'niveau': 0,
            'libelle': 'Rez-de-chaussée',
            'libres': 8,
            'total': 12,
            'type': 'standard',
          },
          {
            'niveau': 1,
            'libelle': 'Étage 1',
            'libres': 5,
            'total': 12,
            'type': 'electrique',
          },
          {
            'niveau': 2,
            'libelle': 'Étage 2',
            'libres': 3,
            'total': 12,
            'type': 'VIP',
          },
        ];
      });
    }
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isWide = MediaQuery.of(context).size.width >= 1100;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (isWide) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Row(
            children: [
              _ClientSidebar(
                hasActiveParking: _hasActiveParking,
                activeParking: _activeParking,
              ),
              Expanded(
                child: _HomeContent(
                  hasActiveParking: _hasActiveParking,
                  activeParking: _activeParking,
                  placesParNiveau: _placesParNiveau,
                  selectedFilter: _selectedFilter,
                  filters: _filters,
                  animationController: _animationController,
                  onRefresh: _loadUserData,
                  onSelectFilter: _updateFilter,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      drawer: Drawer(
        backgroundColor: colors.surface,
        child: SafeArea(
          child: _ClientSidebar(
            hasActiveParking: _hasActiveParking,
            activeParking: _activeParking,
            compact: true,
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Espace client'),
        centerTitle: false,
      ),
      body: _HomeContent(
        hasActiveParking: _hasActiveParking,
        activeParking: _activeParking,
        placesParNiveau: _placesParNiveau,
        selectedFilter: _selectedFilter,
        filters: _filters,
        animationController: _animationController,
        onRefresh: _loadUserData,
        onSelectFilter: _updateFilter,
      ),
    );
  }
}

class _ClientSidebar extends StatelessWidget {
  final bool hasActiveParking;
  final Map<String, dynamic>? activeParking;
  final bool compact;

  const _ClientSidebar({
    required this.hasActiveParking,
    required this.activeParking,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final colors = context.appColors;

    Widget menuButton({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool isActive = false,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)
                    : colors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : colors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : colors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: compact ? double.infinity : 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        border: compact
            ? null
            : Border(
                right: BorderSide(color: colors.border),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Parking',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Client Dashboard',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
          const SizedBox(height: 22),
          menuButton(
            icon: Icons.dashboard_outlined,
            label: 'Accueil',
            isActive: true,
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.clientDashboard,
                (route) => false,
              );
            },
          ),
          menuButton(
            icon: Icons.edit_calendar_outlined,
            label: 'Réserver',
            onTap: () {
              Navigator.pushNamed(context, RouteNames.clientReservation);
            },
          ),
          menuButton(
            icon: Icons.location_searching_outlined,
            label: 'Localiser',
            onTap: () {
              Navigator.pushNamed(context, RouteNames.clientLocateVehicle);
            },
          ),
          menuButton(
            icon: Icons.qr_code_2_outlined,
            label: 'Ticket',
            onTap: () {
              Navigator.pushNamed(
                context,
                RouteNames.clientActiveParking,
                arguments: activeParking,
              );
            },
          ),
          menuButton(
            icon: Icons.person_outline,
            label: 'Profil',
            onTap: () {
              Navigator.pushNamed(context, RouteNames.clientProfile);
            },
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                  child: Text(
                    user?.nom.isNotEmpty == true ? user!.nom[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nom ?? 'Client',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Accès client',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final bool hasActiveParking;
  final Map<String, dynamic>? activeParking;
  final List<dynamic> placesParNiveau;
  final String selectedFilter;
  final List<String> filters;
  final AnimationController animationController;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSelectFilter;

  const _HomeContent({
    required this.hasActiveParking,
    required this.activeParking,
    required this.placesParNiveau,
    required this.selectedFilter,
    required this.filters,
    required this.animationController,
    required this.onRefresh,
    required this.onSelectFilter,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(animationController),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeBanner(context),
              const SizedBox(height: 18),
              _buildTopStats(context),
              const SizedBox(height: 18),
              _buildQuickActionRow(context),
              const SizedBox(height: 18),
              _buildFilters(context, colors),
              const SizedBox(height: 18),
              if (hasActiveParking && activeParking != null)
                _buildActiveParkingCard(context, activeParking!)
              else
                _buildAvailableSpotsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Text(
              user?.nom.isNotEmpty == true ? user!.nom[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour ${user?.nom ?? 'Client'}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasActiveParking
                      ? 'Votre véhicule est actuellement stationné.'
                      : 'Réservez, localisez et gérez votre stationnement.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats(BuildContext context) {
    final totalLevels = placesParNiveau.length;
    final totalFree = placesParNiveau.fold<int>(
      0,
      (sum, item) => sum + ((item['libres'] ?? 0) as int),
    );
    final totalPlaces = placesParNiveau.fold<int>(
      0,
      (sum, item) => sum + ((item['total'] ?? 0) as int),
    );

    final items = [
      (
        title: 'Niveaux',
        value: '$totalLevels',
        icon: Icons.layers_outlined,
      ),
      (
        title: 'Places libres',
        value: '$totalFree',
        icon: Icons.local_parking_outlined,
      ),
      (
        title: 'Capacité',
        value: '$totalPlaces',
        icon: Icons.domain_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isCompact ? 1 : 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isCompact ? 3.6 : 2.6,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _smallMetricCard(
              context,
              title: item.title,
              value: item.value,
              icon: item.icon,
            );
          },
        );
      },
    );
  }

  Widget _smallMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionRow(BuildContext context) {
    final colors = context.appColors;

    final actions = [
      (
        icon: Icons.edit_calendar_outlined,
        title: 'Réserver',
        route: RouteNames.clientReservation,
      ),
      (
        icon: Icons.location_searching_outlined,
        title: 'Localiser',
        route: RouteNames.clientLocateVehicle,
      ),
      (
        icon: Icons.qr_code_2_outlined,
        title: 'Ticket',
        route: RouteNames.clientActiveParking,
      ),
      (
        icon: Icons.person_outline,
        title: 'Profil',
        route: RouteNames.clientProfile,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions.map((action) {
        return InkWell(
          onTap: () {
            if (action.route == RouteNames.clientActiveParking) {
              Navigator.pushNamed(
                context,
                action.route,
                arguments: activeParking,
              );
              return;
            }
            Navigator.pushNamed(context, action.route);
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  action.icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilters(BuildContext context, AppThemeColors colors) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => onSelectFilter(filter),
            backgroundColor: colors.card,
            selectedColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : colors.border,
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : colors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveParkingCard(
    BuildContext context,
    Map<String, dynamic> parking,
  ) {
    final colors = context.appColors;

    final dynamic rawPlace =
        parking['place_numero'] ?? parking['place'] ?? parking['box'] ?? 'A2';
    final String place = rawPlace.toString();
    final String plaque = (parking['plaque'] ?? 'AB-123-CD').toString();
    final String rfidTicket = (parking['rfid_ticket'] ?? 'RFID001').toString();
    final String dateEntree =
        (parking['date_entree'] ?? parking['entree'] ?? DateTime.now().toString())
            .toString();

    final String niveauLabel = _extractNiveauLabel(place);

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: colors.success,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Stationnement actif',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _infoBox(
                        context,
                        icon: Icons.layers_outlined,
                        label: 'Niveau',
                        value: niveauLabel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoBox(
                        context,
                        icon: Icons.local_parking_outlined,
                        label: 'Place',
                        value: place,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _detailRow(
                  context,
                  Icons.badge_outlined,
                  'Plaque',
                  plaque,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  context,
                  Icons.credit_card_outlined,
                  'Ticket RFID',
                  rfidTicket,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  context,
                  Icons.access_time_outlined,
                  'Entrée',
                  _formatHeure(dateEntree),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.clientActiveParking,
                            arguments: parking,
                          );
                        },
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Voir mon ticket'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.clientLocateVehicle,
                          );
                        },
                        icon: const Icon(Icons.location_searching_outlined),
                        label: const Text('Localiser'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSpotsCard(BuildContext context) {
    final colors = context.appColors;

    List<dynamic> filteredPlaces = placesParNiveau;

    if (selectedFilter != 'Tous') {
      filteredPlaces = placesParNiveau.where((place) {
        final type = (place['type'] ?? 'standard').toString().toLowerCase();

        if (selectedFilter == 'VIP') return type == 'vip';
        if (selectedFilter == 'Électrique') return type == 'electrique';
        if (selectedFilter == 'Handicapé') return type == 'handicape';
        return true;
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Choisissez un niveau selon vos besoins et la disponibilité.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...filteredPlaces.map(
          (niveau) => _buildNiveauCard(
            context,
            niveau: niveau['niveau'] ?? 0,
            libelle: niveau['libelle'] ??
                ((niveau['niveau'] ?? 0) == 0
                    ? 'Rez-de-chaussée'
                    : 'Étage ${niveau['niveau']}'),
            libres: niveau['libres'] ?? 0,
            total: niveau['total'] ?? 12,
            type: (niveau['type'] ?? 'standard').toString(),
          ),
        ),
        if (filteredPlaces.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              'Aucune place disponible pour ce filtre.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildNiveauCard(
    BuildContext context, {
    required int niveau,
    required String libelle,
    required int libres,
    required int total,
    required String type,
  }) {
    final colors = context.appColors;
    final double ratio = total == 0 ? 0 : libres / total;

    Color badgeColor = Theme.of(context).colorScheme.primary;
    IconData icon = Icons.local_parking_outlined;

    switch (type.toLowerCase()) {
      case 'vip':
        badgeColor = Colors.purple;
        icon = Icons.workspace_premium_outlined;
        break;
      case 'electrique':
        badgeColor = colors.parkingElectric;
        icon = Icons.ev_station_outlined;
        break;
      case 'handicape':
        badgeColor = colors.info;
        icon = Icons.accessible_outlined;
        break;
      default:
        badgeColor = Theme.of(context).colorScheme.primary;
        icon = Icons.local_parking_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: badgeColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        libelle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$libres / $total places disponibles',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: libres > 0
                        ? colors.success.withValues(alpha: 0.10)
                        : colors.danger.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    libres > 0 ? '$libres libres' : 'Complet',
                    style: TextStyle(
                      color: libres > 0 ? colors.success : colors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: colors.surfaceLight,
                color: libres > 0 ? badgeColor : colors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
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
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }

  String _formatHeure(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day}/${date.month} - ${date.hour}h$minute';
    } catch (_) {
      return dateString;
    }
  }

  String _extractNiveauLabel(String place) {
    final normalized = place.toUpperCase();

    if (normalized.startsWith('P0-')) return 'RDC';
    if (normalized.startsWith('P1-')) return '1';
    if (normalized.startsWith('P2-')) return '2';
    return 'RDC';
  }
}
