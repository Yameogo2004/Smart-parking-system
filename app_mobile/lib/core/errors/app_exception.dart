class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const AppException(
    this.message, {
    this.code,
    this.statusCode,
  });

  @override
  String toString() {
    return 'AppException(message: $message, code: $code, statusCode: $statusCode)';
  }
}

class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.statusCode,
  });
}

class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.code,
    super.statusCode,
  });
}

class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.statusCode,
  });
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    super.statusCode,
  });
}

class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.code,
    super.statusCode,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException(
    super.message, {
    super.code,
    super.statusCode,
  });
}

class UnknownException extends AppException {
  const UnknownException(
    super.message, {
    super.code,
    super.statusCode,
  });
}
