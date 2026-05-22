class BlacklistEvent {
  final int id;
  final int vehicleId;
  final String matricule;
  final String eventType;
  final String riskLevel;
  final String description;
  final DateTime detectedAt;
  final String? assignedSpot;
  final String? actualSpot;
  final bool resolved;

  const BlacklistEvent({
    required this.id,
    required this.vehicleId,
    required this.matricule,
    required this.eventType,
    required this.riskLevel,
    required this.description,
    required this.detectedAt,
    this.assignedSpot,
    this.actualSpot,
    required this.resolved,
  });

  factory BlacklistEvent.fromJson(Map<String, dynamic> json) {
    return BlacklistEvent(
      id: _toInt(json['id']),
      vehicleId: _toInt(json['vehicle_id']),
      matricule: (json['matricule'] ?? '').toString(),
      eventType: (json['event_type'] ?? '').toString(),
      riskLevel: (json['risk_level'] ?? 'low').toString(),
      description: (json['description'] ?? '').toString(),
      detectedAt: DateTime.tryParse(
            (json['detected_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      assignedSpot: json['assigned_spot']?.toString(),
      actualSpot: json['actual_spot']?.toString(),
      resolved: json['resolved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'matricule': matricule,
      'event_type': eventType,
      'risk_level': riskLevel,
      'description': description,
      'detected_at': detectedAt.toIso8601String(),
      'assigned_spot': assignedSpot,
      'actual_spot': actualSpot,
      'resolved': resolved,
    };
  }

  BlacklistEvent copyWith({
    int? id,
    int? vehicleId,
    String? matricule,
    String? eventType,
    String? riskLevel,
    String? description,
    DateTime? detectedAt,
    String? assignedSpot,
    String? actualSpot,
    bool? resolved,
  }) {
    return BlacklistEvent(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      matricule: matricule ?? this.matricule,
      eventType: eventType ?? this.eventType,
      riskLevel: riskLevel ?? this.riskLevel,
      description: description ?? this.description,
      detectedAt: detectedAt ?? this.detectedAt,
      assignedSpot: assignedSpot ?? this.assignedSpot,
      actualSpot: actualSpot ?? this.actualSpot,
      resolved: resolved ?? this.resolved,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
