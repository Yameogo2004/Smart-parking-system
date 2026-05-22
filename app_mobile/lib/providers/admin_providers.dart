import 'package:flutter/material.dart';

import '../core/errors/error_messages.dart';
import '../data/models/admin_notification.dart';
import '../data/models/alerte.dart';
import '../data/models/blacklist_event.dart';
import '../data/models/capteur.dart';
import '../data/models/dashboard_summary.dart';
import '../data/models/elevator.dart';
import '../data/models/ev_charging_payment.dart';
import '../data/models/parking_statut.dart';
import '../data/models/payment.dart';
import '../data/models/stats_overview.dart';
import '../data/models/stationnement.dart';
import '../data/models/vehicle.dart';
import '../data/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepository = AdminRepository();

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  Map<String, dynamic> _dashboardData = {};

  List<Alerte> _alertes = [];
  List<Alerte> _vehicleAlerts = [];
  List<Alerte> _sensorAlerts = [];

  List<Capteur> _capteurs = [];
  List<Vehicle> _vehicules = [];
  List<Stationnement> _stationnements = [];
  List<Payment> _paiements = [];
  List<Payment> _parkingPayments = [];

  List<ParkingStatut> _parkingLevels = [];
  Elevator? _elevator;

  DashboardSummary _dashboardSummary = DashboardSummary.empty();
  StatsOverview _statsOverview = StatsOverview.empty();
  List<AdminNotification> _notifications = [];
  List<BlacklistEvent> _blacklistEvents = [];
  List<EvChargingPayment> _evPayments = [];

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic> get dashboardData => _dashboardData;

  List<Alerte> get alertes => List.unmodifiable(_alertes);
  List<Alerte> get vehicleAlerts => List.unmodifiable(_vehicleAlerts);
  List<Alerte> get sensorAlerts => List.unmodifiable(_sensorAlerts);

  List<Capteur> get capteurs => List.unmodifiable(_capteurs);
  List<Vehicle> get vehicules => List.unmodifiable(_vehicules);
  List<Stationnement> get stationnements => List.unmodifiable(_stationnements);
  List<Payment> get paiements => List.unmodifiable(_paiements);
  List<Payment> get parkingPayments => List.unmodifiable(_parkingPayments);
  List<ParkingStatut> get parkingLevels => List.unmodifiable(_parkingLevels);

  Elevator? get elevator => _elevator;
  DashboardSummary get dashboardSummary => _dashboardSummary;
  StatsOverview get statsOverview => _statsOverview;
  List<AdminNotification> get notifications => List.unmodifiable(_notifications);
  List<BlacklistEvent> get blacklistEvents =>
      List.unmodifiable(_blacklistEvents);
  List<EvChargingPayment> get evPayments => List.unmodifiable(_evPayments);

  int get totalAlertes => _alertes.length;

  int get totalAlertesCritiques =>
      _alertes.where((a) => a.niveau.toLowerCase() == 'critique').length;

  int get totalAlertesVehicules => _vehicleAlerts.length;

  int get totalAlertesCapteurs => _sensorAlerts.length;

  int get totalCapteurs => _capteurs.length;

  int get totalCapteursOffline =>
      _capteurs.where((c) => c.statut.toLowerCase() != 'online').length;

  int get totalVehicules => _vehicules.length;

  int get totalStationnements => _stationnements.length;

  int get totalPaiements => _paiements.length;

  int get totalParkingPayments => _parkingPayments.length;

  int get totalEvPayments => _evPayments.length;

  int get totalBlacklistEvents => _blacklistEvents.length;

  int get totalNotifications => _notifications.length;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  bool get hasDashboardData =>
      _dashboardData.isNotEmpty ||
      _alertes.isNotEmpty ||
      _capteurs.isNotEmpty ||
      _vehicules.isNotEmpty ||
      _stationnements.isNotEmpty ||
      _paiements.isNotEmpty ||
      _parkingLevels.isNotEmpty ||
      _elevator != null;

  Future<void> loadDashboard({bool silent = false}) async {
    if (!silent) {
      _setLoading(true);
    }

    _clearError();

    try {
      final results = await Future.wait([
        _adminRepository.getDashboardData(),
        _adminRepository.getAlertes(),
        _adminRepository.getVehicleAlerts(),
        _adminRepository.getSensorAlerts(),
        _adminRepository.getCapteurs(),
        _adminRepository.getVehicules(),
        _adminRepository.getStationnements(),
        _adminRepository.getPaiements(),
        _adminRepository.getParkingPayments(),
        _adminRepository.getEvPayments(),
        _adminRepository.getParkingStatusByLevel(),
        _adminRepository.getElevatorStatus(),
        _adminRepository.getNotifications(),
        _adminRepository.getBlacklistEvents(),
        _adminRepository.getStatsOverview(),
      ]);

      _dashboardData = results[0] as Map<String, dynamic>;
      _alertes = results[1] as List<Alerte>;
      _vehicleAlerts = results[2] as List<Alerte>;
      _sensorAlerts = results[3] as List<Alerte>;
      _capteurs = results[4] as List<Capteur>;
      _vehicules = results[5] as List<Vehicle>;
      _stationnements = results[6] as List<Stationnement>;
      _paiements = results[7] as List<Payment>;
      _parkingPayments = results[8] as List<Payment>;
      _evPayments = results[9] as List<EvChargingPayment>;
      _parkingLevels = results[10] as List<ParkingStatut>;
      _elevator = results[11] as Elevator?;
      _notifications = results[12] as List<AdminNotification>;
      _blacklistEvents = results[13] as List<BlacklistEvent>;
      _statsOverview = results[14] as StatsOverview;

      _buildDashboardSummary();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
    } finally {
      if (!silent) {
        _setLoading(false);
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> refreshDashboard() async {
    _setRefreshing(true);
    _clearError();

    try {
      await loadDashboard(silent: true);
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      notifyListeners();
    } finally {
      _setRefreshing(false);
    }
  }

  Future<void> loadAlertes() async {
    await _runLoader(() async {
      _alertes = await _adminRepository.getAlertes();
      _vehicleAlerts = await _adminRepository.getVehicleAlerts();
      _sensorAlerts = await _adminRepository.getSensorAlerts();
      _buildDashboardSummary();
    });
  }

  Future<void> loadVehicleAlerts() async {
    await _runLoader(() async {
      _vehicleAlerts = await _adminRepository.getVehicleAlerts();
    });
  }

  Future<void> loadSensorAlerts() async {
    await _runLoader(() async {
      _sensorAlerts = await _adminRepository.getSensorAlerts();
    });
  }

  Future<void> loadCapteurs() async {
    await _runLoader(() async {
      _capteurs = await _adminRepository.getCapteurs();
      _buildDashboardSummary();
    });
  }

  Future<void> loadVehicules() async {
    await _runLoader(() async {
      _vehicules = await _adminRepository.getVehicules();
      _buildDashboardSummary();
    });
  }

  Future<void> loadStationnements() async {
    await _runLoader(() async {
      _stationnements = await _adminRepository.getStationnements();
      _buildDashboardSummary();
    });
  }

  Future<void> loadPaiements() async {
    await _runLoader(() async {
      _paiements = await _adminRepository.getPaiements();
      _buildDashboardSummary();
    });
  }

  Future<void> loadParkingPayments() async {
    await _runLoader(() async {
      _parkingPayments = await _adminRepository.getParkingPayments();
    });
  }

  Future<void> loadEvPayments() async {
    await _runLoader(() async {
      _evPayments = await _adminRepository.getEvPayments();
    });
  }

  Future<void> loadParkingLevels() async {
    await _runLoader(() async {
      _parkingLevels = await _adminRepository.getParkingStatusByLevel();
      _buildDashboardSummary();
    });
  }

  Future<void> loadElevator() async {
    await _runLoader(() async {
      _elevator = await _adminRepository.getElevatorStatus();
      _buildDashboardSummary();
    });
  }

  Future<void> loadDashboardSummary() async {
    await _runLoader(() async {
      if (_dashboardData.isEmpty) {
        _dashboardData = await _adminRepository.getDashboardData();
      }
      _buildDashboardSummary();
    });
  }

  Future<void> loadStatsOverview() async {
    await _runLoader(() async {
      _statsOverview = await _adminRepository.getStatsOverview();
    });
  }

  Future<void> loadBlacklistEvents() async {
    await _runLoader(() async {
      _blacklistEvents = await _adminRepository.getBlacklistEvents();
    });
  }

  Future<void> loadNotifications() async {
    await _runLoader(() async {
      _notifications = await _adminRepository.getNotifications();
    });
  }

  Future<void> loadStatisticsScreenData() async {
    await _runLoader(() async {
      _statsOverview = await _adminRepository.getStatsOverview();
      _paiements = await _adminRepository.getPaiements();
      _parkingPayments = await _adminRepository.getParkingPayments();
      _evPayments = await _adminRepository.getEvPayments();
    });
  }

  Future<void> loadAlertsScreenData() async {
    await _runLoader(() async {
      _alertes = await _adminRepository.getAlertes();
      _vehicleAlerts = await _adminRepository.getVehicleAlerts();
      _sensorAlerts = await _adminRepository.getSensorAlerts();
      _buildDashboardSummary();
    });
  }

  Future<void> loadPaymentsScreenData() async {
    await _runLoader(() async {
      _paiements = await _adminRepository.getPaiements();
      _parkingPayments = await _adminRepository.getParkingPayments();
      _evPayments = await _adminRepository.getEvPayments();
      _buildDashboardSummary();
    });
  }

  Future<bool> resolveAlerte({
    required int alerteId,
    String? commentaire,
  }) async {
    _clearError();
    notifyListeners();

    try {
      await _adminRepository.resolveAlerte(
        alerteId: alerteId,
        commentaire: commentaire,
      );

      await loadAlertes();
      return true;
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      notifyListeners();
      return false;
    }
  }

  void markNotificationAsRead(int notificationId) {
    _notifications = _notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();

    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;

    _dashboardData = {};
    _alertes = [];
    _vehicleAlerts = [];
    _sensorAlerts = [];
    _capteurs = [];
    _vehicules = [];
    _stationnements = [];
    _paiements = [];
    _parkingPayments = [];
    _parkingLevels = [];
    _elevator = null;

    _dashboardSummary = DashboardSummary.empty();
    _statsOverview = StatsOverview.empty();
    _notifications = [];
    _blacklistEvents = [];
    _evPayments = [];

    notifyListeners();
  }

  Future<void> _runLoader(Future<void> Function() loader) async {
    _setLoading(true);
    _clearError();

    try {
      await loader();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
    } finally {
      _setLoading(false);
    }
  }

  void _buildDashboardSummary() {
    final totalPlaces = _extractInt(
      _dashboardData,
      ['total_places', 'places_total', 'total'],
      fallback: _parkingLevels.isNotEmpty ? _parkingLevels.first.total : 0,
    );

    final occupiedPlaces = _extractInt(
      _dashboardData,
      ['occupied_places', 'places_occupees', 'occupes'],
      fallback: _parkingLevels.isNotEmpty ? _parkingLevels.first.occupes : 0,
    );

    final freePlaces = _extractInt(
      _dashboardData,
      ['free_places', 'places_libres', 'libres'],
      fallback: _parkingLevels.isNotEmpty ? _parkingLevels.first.libres : 0,
    );

    final reservedPlaces = _extractInt(
      _dashboardData,
      ['reserved_places', 'places_reservees', 'reserved'],
    );

    final totalVehicules = _extractInt(
      _dashboardData,
      ['total_vehicules', 'vehicules_total', 'vehicules'],
      fallback: _vehicules.length,
    );

    final totalCapteurs = _extractInt(
      _dashboardData,
      ['total_capteurs', 'capteurs_total', 'capteurs'],
      fallback: _capteurs.length,
    );

    final offlineCapteurs = _extractInt(
      _dashboardData,
      ['offline_capteurs', 'capteurs_offline'],
      fallback: totalCapteursOffline,
    );

    final totalAlertes = _extractInt(
      _dashboardData,
      ['total_alertes', 'alertes_total', 'alertes'],
      fallback: _alertes.length,
    );

    final criticalAlertes = _extractInt(
      _dashboardData,
      ['critical_alertes', 'alertes_critiques'],
      fallback: totalAlertesCritiques,
    );

    final activeStationnements = _extractInt(
      _dashboardData,
      ['active_stationnements', 'stationnements_actifs'],
      fallback: _stationnements.where((s) => s.sortie == null).length,
    );

    final totalPaiements = _extractInt(
      _dashboardData,
      ['total_paiements', 'paiements_total', 'paiements'],
      fallback: _paiements.length + _parkingPayments.length + _evPayments.length,
    );

    final elevatorStatus =
        _dashboardData['elevator_status']?.toString() ??
        _elevator?.statut ??
        'N/A';

    final elevatorLevel = _extractInt(
      _dashboardData,
      ['elevator_level', 'niveau_ascenseur'],
      fallback: _elevator?.niveauActuel ?? 0,
    );

    final occupancyRate = totalPlaces > 0
        ? (occupiedPlaces / totalPlaces) * 100
        : 0.0;

    _dashboardSummary = DashboardSummary(
      totalPlaces: totalPlaces,
      occupiedPlaces: occupiedPlaces,
      freePlaces: freePlaces,
      reservedPlaces: reservedPlaces,
      totalVehicules: totalVehicules,
      totalCapteurs: totalCapteurs,
      offlineCapteurs: offlineCapteurs,
      totalAlertes: totalAlertes,
      criticalAlertes: criticalAlertes,
      activeStationnements: activeStationnements,
      totalPaiements: totalPaiements,
      elevatorStatus: elevatorStatus,
      elevatorLevel: elevatorLevel,
      occupancyRate: occupancyRate,
    );
  }

  int _extractInt(
    Map<String, dynamic> data,
    List<String> keys, {
    int fallback = 0,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setRefreshing(bool value) {
    _isRefreshing = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
