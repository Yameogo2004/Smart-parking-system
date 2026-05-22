import 'package:flutter/material.dart';

import '../core/errors/error_messages.dart';
import '../core/routing/route_names.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  String? _role;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  String? get role => _role;

  String get normalizedRole => (_role ?? '').trim().toLowerCase();

  bool get isAdmin =>
      normalizedRole == 'admin' || normalizedRole == 'super_admin';

  bool get isSuperAdmin => normalizedRole == 'super_admin';

  bool get isClient =>
      normalizedRole == 'client' || normalizedRole == 'proprietaire';

  String get defaultHomeRoute {
    if (isAdmin) return RouteNames.adminDashboard;
    if (isClient) return RouteNames.clientDashboard;
    return RouteNames.home;
  }

  Future<void> initializeAuth() async {
    _setLoading(true);
    _clearError();

    try {
      final loggedIn = await _authRepository.isLoggedIn();

      if (!loggedIn) {
        _resetAuthState();
        return;
      }

      _role = await _authRepository.getStoredRole();
      _user = await _authRepository.getCurrentUser();

      if (_user != null) {
        _role = _user!.role;
        _isLoggedIn = true;
      } else {
        _resetAuthState();
      }
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      _resetAuthState();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      final loggedUser = result['user'] as User?;
      _user = loggedUser;
      _role = loggedUser?.role;
      _isLoggedIn = loggedUser != null;

      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      _resetAuthState();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.register(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        password: password,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAdmin({
    required String nom,
    required String prenom,
    required String email,
    String password = 'admin123',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.createAdmin(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> switchAccount(String mode) async {
    _setLoading(true);
    _clearError();

    try {
      final normalized = mode.trim().toLowerCase();

      String email;
      String password;

      if (normalized == 'client') {
        email = 'test@test.com';
        password = 'password';
      } else {
        email = 'admin@parking.com';
        password = 'admin123';
      }

      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      final loggedUser = result['user'] as User?;
      _user = loggedUser;
      _role = loggedUser?.role;
      _isLoggedIn = loggedUser != null;

      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.logout();
      _resetAuthState();
      notifyListeners();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshCurrentUser() async {
    _setLoading(true);
    _clearError();

    try {
      final currentUser = await _authRepository.getCurrentUser();

      _user = currentUser;
      _role = currentUser?.role;
      _isLoggedIn = currentUser != null;

      notifyListeners();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      _resetAuthState();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _resetAuthState() {
    _user = null;
    _role = null;
    _isLoggedIn = false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
