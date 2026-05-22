class ReservationHistory {
  final int id;
  final String codeConfirmation;
  final DateTime dateReservation;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String plaque;
  final String modele;
  final double charge;
  final double montant;
  final String statut;
  final String emplacement;

  ReservationHistory({
    required this.id,
    required this.codeConfirmation,
    required this.dateReservation,
    required this.dateDebut,
    required this.dateFin,
    required this.plaque,
    required this.modele,
    required this.charge,
    required this.montant,
    required this.statut,
    required this.emplacement,
  });

  bool get estConfirmee =>
      statut.trim().toLowerCase() == 'confirmée' ||
      statut.trim().toLowerCase() == 'confirmee';

  bool get estAnnulee =>
      statut.trim().toLowerCase() == 'annulée' ||
      statut.trim().toLowerCase() == 'annulee';

  bool get estTerminee =>
      statut.trim().toLowerCase() == 'terminée' ||
      statut.trim().toLowerCase() == 'terminee';

  Duration get duree => dateFin.difference(dateDebut);

  factory ReservationHistory.fromJson(Map<String, dynamic> json) {
    return ReservationHistory(
      id: _parseInt(json['id']),
      codeConfirmation: (json['code_confirmation'] ?? '').toString(),
      dateReservation: _parseDateTime(json['date_reservation']),
      dateDebut: _parseDateTime(json['date_debut']),
      dateFin: _parseDateTime(json['date_fin']),
      plaque: (json['plaque'] ?? '').toString(),
      modele: (json['modele'] ?? '').toString(),
      charge: _parseDouble(json['charge']),
      montant: _parseDouble(json['montant']),
      statut: (json['statut'] ?? '').toString(),
      emplacement: (json['emplacement'] ?? 'Non assigné').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code_confirmation': codeConfirmation,
      'date_reservation': dateReservation.toIso8601String(),
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'plaque': plaque,
      'modele': modele,
      'charge': charge,
      'montant': montant,
      'statut': statut,
      'emplacement': emplacement,
    };
  }

  ReservationHistory copyWith({
    int? id,
    String? codeConfirmation,
    DateTime? dateReservation,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? plaque,
    String? modele,
    double? charge,
    double? montant,
    String? statut,
    String? emplacement,
  }) {
    return ReservationHistory(
      id: id ?? this.id,
      codeConfirmation: codeConfirmation ?? this.codeConfirmation,
      dateReservation: dateReservation ?? this.dateReservation,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      plaque: plaque ?? this.plaque,
      modele: modele ?? this.modele,
      charge: charge ?? this.charge,
      montant: montant ?? this.montant,
      statut: statut ?? this.statut,
      emplacement: emplacement ?? this.emplacement,
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
