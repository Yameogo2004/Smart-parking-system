import 'package:app_mobile/core/constants/api_constants.dart';
import 'package:app_mobile/data/services/auth_service.dart';

class AuthInterceptor {
  const AuthInterceptor();

  Future<Map<String, String>> buildHeaders({
    bool requiresAuth = true,
    Map<String, String>? extraHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await AuthService.storage.read(
        key: ApiConstants.tokenKey,
      );

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (extraHeaders != null && extraHeaders.isNotEmpty) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }
}
