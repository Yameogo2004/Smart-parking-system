import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
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
import '../services/admin_service.dart';

class AdminRepository {
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      return await AdminService.getDashboardData();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Alerte>> getAlertes() async {
    try {
      return await AdminService.getAlertes();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Alerte>> getVehicleAlerts() async {
    try {
      return await AdminService.getVehicleAlerts();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Alerte>> getSensorAlerts() async {
    try {
      return await AdminService.getSensorAlerts();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Capteur>> getCapteurs() async {
    try {
      return await AdminService.getCapteurs();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Vehicle>> getVehicules() async {
    try {
      return await AdminService.getVehicules();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Stationnement>> getStationnements() async {
    try {
      return await AdminService.getStationnements();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Payment>> getPaiements() async {
    try {
      return await AdminService.getPaiements();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Payment>> getParkingPayments() async {
    try {
      return await AdminService.getParkingPayments();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<EvChargingPayment>> getEvPayments() async {
    try {
      return await AdminService.getEvPayments();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<ParkingStatut>> getParkingStatusByLevel() async {
    try {
      return await AdminService.getParkingStatusByLevel();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<Elevator?> getElevatorStatus() async {
    try {
      return await AdminService.getElevatorStatus();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<AdminNotification>> getNotifications() async {
    try {
      return await AdminService.getNotifications();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<BlacklistEvent>> getBlacklistEvents() async {
    try {
      return await AdminService.getBlacklistEvents();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<StatsOverview> getStatsOverview() async {
    try {
      return await AdminService.getStatsOverview();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<void> resolveAlerte({
    required int alerteId,
    String? commentaire,
  }) async {
    try {
      await AdminService.resolveAlerte(
        alerteId: alerteId,
        commentaire: commentaire,
      );
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
