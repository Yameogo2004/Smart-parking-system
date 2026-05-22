class Failure {
  final String message;
  final String? code;
  final int? statusCode;

  const Failure({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() {
    return 'Failure(message: $message, code: $code, statusCode: $statusCode)';
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.statusCode,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.statusCode,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.statusCode,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.statusCode,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    super.statusCode,
  });
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    required super.message,
    super.code,
    super.statusCode,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.statusCode,
  });
}
