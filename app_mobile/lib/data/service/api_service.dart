import 'package:http/http.dart' as http;

import '../../core/network/api_client.dart';
import '../../core/network/auth_interceptor.dart';
import '../../core/network/network_info.dart';

class ApiService {
  ApiService._();

  static final ApiClient _client = ApiClient(
    client: http.Client(),
    networkInfo: const NetworkInfoImpl(),
    authInterceptor: const AuthInterceptor(),
  );

  static Future<dynamic> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? headers,
  }) {
    return _client.get(
      endpoint,
      requiresAuth: requiresAuth,
      headers: headers,
    );
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
    Map<String, String>? headers,
  }) {
    return _client.post(
      endpoint,
      body: data,
      requiresAuth: requiresAuth,
      headers: headers,
    );
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
    Map<String, String>? headers,
  }) {
    return _client.put(
      endpoint,
      body: data,
      requiresAuth: requiresAuth,
      headers: headers,
    );
  }

  static Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = true,
    Map<String, String>? headers,
  }) {
    return _client.delete(
      endpoint,
      body: data,
      requiresAuth: requiresAuth,
      headers: headers,
    );
  }
}
