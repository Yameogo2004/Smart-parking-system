class Alerte {
  final int id;
  final String type;
  final String message;
  final String niveau;
  final String? source;
  final String? parkingLevel;
  final String? spotCode;
  final String? vehiculeMatricule;
  final String? capteurNom;
  final String? timestamp;

  Alerte({
    required this.id,
    required this.type,
    required this.message,
    required this.niveau,
    this.source,
    this.parkingLevel,
    this.spotCode,
    this.vehiculeMatricule,
    this.capteurNom,
    this.timestamp,
  });

  factory Alerte.fromJson(Map<String, dynamic> json) {
    return Alerte(
      id: json['id'],
      type: json['type'],
      message: json['message'],
      niveau: json['niveau'],
      source: json['source']?.toString(),
      parkingLevel: json['parking_level']?.toString(),
      spotCode: json['spot_code']?.toString(),
      vehiculeMatricule: json['vehicule_matricule']?.toString(),
      capteurNom: json['capteur_nom']?.toString(),
      timestamp: json['timestamp']?.toString(),
    );
  }
}
