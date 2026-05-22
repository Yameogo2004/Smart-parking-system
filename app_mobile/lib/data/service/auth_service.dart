import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();

  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiConstants.login,
      {
        'email': email.trim(),
        'password': password,
      },
      requiresAuth: false,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Réponse login invalide');
    }

    final success = response['success'] == true;
    if (!success) {
      throw Exception(
        response['error']?.toString() ?? 'Échec de connexion',
      );
    }

    final token = response['token']?.toString();
    final userId = response['user_id'];
    final userJson = response['user'];

    if (token != null && token.isNotEmpty) {
      await storage.write(
        key: ApiConstants.tokenKey,
        value: token,
      );
    }

    if (userId != null) {
      await storage.write(
        key: ApiConstants.userIdKey,
        value: userId.toString(),
      );
    }

    User? user;
    if (userJson is Map<String, dynamic>) {
      user = User.fromJson(userJson);

      final role = userJson['role']?.toString();
      if (role != null && role.isNotEmpty) {
        await storage.write(
          key: ApiConstants.userRoleKey,
          value: role,
        );
      }
    }

    return {
      'token': token,
      'user': user,
    };
  }

  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiConstants.register,
      {
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'email': email.trim(),
        'telephone': telephone.trim(),
        'password': password,
      },
      requiresAuth: false,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    return <String, dynamic>{
      'success': true,
      'message': 'Inscription réussie',
    };
  }

  static Future<Map<String, dynamic>> createAdmin({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/api/admin/users',
      {
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'email': email.trim(),
        'password': password,
        'role': 'admin',
      },
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    return <String, dynamic>{
      'success': true,
      'message': 'Administrateur créé avec succès',
    };
  }

  static Future<User?> getCurrentUser() async {
    final response = await ApiService.get(
      ApiConstants.me,
      requiresAuth: true,
    );

    if (response is! Map<String, dynamic>) {
      return null;
    }

    if (response['user'] is Map<String, dynamic>) {
      return User.fromJson(
        Map<String, dynamic>.from(response['user']),
      );
    }

    if (response['id'] != null) {
      return User.fromJson(response);
    }

    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await storage.read(key: ApiConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getStoredRole() async {
    return storage.read(key: ApiConstants.userRoleKey);
  }

  static Future<String?> getStoredToken() async {
    return storage.read(key: ApiConstants.tokenKey);
  }

  static Future<void> logout() async {
    try {
      await ApiService.post(
        ApiConstants.logout,
        {},
        requiresAuth: true,
      );
    } catch (_) {
      // backend mock
    }

    await storage.delete(key: ApiConstants.tokenKey);
    await storage.delete(key: ApiConstants.userIdKey);
    await storage.delete(key: ApiConstants.userRoleKey);
  }

  static Future<void> clearStorage() async {
    await storage.delete(key: ApiConstants.tokenKey);
    await storage.delete(key: ApiConstants.userIdKey);
    await storage.delete(key: ApiConstants.userRoleKey);
  }
}
