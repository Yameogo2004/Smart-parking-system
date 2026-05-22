import '../../core/constants/api_constants.dart';
import '../models/admin_notification.dart';
import '../models/alerte.dart';
import '../models/blacklist_event.dart';
import '../models/capteur.dart';
import '../models/elevator.dart';
import '../models/ev_charging_payment.dart';
import '../models/parking_statut.dart';
import '../models/payment.dart';
import '../models/stats_overview.dart';
import '../models/stationnement.dart';
import '../models/vehicle.dart';
import 'api_service.dart';

class AdminService {
  AdminService._();

  static Future<Map<String, dynamic>> getDashboardData() async {
    final response = await ApiService.get(ApiConstants.adminDashboard);

    if (response is Map<String, dynamic>) {
      return Map<String, dynamic>.from(response);
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    return <String, dynamic>{};
  }

  static Future<List<Alerte>> getAlertes() async {
    final response = await ApiService.get(ApiConstants.adminAlerts);

    if (response is List) {
      return response
          .map((item) => Alerte.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['alertes'] is List) {
      return (response['alertes'] as List)
          .map((item) => Alerte.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<List<Alerte>> getVehicleAlerts() async {
    final response = await ApiService.get(ApiConstants.adminVehicleAlerts);

    if (response is List) {
      return response
          .map((item) => Alerte.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['alertes'] is List) {
      return (response['alertes'] as List)
          .map((item) => Alerte.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<List<Alerte>> getSensorAlerts() async {
    final response = await ApiService.get(ApiConstants.adminSensorAlerts);

    if (response is List) {
      return response
          .map((item) => Alerte.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['alertes'] is List) {
      return (response['alertes'] as List)
          .map((item) => Alerte.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<List<Capteur>> getCapteurs() async {
    final response = await ApiService.get(ApiConstants.adminSensors);

    if (response is List) {
      return response
          .map((item) => Capteur.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['capteurs'] is List) {
      return (response['capteurs'] as List)
          .map((item) => Capteur.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<List<Vehicle>> getVehicules() async {
    final response = await ApiService.get(ApiConstants.adminVehicles);

    if (response is List) {
      return response
          .map((item) => Vehicle.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['vehicules'] is List) {
      return (response['vehicules'] as List)
          .map((item) => Vehicle.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<List<Stationnement>> getStationnements() async {
    final response = await ApiService.get(ApiConstants.adminStationnements);

    if (response is List) {
      return response
          .map((item) => Stationnement.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['stationnements'] is List) {
      return (response['stationnements'] as List)
          .map((item) => Stationnement.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<List<Payment>> getPaiements() async {
    final response = await ApiService.get(ApiConstants.adminPayments);

    if (response is List) {
      return response
          .map((item) => Payment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['paiements'] is List) {
      return (response['paiements'] as List)
          .map((item) => Payment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<List<Payment>> getParkingPayments() async {
    final response = await ApiService.get(ApiConstants.adminParkingPayments);

    if (response is List) {
      return response
          .map((item) => Payment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['paiements'] is List) {
      return (response['paiements'] as List)
          .map((item) => Payment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<List<EvChargingPayment>> getEvPayments() async {
    final response = await ApiService.get(ApiConstants.adminEvPayments);

    if (response is List) {
      return response
          .map(
            (item) =>
                EvChargingPayment.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (response is Map && response['paiements'] is List) {
      return (response['paiements'] as List)
          .map(
            (item) =>
                EvChargingPayment.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    return [];
  }

  static Future<List<ParkingStatut>> getParkingStatusByLevel() async {
    final response = await ApiService.get(ApiConstants.adminParkingLevels);

    if (response is List) {
      return response
          .map((item) => ParkingStatut.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['niveaux'] is List) {
      return (response['niveaux'] as List)
          .map((item) => ParkingStatut.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<Elevator?> getElevatorStatus() async {
    final response = await ApiService.get(ApiConstants.adminElevator);

    if (response is Map && response['ascenseur'] is Map) {
      return Elevator.fromJson(
        Map<String, dynamic>.from(response['ascenseur']),
      );
    }

    if (response is Map<String, dynamic>) {
      return Elevator.fromJson(response);
    }

    if (response is Map) {
      return Elevator.fromJson(Map<String, dynamic>.from(response));
    }

    return null;
  }

  static Future<List<AdminNotification>> getNotifications() async {
    final response = await ApiService.get(ApiConstants.adminNotifications);

    if (response is List) {
      return response
          .map(
            (item) =>
                AdminNotification.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (response is Map && response['notifications'] is List) {
      return (response['notifications'] as List)
          .map(
            (item) =>
                AdminNotification.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    return [];
  }

  static Future<List<BlacklistEvent>> getBlacklistEvents() async {
    final response = await ApiService.get(ApiConstants.adminBlacklist);

    if (response is List) {
      return response
          .map((item) => BlacklistEvent.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map && response['events'] is List) {
      return (response['events'] as List)
          .map((item) => BlacklistEvent.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  static Future<StatsOverview> getStatsOverview() async {
    final response = await ApiService.get(ApiConstants.adminStatsOverview);

    if (response is Map<String, dynamic>) {
      return StatsOverview.fromJson(response);
    }

    if (response is Map) {
      return StatsOverview.fromJson(Map<String, dynamic>.from(response));
    }

    return StatsOverview.empty();
  }

  static Future<void> resolveAlerte({
    required int alerteId,
    String? commentaire,
  }) async {
    await ApiService.put(
      '${ApiConstants.adminAlerts}/$alerteId/resoudre',
      {
        'commentaire': commentaire ?? '',
      },
    );
  }
}
