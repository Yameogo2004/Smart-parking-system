class DashboardSummary {
  final int totalPlaces;
  final int occupiedPlaces;
  final int freePlaces;
  final int reservedPlaces;
  final int totalVehicules;
  final int totalCapteurs;
  final int offlineCapteurs;
  final int totalAlertes;
  final int criticalAlertes;
  final int activeStationnements;
  final int totalPaiements;
  final String elevatorStatus;
  final int elevatorLevel;
  final double occupancyRate;

  const DashboardSummary({
    required this.totalPlaces,
    required this.occupiedPlaces,
    required this.freePlaces,
    required this.reservedPlaces,
    required this.totalVehicules,
    required this.totalCapteurs,
    required this.offlineCapteurs,
    required this.totalAlertes,
    required this.criticalAlertes,
    required this.activeStationnements,
    required this.totalPaiements,
    required this.elevatorStatus,
    required this.elevatorLevel,
    required this.occupancyRate,
  });

  factory DashboardSummary.empty() {
    return const DashboardSummary(
      totalPlaces: 0,
      occupiedPlaces: 0,
      freePlaces: 0,
      reservedPlaces: 0,
      totalVehicules: 0,
      totalCapteurs: 0,
      offlineCapteurs: 0,
      totalAlertes: 0,
      criticalAlertes: 0,
      activeStationnements: 0,
      totalPaiements: 0,
      elevatorStatus: 'N/A',
      elevatorLevel: 0,
      occupancyRate: 0,
    );
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final totalPlaces = _toInt(json['total_places']);
    final occupiedPlaces = _toInt(json['occupied_places']);
    final freePlaces = _toInt(json['free_places']);
    final reservedPlaces = _toInt(json['reserved_places']);

    final double occupancyRate = totalPlaces > 0
        ? (occupiedPlaces / totalPlaces) * 100
        : _toDouble(json['occupancy_rate']);

    return DashboardSummary(
      totalPlaces: totalPlaces,
      occupiedPlaces: occupiedPlaces,
      freePlaces: freePlaces,
      reservedPlaces: reservedPlaces,
      totalVehicules: _toInt(json['total_vehicules']),
      totalCapteurs: _toInt(json['total_capteurs']),
      offlineCapteurs: _toInt(json['offline_capteurs']),
      totalAlertes: _toInt(json['total_alertes']),
      criticalAlertes: _toInt(json['critical_alertes']),
      activeStationnements: _toInt(json['active_stationnements']),
      totalPaiements: _toInt(json['total_paiements']),
      elevatorStatus: (json['elevator_status'] ?? 'N/A').toString(),
      elevatorLevel: _toInt(json['elevator_level']),
      occupancyRate: occupancyRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_places': totalPlaces,
      'occupied_places': occupiedPlaces,
      'free_places': freePlaces,
      'reserved_places': reservedPlaces,
      'total_vehicules': totalVehicules,
      'total_capteurs': totalCapteurs,
      'offline_capteurs': offlineCapteurs,
      'total_alertes': totalAlertes,
      'critical_alertes': criticalAlertes,
      'active_stationnements': activeStationnements,
      'total_paiements': totalPaiements,
      'elevator_status': elevatorStatus,
      'elevator_level': elevatorLevel,
      'occupancy_rate': occupancyRate,
    };
  }

  DashboardSummary copyWith({
    int? totalPlaces,
    int? occupiedPlaces,
    int? freePlaces,
    int? reservedPlaces,
    int? totalVehicules,
    int? totalCapteurs,
    int? offlineCapteurs,
    int? totalAlertes,
    int? criticalAlertes,
    int? activeStationnements,
    int? totalPaiements,
    String? elevatorStatus,
    int? elevatorLevel,
    double? occupancyRate,
  }) {
    return DashboardSummary(
      totalPlaces: totalPlaces ?? this.totalPlaces,
      occupiedPlaces: occupiedPlaces ?? this.occupiedPlaces,
      freePlaces: freePlaces ?? this.freePlaces,
      reservedPlaces: reservedPlaces ?? this.reservedPlaces,
      totalVehicules: totalVehicules ?? this.totalVehicules,
      totalCapteurs: totalCapteurs ?? this.totalCapteurs,
      offlineCapteurs: offlineCapteurs ?? this.offlineCapteurs,
      totalAlertes: totalAlertes ?? this.totalAlertes,
      criticalAlertes: criticalAlertes ?? this.criticalAlertes,
      activeStationnements:
          activeStationnements ?? this.activeStationnements,
      totalPaiements: totalPaiements ?? this.totalPaiements,
      elevatorStatus: elevatorStatus ?? this.elevatorStatus,
      elevatorLevel: elevatorLevel ?? this.elevatorLevel,
      occupancyRate: occupancyRate ?? this.occupancyRate,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
