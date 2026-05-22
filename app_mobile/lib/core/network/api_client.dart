import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/app_exception.dart';
import '../errors/error_messages.dart';
import 'auth_interceptor.dart';
import 'network_info.dart';

class ApiClient {
  final http.Client client;
  final NetworkInfo networkInfo;
  final AuthInterceptor authInterceptor;

  ApiClient({
    required this.client,
    required this.networkInfo,
    required this.authInterceptor,
  });

  Future<dynamic> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? headers,
  }) async {
    return _sendRequest(
      method: _HttpMethod.get,
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      headers: headers,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    Map<String, String>? headers,
  }) async {
    return _sendRequest(
      method: _HttpMethod.post,
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
      headers: headers,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    Map<String, String>? headers,
  }) async {
    return _sendRequest(
      method: _HttpMethod.put,
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
      headers: headers,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    Map<String, String>? headers,
  }) async {
    return _sendRequest(
      method: _HttpMethod.delete,
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
      headers: headers,
    );
  }

  Future<dynamic> _sendRequest({
    required _HttpMethod method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    Map<String, String>? headers,
  }) async {
    if (!kIsWeb) {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        throw const NetworkException(ErrorMessages.networkError);
      }
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final mergedHeaders = await authInterceptor.buildHeaders(
      requiresAuth: requiresAuth,
      extraHeaders: headers,
    );

    try {
      debugPrint('================ API REQUEST ================');
      debugPrint('METHOD: ${method.name.toUpperCase()}');
      debugPrint('URL: $uri');
      debugPrint('HEADERS: $mergedHeaders');
      debugPrint('BODY: ${body != null ? jsonEncode(body) : 'null'}');
      debugPrint('REQUIRES AUTH: $requiresAuth');

      late final http.Response response;

      switch (method) {
        case _HttpMethod.get:
          response = await client
              .get(uri, headers: mergedHeaders)
              .timeout(ApiConstants.receiveTimeout);
          break;

        case _HttpMethod.post:
          response = await client
              .post(
                uri,
                headers: mergedHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(ApiConstants.receiveTimeout);
          break;

        case _HttpMethod.put:
          response = await client
              .put(
                uri,
                headers: mergedHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(ApiConstants.receiveTimeout);
          break;

        case _HttpMethod.delete:
          response = await client
              .delete(
                uri,
                headers: mergedHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(ApiConstants.receiveTimeout);
          break;
      }

      debugPrint('================ API RESPONSE ================');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkException(
        ErrorMessages.timeoutError,
        code: 'timeout',
        statusCode: 408,
      );
    } on http.ClientException catch (e) {
      debugPrint('HTTP CLIENT EXCEPTION: ${e.message}');
      throw NetworkException(
        e.message,
        code: 'client_exception',
      );
    } on FormatException catch (e) {
      debugPrint('FORMAT EXCEPTION: $e');
      throw const ServerException(
        'Réponse serveur invalide.',
        code: 'invalid_json',
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('UNKNOWN ERROR: $e');
      debugPrint(stackTrace.toString());
      throw UnknownException(
        e.toString(),
        code: 'unknown_error',
      );
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    dynamic decodedBody;
    if (body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(body);
      } catch (_) {
        decodedBody = body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    }

    final fallbackMessage = _extractMessage(decodedBody);

    switch (statusCode) {
      case 400:
        throw ValidationException(
          ErrorMessages.fromStatusCode(
            statusCode,
            fallbackMessage: fallbackMessage,
          ),
          code: 'bad_request',
          statusCode: statusCode,
        );
      case 401:
        throw AuthException(
          ErrorMessages.fromStatusCode(
            statusCode,
            fallbackMessage: fallbackMessage,
          ),
          code: 'unauthorized',
          statusCode: statusCode,
        );
      case 403:
        throw ForbiddenException(
          ErrorMessages.fromStatusCode(
            statusCode,
            fallbackMessage: fallbackMessage,
          ),
          code: 'forbidden',
          statusCode: statusCode,
        );
      case 404:
        throw NotFoundException(
          ErrorMessages.fromStatusCode(
            statusCode,
            fallbackMessage: fallbackMessage,
          ),
          code: 'not_found',
          statusCode: statusCode,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException(
          ErrorMessages.fromStatusCode(
            statusCode,
            fallbackMessage: fallbackMessage,
          ),
          code: 'server_error',
          statusCode: statusCode,
        );
      default:
        throw UnknownException(
          ErrorMessages.fromStatusCode(
            statusCode,
            fallbackMessage: fallbackMessage,
          ),
          code: 'unknown_http_error',
          statusCode: statusCode,
        );
    }
  }

  String? _extractMessage(dynamic decodedBody) {
    if (decodedBody == null) return null;

    if (decodedBody is Map<String, dynamic>) {
      if (decodedBody['message'] is String &&
          (decodedBody['message'] as String).trim().isNotEmpty) {
        return decodedBody['message'] as String;
      }
      if (decodedBody['error'] is String &&
          (decodedBody['error'] as String).trim().isNotEmpty) {
        return decodedBody['error'] as String;
      }
    }

    if (decodedBody is String && decodedBody.trim().isNotEmpty) {
      return decodedBody;
    }

    return null;
  }
}

enum _HttpMethod {
  get,
  post,
  put,
  delete,
}
