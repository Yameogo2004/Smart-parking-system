import 'package:flutter/material.dart';

import '../../presentation/screens/admin/alerts/admin_alerts_screen.dart';
import '../../presentation/screens/admin/alerts/admin_sensor_alerts_screen.dart';
import '../../presentation/screens/admin/alerts/admin_vehicle_alerts_screen.dart';
import '../../presentation/screens/admin/capteurs/admin_capteurs_screen.dart';
import '../../presentation/screens/admin/dashboard/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/paiements/admin_ev_payments_screen.dart';
import '../../presentation/screens/admin/paiements/admin_paiements_screen.dart';
import '../../presentation/screens/admin/paiements/admin_parking_payments_screen.dart';
import '../../presentation/screens/admin/parking/admin_parking_grid_screen.dart';
import '../../presentation/screens/admin/parking/admin_parking_overview_screen.dart';
import '../../presentation/screens/admin/parking/admin_parking_spots_screen.dart';
import '../../presentation/screens/admin/settings/admin_settings_screen.dart';
import '../../presentation/screens/admin/stationnements/admin_stationnements_screen.dart';
import '../../presentation/screens/admin/statistiques/admin_statistics_screen.dart';
import '../../presentation/screens/admin/vehicules/admin_blacklist_screen.dart';
import '../../presentation/screens/admin/vehicules/admin_vehicules_screen.dart';

import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';

import '../../presentation/screens/client/home/home_screen.dart';
import '../../presentation/screens/client/parking/active_parking_screen.dart';
import '../../presentation/screens/client/parking/locate_vehicle_screen.dart';
import '../../presentation/screens/client/payment/payment_screen.dart';
import '../../presentation/screens/client/profile/profile_screen.dart';
import '../../presentation/screens/client/reservation/reservation_form_screen.dart';
import '../../presentation/screens/client/reservation/reservation_history_screen.dart';
import '../../presentation/screens/client/settings/language_screen.dart';
import '../../presentation/screens/client/settings/settings_screen.dart';

import '../../presentation/screens/common/access_denied_screen.dart';
import '../../presentation/screens/common/help_screen.dart';
import '../../presentation/screens/common/no_internet_screen.dart';
import '../../presentation/screens/common/not_found_screen.dart';
import '../../presentation/screens/common/notifications_screen.dart';
import '../../presentation/screens/common/profile_screen.dart';
import '../../presentation/screens/common/settings_screen.dart';

import '../../presentation/screens/splash/splash_screen.dart';

import 'route_guard.dart';
import 'route_names.dart';
import '../../presentation/screens/admin/iot/admin_iot_dashboard_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('➡️ Route appelée: ${settings.name}');

    switch (settings.name) {
      /// AUTH
      case RouteNames.splash:
        return _buildRoute(const SplashScreen(), settings);

      case RouteNames.login:
        return _buildRoute(const LoginScreen(), settings);

      case RouteNames.register:
        return _buildRoute(const RegisterScreen(), settings);

      case RouteNames.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      /// ROOT
      case RouteNames.home:
        return RouteGuard.protectByRole(
          settings: settings,
          adminPage: const AdminDashboardScreen(),
          clientPage: const HomeScreen(),
        );

      /// ADMIN
      case RouteNames.adminDashboard:
        return RouteGuard.protectAdmin(
          settings,
          const AdminDashboardScreen(),
        );

      case RouteNames.adminParking:
        return RouteGuard.protectAdmin(
          settings,
          const AdminParkingOverviewScreen(),
        );

      case RouteNames.adminParkingSpots:
        return RouteGuard.protectAdmin(
          settings,
          const AdminParkingSpotsScreen(),
        );

      case RouteNames.adminParkingGrid:
        return RouteGuard.protectAdmin(
          settings,
          const AdminParkingGridScreen(),
        );

      case RouteNames.adminVehicles:
        return RouteGuard.protectAdmin(
          settings,
          const AdminVehiculesScreen(),
        );

      case RouteNames.adminBlacklist:
        return RouteGuard.protectAdmin(
          settings,
          const AdminBlacklistScreen(),
        );

      case RouteNames.adminAlerts:
        return RouteGuard.protectAdmin(
          settings,
          const AdminAlertsScreen(),
        );

      case RouteNames.adminVehicleAlerts:
        return RouteGuard.protectAdmin(
          settings,
          const AdminVehicleAlertsScreen(),
        );

      case RouteNames.adminSensorAlerts:
        return RouteGuard.protectAdmin(
          settings,
          const AdminSensorAlertsScreen(),
        );

      case RouteNames.adminPayments:
        return RouteGuard.protectAdmin(
          settings,
          const AdminPaiementsScreen(),
        );

      case RouteNames.adminParkingPayments:
        return RouteGuard.protectAdmin(
          settings,
          const AdminParkingPaymentsScreen(),
        );

      case RouteNames.adminEvPayments:
        return RouteGuard.protectAdmin(
          settings,
          const AdminEvPaymentsScreen(),
        );

      case RouteNames.adminCapteurs:
        return RouteGuard.protectAdmin(
          settings,
          const AdminCapteursScreen(),
        );
      case RouteNames.adminIotDashboard:
        return RouteGuard.protectAdmin(settings, const AdminIotDashboardScreen());

      case RouteNames.adminSettings:
        return RouteGuard.protectAdmin(
          settings,
          const AdminSettingsScreen(),
        );

      case RouteNames.adminStationnements:
        return RouteGuard.protectAdmin(
          settings,
          const AdminStationnementsScreen(),
        );

      case RouteNames.adminStatistics:
        return RouteGuard.protectAdmin(
          settings,
          const AdminStatisticsScreen(),
        );

      /// CLIENT
      case RouteNames.clientDashboard:
        return RouteGuard.protectClient(
          settings,
          const HomeScreen(),
        );

      case RouteNames.clientReservation:
        return RouteGuard.protectClient(
          settings,
          const ReservationFormScreen(),
        );

      case RouteNames.clientReservationHistory:
        return RouteGuard.protectClient(
          settings,
          const ReservationHistoryScreen(),
        );

      case RouteNames.clientActiveParking:
        final args = settings.arguments as Map<String, dynamic>?;
        return RouteGuard.protectClient(
          settings,
          ActiveParkingScreen(stationnement: args),
        );

      case RouteNames.clientLocateVehicle:
        return RouteGuard.protectClient(
          settings,
          const LocateVehicleScreen(),
        );

      case RouteNames.clientProfile:
        return RouteGuard.protectClient(
          settings,
          const ClientProfileScreen(),
        );

      case RouteNames.clientSettings:
        return RouteGuard.protectClient(
          settings,
          const ClientSettingsScreen(),
        );

      case RouteNames.clientLanguage:
        return RouteGuard.protectClient(
          settings,
          const LanguageScreen(),
        );

      case RouteNames.clientPayment:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args == null) {
          debugPrint('❌ Arguments manquants pour RouteNames.clientPayment');
          return _buildRoute(const NotFoundScreen(), settings);
        }

        return RouteGuard.protectClient(
          settings,
          PaymentScreen(
            montant: _toDouble(args['montant']),
            reservationId: _toInt(args['reservationId']),
            reservationCode: (args['reservationCode'] ?? '').toString(),
          ),
        );

      /// COMMON
      case RouteNames.profile:
        return RouteGuard.protect(
          settings,
          const ProfileScreen(),
        );

      case RouteNames.settings:
        return RouteGuard.protect(
          settings,
          const SettingsScreen(),
        );

      case RouteNames.notifications:
        return RouteGuard.protect(
          settings,
          const NotificationsScreen(),
        );

      case RouteNames.help:
        return RouteGuard.protect(
          settings,
          const HelpScreen(),
        );

      /// SYSTEM
      case RouteNames.noInternet:
        return _buildRoute(const NoInternetScreen(), settings);

      case RouteNames.accessDenied:
        return _buildRoute(const AccessDeniedScreen(), settings);

      case RouteNames.notFound:
        return _buildRoute(const NotFoundScreen(), settings);

      default:
        debugPrint('❌ Route inconnue: ${settings.name}');
        return _buildRoute(const NotFoundScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
