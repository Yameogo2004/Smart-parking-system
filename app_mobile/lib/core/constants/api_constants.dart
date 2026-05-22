class ApiConstants {
  ApiConstants._();

  static const String appName = 'Smart Parking Admin';

  // Raspberry Pi on local Wi-Fi
  static const String baseUrl = 'http://192.168.76.138:5000';
  static const String apiPrefix = '/api';

  // Auth
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String me = '$apiPrefix/auth/me';
  static const String logout = '$apiPrefix/auth/logout';

  // Admin Dashboard
  static const String adminDashboard = '$apiPrefix/admin/dashboard';
  static const String adminAlerts = '$apiPrefix/admin/alertes';
  static const String adminVehicleAlerts = '$apiPrefix/admin/alertes/vehicules';
  static const String adminSensorAlerts = '$apiPrefix/admin/alertes/capteurs';
  static const String adminSensors = '$apiPrefix/admin/capteurs';
  static const String adminVehicles = '$apiPrefix/admin/vehicules';
  static const String adminParkings = '$apiPrefix/admin/parking';
  static const String adminParkingLevels = '$apiPrefix/admin/parking/niveaux';
  static const String adminParkingSpots = '$apiPrefix/admin/parking/places';
  static const String adminStationnements = '$apiPrefix/admin/stationnements';
  static const String adminPayments = '$apiPrefix/admin/paiements';
  static const String adminParkingPayments =
      '$apiPrefix/admin/paiements/parking';
  static const String adminEvPayments = '$apiPrefix/admin/paiements/ev';
  static const String adminElevator = '$apiPrefix/admin/ascenseur';
  static const String adminNotifications = '$apiPrefix/admin/notifications';
  static const String adminNotificationsReadAll =
      '$apiPrefix/admin/notifications/read-all';
  static const String adminBlacklist = '$apiPrefix/admin/blacklist';
  static const String adminStatsOverview = '$apiPrefix/admin/stats/overview';

  // General parking
  static const String parkingStatus = '$apiPrefix/parking/statut';
  static const String parkingStatusByLevel =
      '$apiPrefix/parking/statut-par-niveau';

  // Client / reservation / vehicle
  static const String reservations = '$apiPrefix/reservation';
  static const String activeParking = '$apiPrefix/stationnement/actif';
  static const String vehicles = '$apiPrefix/vehicules';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
