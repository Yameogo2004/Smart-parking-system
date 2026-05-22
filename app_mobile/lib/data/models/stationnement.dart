class Stationnement {
  final int id;
  final int vehicleId;
  final int parkingSpotId;
  final DateTime entree;
  final DateTime? sortie;

  Stationnement({
    required this.id,
    required this.vehicleId,
    required this.parkingSpotId,
    required this.entree,
    this.sortie,
  });

  factory Stationnement.fromJson(Map<String, dynamic> json) {
    return Stationnement(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      parkingSpotId: json['parking_spot_id'],
      entree: DateTime.parse(json['entree']),
      sortie: json['sortie'] != null
          ? DateTime.parse(json['sortie'])
          : null,
    );
  }
}
