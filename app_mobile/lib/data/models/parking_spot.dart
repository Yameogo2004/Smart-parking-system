class ParkingSpot {
  final int id;
  final String numero;
  final String statut;

  ParkingSpot({
    required this.id,
    required this.numero,
    required this.statut,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: json['id'],
      numero: json['numero'],
      statut: json['statut'],
    );
  }
}
