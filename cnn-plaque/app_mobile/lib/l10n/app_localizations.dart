import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await _loadLanguageFile();
    _localizedStrings = _parseJson(jsonString);
    return true;
  }

  Future<String> _loadLanguageFile() async {
    switch (locale.languageCode) {
      case 'en':
        return englishTranslations;
      case 'es':
        return spanishTranslations;
      case 'ar':
        return arabicTranslations;
      default:
        return frenchTranslations;
    }
  }

  Map<String, String> _parseJson(String jsonString) {
    Map<String, String> map = {};
    List<String> lines = jsonString.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      List<String> parts = line.split(':');
      if (parts.length >= 2) {
        String key = parts[0].trim().replaceAll('"', '');
        String value = parts.sublist(1).join(':').trim().replaceAll('"', '');
        map[key] = value;
      }
    }
    return map;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // TRADUCTIONS FRANÇAISES
  static const String frenchTranslations = '''
"app_name":"Parking Intelligent"
"login_title":"Parking Intelligent"
"login_subtitle":"Connectez-vous pour accéder à votre espace"
"email":"Email"
"password":"Mot de passe"
"login":"Se connecter"
"register":"S'inscrire"
"forgot_password":"Mot de passe oublié ?"
"no_account":"Pas encore de compte ? "
"test_account":"Compte de test"
"home":"Accueil"
"profile":"Profil"
"reserve":"Réserver"
"my_ticket":"Mon ticket"
"parking_spots":"Places libres"
"ground_floor":"Rez-de-chaussée"
"floor":"Étage"
"available":"places libres"
"full":"Complet"
"vehicle_parked":"VÉHICULE GARÉ"
"location":"EMPLACEMENT"
"level":"NIVEAU"
"box":"BOX"
"vehicle_info":"VÉHICULE"
"plate":"Plaque"
"rfid_ticket":"Ticket RFID"
"entry_time":"Heure d'entrée"
"exit_code":"CODE DE SORTIE"
"scan_code":"Présentez ce code au terminal de sortie"
"duration":"TEMPS STATIONNÉ"
"amount":"MONTANT"
"extend":"PROLONGER"
"locate":"LOCALISER"
"reservation":"Réserver"
"new_reservation":"Nouvelle réservation"
"history":"Historique"
"personal_info":"Informations personnelles"
"last_name":"Nom"
"first_name":"Prénom"
"phone":"Téléphone"
"vehicle_info_title":"Informations véhicule"
"plate_number":"Plaque d'immatriculation"
"model":"Modèle du véhicule"
"extra_charge":"Charge supplémentaire (kg)"
"date_time":"Date et heure"
"start":"Début"
"end":"Fin"
"extra_charge_title":"Charge supplémentaire"
"summary":"RÉCAPITULATIF"
"duration_label":"Durée"
"hourly_rate":"Tarif horaire"
"base_amount":"Montant base"
"extra_fee":"Charge supp."
"total":"TOTAL"
"confirm_reservation":"CONFIRMER LA RÉSERVATION"
"payment":"Paiement"
"amount_to_pay":"MONTANT À PAYER"
"payment_method":"Méthode de paiement"
"card_payment":"Carte bancaire"
"cash_payment":"Espèces"
"app_money":"App Money"
"pay":"PAYER"
"cancel":"Annuler"
"confirm":"Confirmer"
"close":"Fermer"
"loading":"Chargement..."
"error":"Erreur"
"retry":"Réessayer"
"language":"Langue"
"french":"Français"
"english":"English"
"spanish":"Español"
"arabic":"العربية"
"settings":"Paramètres"
"notifications":"Notifications"
"logout":"Se déconnecter"
"reservation_code":"Code réservation"
"distance":"Distance du parking"
''';

  // TRADUCTIONS ANGLAISES
  static const String englishTranslations = '''
"app_name":"Smart Parking"
"login_title":"Smart Parking"
"login_subtitle":"Login to access your space"
"email":"Email"
"password":"Password"
"login":"Login"
"register":"Sign up"
"forgot_password":"Forgot password?"
"no_account":"Don't have an account? "
"test_account":"Test account"
"home":"Home"
"profile":"Profile"
"reserve":"Reserve"
"my_ticket":"My ticket"
"parking_spots":"Available spots"
"ground_floor":"Ground floor"
"floor":"Floor"
"available":"available spots"
"full":"Full"
"vehicle_parked":"VEHICLE PARKED"
"location":"LOCATION"
"level":"LEVEL"
"box":"BOX"
"vehicle_info":"VEHICLE"
"plate":"License plate"
"rfid_ticket":"RFID Ticket"
"entry_time":"Entry time"
"exit_code":"EXIT CODE"
"scan_code":"Present this code at the exit terminal"
"duration":"PARKING DURATION"
"amount":"AMOUNT"
"extend":"EXTEND"
"locate":"LOCATE"
"reservation":"Reserve"
"new_reservation":"New reservation"
"history":"History"
"personal_info":"Personal information"
"last_name":"Last name"
"first_name":"First name"
"phone":"Phone"
"vehicle_info_title":"Vehicle information"
"plate_number":"License plate"
"model":"Vehicle model"
"extra_charge":"Extra charge (kg)"
"date_time":"Date and time"
"start":"Start"
"end":"End"
"extra_charge_title":"Extra charge"
"summary":"SUMMARY"
"duration_label":"Duration"
"hourly_rate":"Hourly rate"
"base_amount":"Base amount"
"extra_fee":"Extra fee"
"total":"TOTAL"
"confirm_reservation":"CONFIRM RESERVATION"
"payment":"Payment"
"amount_to_pay":"AMOUNT TO PAY"
"payment_method":"Payment method"
"card_payment":"Credit card"
"cash_payment":"Cash"
"app_money":"App Money"
"pay":"PAY"
"cancel":"Cancel"
"confirm":"Confirm"
"close":"Close"
"loading":"Loading..."
"error":"Error"
"retry":"Retry"
"language":"Language"
"french":"French"
"english":"English"
"spanish":"Spanish"
"arabic":"Arabic"
"settings":"Settings"
"notifications":"Notifications"
"logout":"Logout"
"reservation_code":"Reservation code"
"distance":"Distance to parking"
''';

  // TRADUCTIONS ESPAGNOLES
  static const String spanishTranslations = '''
"app_name":"Parking Inteligente"
"login_title":"Parking Inteligente"
"login_subtitle":"Inicie sesión para acceder a su espacio"
"email":"Correo electrónico"
"password":"Contraseña"
"login":"Iniciar sesión"
"register":"Registrarse"
"forgot_password":"¿Olvidó su contraseña?"
"no_account":"¿No tiene cuenta? "
"test_account":"Cuenta de prueba"
"home":"Inicio"
"profile":"Perfil"
"reserve":"Reservar"
"my_ticket":"Mi ticket"
"parking_spots":"Plazas disponibles"
"ground_floor":"Planta baja"
"floor":"Piso"
"available":"plazas libres"
"full":"Completo"
"vehicle_parked":"VEHÍCULO ESTACIONADO"
"location":"UBICACIÓN"
"level":"NIVEL"
"box":"CAJA"
"vehicle_info":"VEHÍCULO"
"plate":"Matrícula"
"rfid_ticket":"Ticket RFID"
"entry_time":"Hora de entrada"
"exit_code":"CÓDIGO DE SALIDA"
"scan_code":"Presente este código en el terminal de salida"
"duration":"TIEMPO ESTACIONADO"
"amount":"MONTO"
"extend":"PRORROGAR"
"locate":"LOCALIZAR"
"reservation":"Reservar"
"new_reservation":"Nueva reserva"
"history":"Historial"
"personal_info":"Información personal"
"last_name":"Apellido"
"first_name":"Nombre"
"phone":"Teléfono"
"vehicle_info_title":"Información del vehículo"
"plate_number":"Matrícula"
"model":"Modelo del vehículo"
"extra_charge":"Carga extra (kg)"
"date_time":"Fecha y hora"
"start":"Inicio"
"end":"Fin"
"extra_charge_title":"Carga extra"
"summary":"RESUMEN"
"duration_label":"Duración"
"hourly_rate":"Tarifa por hora"
"base_amount":"Monto base"
"extra_fee":"Carga extra"
"total":"TOTAL"
"confirm_reservation":"CONFIRMAR RESERVA"
"payment":"Pago"
"amount_to_pay":"MONTO A PAGAR"
"payment_method":"Método de pago"
"card_payment":"Tarjeta bancaria"
"cash_payment":"Efectivo"
"app_money":"App Money"
"pay":"PAGAR"
"cancel":"Cancelar"
"confirm":"Confirmar"
"close":"Cerrar"
"loading":"Cargando..."
"error":"Error"
"retry":"Reintentar"
"language":"Idioma"
"french":"Francés"
"english":"Inglés"
"spanish":"Español"
"arabic":"Árabe"
"settings":"Ajustes"
"notifications":"Notificaciones"
"logout":"Cerrar sesión"
"reservation_code":"Código de reserva"
"distance":"Distancia al parking"
''';

  // TRADUCTIONS ARABES
  static const String arabicTranslations = '''
"app_name":"موقف ذكي"
"login_title":"موقف ذكي"
"login_subtitle":"تسجيل الدخول للوصول إلى مساحتك"
"email":"البريد الإلكتروني"
"password":"كلمة المرور"
"login":"تسجيل الدخول"
"register":"إنشاء حساب"
"forgot_password":"نسيت كلمة المرور؟"
"no_account":"ليس لديك حساب؟ "
"test_account":"حساب تجريبي"
"home":"الرئيسية"
"profile":"الملف الشخصي"
"reserve":"حجز"
"my_ticket":"تذكرتي"
"parking_spots":"أماكن متاحة"
"ground_floor":"الطابق الأرضي"
"floor":"الطابق"
"available":"أماكن متاحة"
"full":"ممتلئ"
"vehicle_parked":"المركبة متوقفة"
"location":"الموقع"
"level":"المستوى"
"box":"الصندوق"
"vehicle_info":"المركبة"
"plate":"لوحة الترخيص"
"rfid_ticket":"بطاقة RFID"
"entry_time":"وقت الدخول"
"exit_code":"رمز الخروج"
"scan_code":"قدم هذا الرمز عند مخرج المحطة"
"duration":"مدة الوقوف"
"amount":"المبلغ"
"extend":"تمديد"
"locate":"تحديد الموقع"
"reservation":"حجز"
"new_reservation":"حجز جديد"
"history":"السجل"
"personal_info":"المعلومات الشخصية"
"last_name":"الاسم الأخير"
"first_name":"الاسم الأول"
"phone":"الهاتف"
"vehicle_info_title":"معلومات المركبة"
"plate_number":"لوحة الترخيص"
"model":"طراز المركبة"
"extra_charge":"حمولة إضافية (كغم)"
"date_time":"التاريخ والوقت"
"start":"البداية"
"end":"النهاية"
"extra_charge_title":"حمولة إضافية"
"summary":"الملخص"
"duration_label":"المدة"
"hourly_rate":"السعر بالساعة"
"base_amount":"المبلغ الأساسي"
"extra_fee":"رسوم إضافية"
"total":"المجموع"
"confirm_reservation":"تأكيد الحجز"
"payment":"الدفع"
"amount_to_pay":"المبلغ المطلوب"
"payment_method":"طريقة الدفع"
"card_payment":"بطاقة ائتمان"
"cash_payment":"نقدي"
"app_money":"أموال التطبيق"
"pay":"ادفع"
"cancel":"إلغاء"
"confirm":"تأكيد"
"close":"إغلاق"
"loading":"جاري التحميل..."
"error":"خطأ"
"retry":"إعادة المحاولة"
"language":"اللغة"
"french":"الفرنسية"
"english":"الإنجليزية"
"spanish":"الإسبانية"
"arabic":"العربية"
"settings":"الإعدادات"
"notifications":"الإشعارات"
"logout":"تسجيل الخروج"
"reservation_code":"رمز الحجز"
"distance":"المسافة إلى الموقف"
''';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'es', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
