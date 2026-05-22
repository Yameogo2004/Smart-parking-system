class Capteur {
  final int id;
  final String type;
  final String statut;

  Capteur({
    required this.id,
    required this.type,
    required this.statut,
  });

  factory Capteur.fromJson(Map<String, dynamic> json) {
    return Capteur(
      id: json['id'],
      type: json['type'],
      statut: json['statut'],
    );
  }
}
