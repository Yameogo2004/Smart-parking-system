class RouteNames {
  RouteNames._();

  /// AUTH
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  /// ROOT / SMART HOME
  static const String home = '/home';

  /// ADMIN
  static const String adminDashboard = '/admin/dashboard';

  /// ADMIN - PARKING
  static const String adminParking = '/admin/parking';
  static const String adminParkingSpots = '/admin/parking/spots';
  static const String adminParkingGrid = '/admin/parking/grid';

  /// ADMIN - VEHICLES
  static const String adminVehicles = '/admin/vehicles';
  static const String adminBlacklist = '/admin/vehicles/blacklist';

  /// ADMIN - ALERTS
  static const String adminAlerts = '/admin/alerts';
  static const String adminVehicleAlerts = '/admin/alerts/vehicles';
  static const String adminSensorAlerts = '/admin/alerts/sensors';

  /// ADMIN - PAYMENTS
  static const String adminPayments = '/admin/payments';
  static const String adminParkingPayments = '/admin/payments/parking';
  static const String adminEvPayments = '/admin/payments/ev';

  /// ADMIN - OTHER
  static const String adminCapteurs = '/admin/capteurs';
  static const String adminSettings = '/admin/settings';
  static const String adminStationnements = '/admin/stationnements';
  static const String adminStatistics = '/admin/statistics';

  /// CLIENT
  static const String clientDashboard = '/client/dashboard';
  static const String clientReservation = '/client/reservation';
  static const String clientReservationHistory =
      '/client/reservation/history';
  static const String clientActiveParking = '/client/parking/active';
  static const String clientLocateVehicle = '/client/parking/locate';
  static const String clientPayment = '/client/payment';
  static const String clientProfile = '/client/profile';
  static const String clientSettings = '/client/settings';
  static const String clientLanguage = '/client/settings/language';

  /// COMMON
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String help = '/help';

  /// SYSTEM
  static const String noInternet = '/no-internet';
  static const String accessDenied = '/access-denied';
  static const String notFound = '/not-found';
  /// ADMIN - IoT
  static const String adminIotDashboard = '/admin/iot';

  /// LEGACY COMPAT
  static const String dashboard = adminDashboard;

  
}
