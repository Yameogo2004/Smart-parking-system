class Payment {
  final int id;
  final double montant;
  final String statut;

  Payment({
    required this.id,
    required this.montant,
    required this.statut,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      montant: json['montant'].toDouble(),
      statut: json['statut'],
    );
  }
}
