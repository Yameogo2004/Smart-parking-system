class StatsOverview {
  final double weeklyRevenue;
  final int averageDailyTraffic;
  final double averageParkingDurationHours;
  final int weeklyEvCharges;
  final List<DailyTrafficPoint> weeklyTraffic;
  final List<RevenuePoint> revenueSeries;
  final List<VehicleWeightPoint> weightSeries;

  const StatsOverview({
    required this.weeklyRevenue,
    required this.averageDailyTraffic,
    required this.averageParkingDurationHours,
    required this.weeklyEvCharges,
    required this.weeklyTraffic,
    required this.revenueSeries,
    required this.weightSeries,
  });

  factory StatsOverview.empty() {
    return const StatsOverview(
      weeklyRevenue: 0,
      averageDailyTraffic: 0,
      averageParkingDurationHours: 0,
      weeklyEvCharges: 0,
      weeklyTraffic: [],
      revenueSeries: [],
      weightSeries: [],
    );
  }

  factory StatsOverview.fromJson(Map<String, dynamic> json) {
    return StatsOverview(
      weeklyRevenue: _toDouble(json['weekly_revenue']),
      averageDailyTraffic: _toInt(json['average_daily_traffic']),
      averageParkingDurationHours:
          _toDouble(json['average_parking_duration_hours']),
      weeklyEvCharges: _toInt(json['weekly_ev_charges']),
      weeklyTraffic: (json['weekly_traffic'] as List? ?? [])
          .map((e) => DailyTrafficPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      revenueSeries: (json['revenue_series'] as List? ?? [])
          .map((e) => RevenuePoint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      weightSeries: (json['weight_series'] as List? ?? [])
          .map((e) => VehicleWeightPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekly_revenue': weeklyRevenue,
      'average_daily_traffic': averageDailyTraffic,
      'average_parking_duration_hours': averageParkingDurationHours,
      'weekly_ev_charges': weeklyEvCharges,
      'weekly_traffic': weeklyTraffic.map((e) => e.toJson()).toList(),
      'revenue_series': revenueSeries.map((e) => e.toJson()).toList(),
      'weight_series': weightSeries.map((e) => e.toJson()).toList(),
    };
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

class DailyTrafficPoint {
  final String label;
  final int value;

  const DailyTrafficPoint({
    required this.label,
    required this.value,
  });

  factory DailyTrafficPoint.fromJson(Map<String, dynamic> json) {
    return DailyTrafficPoint(
      label: (json['label'] ?? '').toString(),
      value: json['value'] is int
          ? json['value'] as int
          : int.tryParse(json['value']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class RevenuePoint {
  final String label;
  final double value;

  const RevenuePoint({
    required this.label,
    required this.value,
  });

  factory RevenuePoint.fromJson(Map<String, dynamic> json) {
    return RevenuePoint(
      label: (json['label'] ?? '').toString(),
      value: json['value'] is double
          ? json['value'] as double
          : double.tryParse(json['value']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class VehicleWeightPoint {
  final String label;
  final double averageWeight;

  const VehicleWeightPoint({
    required this.label,
    required this.averageWeight,
  });

  factory VehicleWeightPoint.fromJson(Map<String, dynamic> json) {
    return VehicleWeightPoint(
      label: (json['label'] ?? '').toString(),
      averageWeight: json['average_weight'] is double
          ? json['average_weight'] as double
          : double.tryParse(json['average_weight']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'average_weight': averageWeight,
    };
  }
}
