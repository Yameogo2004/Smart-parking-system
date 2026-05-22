class Vehicle {
  final int id;
  final String matricule;
  final String type;
  final int suspect;          // 0=Normal, 1=Suspect
  final String? placeActuelle; // place actuelle depuis stationnements (null si pas garé)
  final bool estGare;         // true si stationnement actif

  Vehicle({
    required this.id,
    required this.matricule,
    required this.type,
    this.suspect = 0,
    this.placeActuelle,
    this.estGare = false,
  });

  /// Statut calculé depuis la DB
  String get statut {
    if (suspect == 1) return 'Suspect';
    return 'Normal';
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: _toInt(json['id']),
      matricule: (json['matricule'] ?? '').toString(),
      type: (json['type'] ?? 'standard').toString(),
      suspect: _toInt(json['suspect']),
      placeActuelle: json['place_actuelle']?.toString(),
      estGare: json['est_gare'] == true || json['est_gare'] == 1,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'matricule': matricule,
        'type': type,
        'suspect': suspect,
        'place_actuelle': placeActuelle,
        'est_gare': estGare,
      };
}
