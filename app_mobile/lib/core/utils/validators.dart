class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';

    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Email invalide';

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ requis';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Numéro requis';
    if (value.length < 8) return 'Numéro invalide';
    return null;
  }
}
