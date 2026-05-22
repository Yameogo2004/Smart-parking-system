import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  Future<User?> getCurrentUser() async {
    try {
      return await AuthService.getCurrentUser();
    } on AppException catch (e) {
      throw AuthFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      return result;
    } on AppException catch (e) {
      throw AuthFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    try {
      final result = await AuthService.register(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        password: password,
      );

      return result;
    } on AppException catch (e) {
      throw ValidationFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> createAdmin({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    try {
      final result = await AuthService.createAdmin(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
      );

      return result;
    } on AppException catch (e) {
      throw ValidationFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await AuthService.isLoggedIn();
    } catch (_) {
      return false;
    }
  }

  Future<String?> getStoredRole() async {
    try {
      return await AuthService.getStoredRole();
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
    } on AppException catch (e) {
      throw AuthFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
