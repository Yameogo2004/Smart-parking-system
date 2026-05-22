import 'package:flutter/material.dart';

class AppStrings {
  AppStrings._();

  static const String appName = 'Smart Parking Admin';
  static const String appTagline = 'Supervision intelligente du parking';
  static const String loading = 'Chargement...';
  static const String retry = 'Reessayer';
  static const String cancel = 'Annuler';
  static const String confirm = 'Confirmer';
  static const String save = 'Enregistrer';
  static const String update = 'Mettre a jour';
  static const String delete = 'Supprimer';
  static const String search = 'Rechercher';
  static const String seeAll = 'Voir tout';
  static const String noData = 'Aucune donnee disponible';
  static const String unknownError = 'Une erreur inattendue est survenue';
  static const String loginTitle = 'Connexion';
  static const String loginSubtitle = 'Connectez-vous a votre espace administrateur';
  static const String email = 'Email';
  static const String password = 'Mot de passe';
  static const String forgotPassword = 'Mot de passe oublie ?';
  static const String signIn = 'Se connecter';
  static const String signOut = 'Se deconnecter';
  static const String dashboard = 'Tableau de bord';
  static const String overview = 'Vue d ensemble';
  static const String quickActions = 'Actions rapides';
  static const String recentActivity = 'Activite recente';
  static const String alerts = 'Alertes';
  static const String sensors = 'Capteurs';
  static const String vehicles = 'Vehicules';
  static const String parking = 'Parking';
  static const String parkingSpots = 'Places de parking';
  static const String parkingLevels = 'Niveaux';
  static const String reservations = 'Reservations';
  static const String stationnements = 'Stationnements';
  static const String payments = 'Paiements';
  static const String settings = 'Parametres';
  static const String reports = 'Rapports';
  static const String totalPlaces = 'Total places';
  static const String freePlaces = 'Places libres';
  static const String occupiedPlaces = 'Places occupees';
  static const String occupationRate = 'Taux d occupation';
  static const String dailyEntries = 'Entrees du jour';
  static const String dailyRevenue = 'CA du jour';
  static const String available = 'Disponible';
  static const String occupied = 'Occupe';
  static const String reserved = 'Reserve';
  static const String offline = 'Hors ligne';
  static const String online = 'En ligne';
  static const String critical = 'Critique';
  static const String warning = 'Avertissement';
  static const String resolved = 'Resolue';
  static const String pending = 'En attente';
  static const String noAlerts = 'Aucune alerte pour le moment';
  static const String noSensors = 'Aucun capteur trouve';
  static const String noVehicles = 'Aucun vehicule trouve';
  static const String noPayments = 'Aucun paiement trouve';
  static const String noStationnements = 'Aucun stationnement trouve';
  static const String sessionExpired = 'Session expiree, veuillez vous reconnecter';
  static const String networkError = 'Erreur reseau, veuillez reessayer';
  static const String accessDenied = 'Acces refuse';
  static const String operationSuccess = 'Operation reussie';
}

class AppLocalText {
  final Locale locale;

  const AppLocalText(this.locale);

  String get _code => locale.languageCode;

  String text(String key) {
    final languageMap = _translations[_code] ?? _translations['fr']!;
    return languageMap[key] ?? _translations['fr']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'fr': {
      'nav.dashboard': 'Dashboard',
      'nav.parking': 'Parking',
      'nav.spots': 'Places',
      'nav.vehicles': 'Vehicules',
      'nav.alerts': 'Alertes',
      'nav.payments': 'Paiements',
      'nav.statistics': 'Statistiques',
      'nav.settings': 'Parametres',
      'sidebar.subtitle': 'Centre de controle admin',
      'sidebar.fullAccess': 'Acces complet',
      'settings.title': 'Parametres admin',
      'settings.subtitle': 'Profil administrateur, preferences, theme et configuration systeme.',
      'settings.systemPreferences': 'Preferences systeme',
      'settings.notifications': 'Notifications activees',
      'settings.notificationsSubtitle': 'Recevoir les notifications systeme',
      'settings.autoRefresh': 'Actualisation automatique',
      'settings.autoRefreshSubtitle': 'Rafraichir les donnees periodiquement',
      'settings.criticalOnly': 'Alertes critiques uniquement',
      'settings.criticalOnlySubtitle': 'Filtrer les alertes non prioritaires',
      'settings.theme': 'Theme',
      'settings.themeSubtitle': 'Choisir entre le mode sombre et clair',
      'settings.language': 'Langue',
      'settings.languageSubtitle': 'Choisir la langue de l interface',
      'settings.adminManagement': 'Gestion administration',
      'settings.addAdmin': 'Ajouter un administrateur',
      'settings.addAdminSubtitle': 'Creer un autre compte admin',
      'settings.switchAccount': 'Changer de compte',
      'settings.switchAccountSubtitle': 'Basculer entre admin, client ou super admin',
      'settings.security': 'Securite et mot de passe',
      'settings.securitySubtitle': 'Mettre a jour les acces securises',
      'settings.logout': 'Deconnexion',
      'settings.logoutSubtitle': 'Terminer proprement la session administrateur.',
      'settings.logoutButton': 'Se deconnecter',
      'settings.profileFallback': 'Administrateur principal',
      'settings.roleSuperAdmin': 'Super administrateur',
      'settings.roleClient': 'Compte client',
      'settings.systemActive': 'Systeme actif',
      'settings.systemInfo': 'Informations systeme',
      'settings.version': 'Version',
      'settings.environment': 'Environnement',
      'settings.production': 'Production',
      'settings.module': 'Module',
      'settings.chooseTheme': 'Choisir le theme',
      'settings.darkTheme': 'Interface sombre professionnelle',
      'settings.lightTheme': 'Interface claire',
      'settings.chooseLanguage': 'Choisir la langue',
      'settings.displayLanguage': 'Langue d affichage de l interface',
      'settings.languageSelected': 'Langue selectionnee',
      'settings.chooseAccount': 'Changer de compte',
      'settings.chooseAccountHelp': 'Choisis le mode de compte a utiliser dans l interface.',
      'settings.switchToProfile': 'Basculer l interface vers ce profil',
      'settings.activeAccount': 'Compte actif',
      'settings.switchFailed': 'Impossible de changer de compte.',
      'settings.firstName': 'Prenom',
      'settings.lastName': 'Nom',
      'settings.requiredFields': 'Veuillez remplir tous les champs.',
      'settings.adminCreated': 'Administrateur ajoute avec succes.',
      'settings.adminCreateFailed': 'Erreur lors de la creation.',
      'settings.securityTitle': 'Securite et mot de passe',
      'settings.securityBody': 'Ici tu pourras plus tard modifier le mot de passe administrateur, activer une double authentification et gerer les acces sensibles.',
      'common.cancel': 'Annuler',
      'common.close': 'Fermer',
      'common.save': 'Enregistrer',
    },
    'en': {
      'nav.dashboard': 'Dashboard',
      'nav.parking': 'Parking',
      'nav.spots': 'Spots',
      'nav.vehicles': 'Vehicles',
      'nav.alerts': 'Alerts',
      'nav.payments': 'Payments',
      'nav.statistics': 'Statistics',
      'nav.settings': 'Settings',
      'sidebar.subtitle': 'Admin Control Center',
      'sidebar.fullAccess': 'Full access',
      'settings.title': 'Admin Settings',
      'settings.subtitle': 'Admin profile, preferences, theme and system configuration.',
      'settings.systemPreferences': 'System preferences',
      'settings.notifications': 'Notifications enabled',
      'settings.notificationsSubtitle': 'Receive system notifications',
      'settings.autoRefresh': 'Auto refresh',
      'settings.autoRefreshSubtitle': 'Refresh data periodically',
      'settings.criticalOnly': 'Critical alerts only',
      'settings.criticalOnlySubtitle': 'Filter lower priority alerts',
      'settings.theme': 'Theme',
      'settings.themeSubtitle': 'Choose dark or light mode',
      'settings.language': 'Language',
      'settings.languageSubtitle': 'Choose the interface language',
      'settings.adminManagement': 'Administration management',
      'settings.addAdmin': 'Add administrator',
      'settings.addAdminSubtitle': 'Create another admin account',
      'settings.switchAccount': 'Switch account',
      'settings.switchAccountSubtitle': 'Switch between admin, client or super admin',
      'settings.security': 'Security and password',
      'settings.securitySubtitle': 'Update secure access',
      'settings.logout': 'Sign out',
      'settings.logoutSubtitle': 'End the administrator session cleanly.',
      'settings.logoutButton': 'Sign out',
      'settings.profileFallback': 'Main administrator',
      'settings.roleSuperAdmin': 'Super administrator',
      'settings.roleClient': 'Client account',
      'settings.systemActive': 'System active',
      'settings.systemInfo': 'System information',
      'settings.version': 'Version',
      'settings.environment': 'Environment',
      'settings.production': 'Production',
      'settings.module': 'Module',
      'settings.chooseTheme': 'Choose theme',
      'settings.darkTheme': 'Professional dark interface',
      'settings.lightTheme': 'Light interface',
      'settings.chooseLanguage': 'Choose language',
      'settings.displayLanguage': 'Interface display language',
      'settings.languageSelected': 'Selected language',
      'settings.chooseAccount': 'Switch account',
      'settings.chooseAccountHelp': 'Choose the account mode to use in the interface.',
      'settings.switchToProfile': 'Switch the interface to this profile',
      'settings.activeAccount': 'Active account',
      'settings.switchFailed': 'Unable to switch account.',
      'settings.firstName': 'First name',
      'settings.lastName': 'Last name',
      'settings.requiredFields': 'Please fill all fields.',
      'settings.adminCreated': 'Administrator added successfully.',
      'settings.adminCreateFailed': 'Creation failed.',
      'settings.securityTitle': 'Security and password',
      'settings.securityBody': 'Later, you will be able to change the administrator password, enable two-factor authentication and manage sensitive access.',
      'common.cancel': 'Cancel',
      'common.close': 'Close',
      'common.save': 'Save',
    },
    'ar': {
      'nav.dashboard': 'Dashboard',
      'nav.parking': 'Parking',
      'nav.spots': 'Spots',
      'nav.vehicles': 'Vehicles',
      'nav.alerts': 'Alerts',
      'nav.payments': 'Payments',
      'nav.statistics': 'Statistics',
      'nav.settings': 'Settings',
      'sidebar.subtitle': 'Admin Control Center',
      'sidebar.fullAccess': 'Full access',
      'settings.title': 'Admin Settings',
      'settings.subtitle': 'Admin profile, preferences, theme and system configuration.',
      'settings.systemPreferences': 'System preferences',
      'settings.notifications': 'Notifications enabled',
      'settings.notificationsSubtitle': 'Receive system notifications',
      'settings.autoRefresh': 'Auto refresh',
      'settings.autoRefreshSubtitle': 'Refresh data periodically',
      'settings.criticalOnly': 'Critical alerts only',
      'settings.criticalOnlySubtitle': 'Filter lower priority alerts',
      'settings.theme': 'Theme',
      'settings.themeSubtitle': 'Choose dark or light mode',
      'settings.language': 'Language',
      'settings.languageSubtitle': 'Choose the interface language',
      'settings.adminManagement': 'Administration management',
      'settings.addAdmin': 'Add administrator',
      'settings.addAdminSubtitle': 'Create another admin account',
      'settings.switchAccount': 'Switch account',
      'settings.switchAccountSubtitle': 'Switch between admin, client or super admin',
      'settings.security': 'Security and password',
      'settings.securitySubtitle': 'Update secure access',
      'settings.logout': 'Sign out',
      'settings.logoutSubtitle': 'End the administrator session cleanly.',
      'settings.logoutButton': 'Sign out',
      'settings.profileFallback': 'Main administrator',
      'settings.roleSuperAdmin': 'Super administrator',
      'settings.roleClient': 'Client account',
      'settings.systemActive': 'System active',
      'settings.systemInfo': 'System information',
      'settings.version': 'Version',
      'settings.environment': 'Environment',
      'settings.production': 'Production',
      'settings.module': 'Module',
      'settings.chooseTheme': 'Choose theme',
      'settings.darkTheme': 'Professional dark interface',
      'settings.lightTheme': 'Light interface',
      'settings.chooseLanguage': 'Choose language',
      'settings.displayLanguage': 'Interface display language',
      'settings.languageSelected': 'Selected language',
      'settings.chooseAccount': 'Switch account',
      'settings.chooseAccountHelp': 'Choose the account mode to use in the interface.',
      'settings.switchToProfile': 'Switch the interface to this profile',
      'settings.activeAccount': 'Active account',
      'settings.switchFailed': 'Unable to switch account.',
      'settings.firstName': 'First name',
      'settings.lastName': 'Last name',
      'settings.requiredFields': 'Please fill all fields.',
      'settings.adminCreated': 'Administrator added successfully.',
      'settings.adminCreateFailed': 'Creation failed.',
      'settings.securityTitle': 'Security and password',
      'settings.securityBody': 'Later, you will be able to change the administrator password, enable two-factor authentication and manage sensitive access.',
      'common.cancel': 'Cancel',
      'common.close': 'Close',
      'common.save': 'Save',
    },
    'es': {
      'nav.dashboard': 'Panel',
      'nav.parking': 'Parking',
      'nav.spots': 'Plazas',
      'nav.vehicles': 'Vehiculos',
      'nav.alerts': 'Alertas',
      'nav.payments': 'Pagos',
      'nav.statistics': 'Estadisticas',
      'nav.settings': 'Ajustes',
      'sidebar.subtitle': 'Centro de control admin',
      'sidebar.fullAccess': 'Acceso completo',
      'settings.title': 'Ajustes admin',
      'settings.subtitle': 'Perfil administrador, preferencias, tema y configuracion del sistema.',
      'settings.systemPreferences': 'Preferencias del sistema',
      'settings.notifications': 'Notificaciones activadas',
      'settings.notificationsSubtitle': 'Recibir notificaciones del sistema',
      'settings.autoRefresh': 'Actualizacion automatica',
      'settings.autoRefreshSubtitle': 'Actualizar datos periodicamente',
      'settings.criticalOnly': 'Solo alertas criticas',
      'settings.criticalOnlySubtitle': 'Filtrar alertas no prioritarias',
      'settings.theme': 'Tema',
      'settings.themeSubtitle': 'Elegir modo oscuro o claro',
      'settings.language': 'Idioma',
      'settings.languageSubtitle': 'Elegir idioma de la interfaz',
      'settings.adminManagement': 'Gestion administrativa',
      'settings.addAdmin': 'Agregar administrador',
      'settings.addAdminSubtitle': 'Crear otra cuenta admin',
      'settings.switchAccount': 'Cambiar cuenta',
      'settings.switchAccountSubtitle': 'Cambiar entre admin, cliente o super admin',
      'settings.security': 'Seguridad y contrasena',
      'settings.securitySubtitle': 'Actualizar accesos seguros',
      'settings.logout': 'Cerrar sesion',
      'settings.logoutSubtitle': 'Finalizar correctamente la sesion del administrador.',
      'settings.logoutButton': 'Cerrar sesion',
      'settings.profileFallback': 'Administrador principal',
      'settings.roleSuperAdmin': 'Super administrador',
      'settings.roleClient': 'Cuenta cliente',
      'settings.systemActive': 'Sistema activo',
      'settings.systemInfo': 'Informacion del sistema',
      'settings.version': 'Version',
      'settings.environment': 'Entorno',
      'settings.production': 'Produccion',
      'settings.module': 'Modulo',
      'settings.chooseTheme': 'Elegir tema',
      'settings.darkTheme': 'Interfaz oscura profesional',
      'settings.lightTheme': 'Interfaz clara',
      'settings.chooseLanguage': 'Elegir idioma',
      'settings.displayLanguage': 'Idioma de visualizacion de la interfaz',
      'settings.languageSelected': 'Idioma seleccionado',
      'settings.chooseAccount': 'Cambiar cuenta',
      'settings.chooseAccountHelp': 'Elige el modo de cuenta para usar en la interfaz.',
      'settings.switchToProfile': 'Cambiar la interfaz a este perfil',
      'settings.activeAccount': 'Cuenta activa',
      'settings.switchFailed': 'No se pudo cambiar de cuenta.',
      'settings.firstName': 'Nombre',
      'settings.lastName': 'Apellido',
      'settings.requiredFields': 'Completa todos los campos.',
      'settings.adminCreated': 'Administrador agregado correctamente.',
      'settings.adminCreateFailed': 'Error durante la creacion.',
      'settings.securityTitle': 'Seguridad y contrasena',
      'settings.securityBody': 'Mas tarde podras cambiar la contrasena del administrador, activar la doble autenticacion y gestionar accesos sensibles.',
      'common.cancel': 'Cancelar',
      'common.close': 'Cerrar',
      'common.save': 'Guardar',
    },
  };
}

extension AppLocalTextX on BuildContext {
  AppLocalText get t => AppLocalText(Localizations.localeOf(this));
}
