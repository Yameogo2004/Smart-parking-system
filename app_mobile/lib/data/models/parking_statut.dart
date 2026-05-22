class ParkingStatut {
  final int total;
  final int libres;
  final int occupes;

  ParkingStatut({
    required this.total,
    required this.libres,
    required this.occupes,
  });

  factory ParkingStatut.fromJson(Map<String, dynamic> json) {
    return ParkingStatut(
      total: json['total'],
      libres: json['libres'],
      occupes: json['occupes'],
    );
  }
}
