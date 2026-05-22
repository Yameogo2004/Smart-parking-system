import 'user.dart';

class Admin extends User {
  final String niveauAcces;

  Admin({
    required super.id,
    required super.nom,
    required super.email,
    required super.role,
    required this.niveauAcces,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      role: json['role'],
      niveauAcces: json['niveauAcces'] ?? '',
    );
  }
}
