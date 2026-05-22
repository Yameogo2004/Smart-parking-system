import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  static const Map<String, String> labelsByCode = {
    'fr': 'Francais',
    'en': 'English',
    'ar': 'Arabic',
    'es': 'Espanol',
  };

  Locale _locale = const Locale('fr');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  String get languageLabel => labelsByCode[languageCode] ?? labelsByCode['fr']!;

  void setLocale(Locale locale) {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = Locale(locale.languageCode);
    notifyListeners();
  }

  void setFrench() => setLocale(const Locale('fr'));
  void setEnglish() => setLocale(const Locale('en'));
  void setArabic() => setLocale(const Locale('ar'));
  void setSpanish() => setLocale(const Locale('es'));

  void setByCode(String code) {
    if (!labelsByCode.containsKey(code)) {
      setFrench();
      return;
    }

    setLocale(Locale(code));
  }

  void setByLabel(String label) {
    final normalized = label.trim().toLowerCase();

    for (final entry in labelsByCode.entries) {
      if (entry.value.toLowerCase() == normalized) {
        setByCode(entry.key);
        return;
      }
    }

    setFrench();
  }
}
