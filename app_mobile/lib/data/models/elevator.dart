class Elevator {
  final int id;
  final String statut;
  final int niveauActuel;

  Elevator({
    required this.id,
    required this.statut,
    required this.niveauActuel,
  });

  factory Elevator.fromJson(Map<String, dynamic> json) {
    return Elevator(
      id: _toInt(json['id']),
      statut: (json['statut'] ?? '').toString(),
      niveauActuel: _toInt(json['niveauActuel']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
