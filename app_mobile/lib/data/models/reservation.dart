class Reservation {
  final int id;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String statut;
  final double poidsEstime;
  final double montantEstime;
  final String? typePlace;
  final int? emplacementId;
  final String codeConfirmation;

  Reservation({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.poidsEstime,
    required this.montantEstime,
    this.typePlace,
    this.emplacementId,
    required this.codeConfirmation,
  });

  Duration get duree => dateFin.difference(dateDebut);

  int get heures => duree.inHours;

  bool get estActive =>
      dateDebut.isBefore(DateTime.now()) && dateFin.isAfter(DateTime.now());

  bool get estEnAttentePaiement =>
      statut.trim().toLowerCase() == 'en_attente_paiement';

  bool get estConfirmee =>
      statut.trim().toLowerCase() == 'confirmée' ||
      statut.trim().toLowerCase() == 'confirmee';

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: _parseInt(json['id']),
      dateDebut: _parseDateTime(json['date_debut']),
      dateFin: _parseDateTime(json['date_fin']),
      statut: (json['statut'] ?? '').toString(),
      poidsEstime: _parseDouble(json['poids_estime']),
      montantEstime: _parseDouble(json['montant_estime']),
      typePlace: json['type_place']?.toString(),
      emplacementId: json['emplacement_id'] != null
          ? _parseInt(json['emplacement_id'])
          : null,
      codeConfirmation: (json['code_confirmation'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'statut': statut,
      'poids_estime': poidsEstime,
      'montant_estime': montantEstime,
      'type_place': typePlace,
      'emplacement_id': emplacementId,
      'code_confirmation': codeConfirmation,
    };
  }

  Reservation copyWith({
    int? id,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? statut,
    double? poidsEstime,
    double? montantEstime,
    String? typePlace,
    int? emplacementId,
    String? codeConfirmation,
  }) {
    return Reservation(
      id: id ?? this.id,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statut: statut ?? this.statut,
      poidsEstime: poidsEstime ?? this.poidsEstime,
      montantEstime: montantEstime ?? this.montantEstime,
      typePlace: typePlace ?? this.typePlace,
      emplacementId: emplacementId ?? this.emplacementId,
      codeConfirmation: codeConfirmation ?? this.codeConfirmation,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
