import 'app_exception.dart';
import 'failure.dart';

class ErrorMessages {
  ErrorMessages._();

  static const String unknownError =
      'Une erreur inattendue est survenue.';
  static const String networkError =
      'Problème de connexion réseau. Vérifiez votre connexion internet.';
  static const String serverError =
      'Le serveur a rencontré un problème. Veuillez réessayer plus tard.';
  static const String unauthorized =
      'Session expirée ou accès non autorisé.';
  static const String forbidden =
      'Vous n’avez pas les permissions nécessaires.';
  static const String notFound =
      'Ressource introuvable.';
  static const String validationError =
      'Certaines informations sont invalides.';
  static const String timeoutError =
      'Le serveur met trop de temps à répondre.';
  static const String badCredentials =
      'Email ou mot de passe incorrect.';
  static const String emptyData =
      'Aucune donnée disponible.';

  static String fromException(Object error) {
    if (error is NetworkException) {
      return error.message.isNotEmpty ? error.message : networkError;
    }
    if (error is ServerException) {
      return error.message.isNotEmpty ? error.message : serverError;
    }
    if (error is AuthException) {
      return error.message.isNotEmpty ? error.message : unauthorized;
    }
    if (error is ForbiddenException) {
      return error.message.isNotEmpty ? error.message : forbidden;
    }
    if (error is NotFoundException) {
      return error.message.isNotEmpty ? error.message : notFound;
    }
    if (error is ValidationException) {
      return error.message.isNotEmpty ? error.message : validationError;
    }
    if (error is UnknownException) {
      return error.message.isNotEmpty ? error.message : unknownError;
    }
    if (error is AppException) {
      return error.message.isNotEmpty ? error.message : unknownError;
    }

    return unknownError;
  }

  static String fromFailure(Failure failure) {
    if (failure.message.isNotEmpty) {
      return failure.message;
    }

    if (failure is NetworkFailure) return networkError;
    if (failure is ServerFailure) return serverError;
    if (failure is AuthFailure) return unauthorized;
    if (failure is ForbiddenFailure) return forbidden;
    if (failure is NotFoundFailure) return notFound;
    if (failure is ValidationFailure) return validationError;
    if (failure is UnknownFailure) return unknownError;

    return unknownError;
  }

  static String fromStatusCode(int? statusCode, {String? fallbackMessage}) {
    switch (statusCode) {
      case 400:
        return fallbackMessage?.isNotEmpty == true
            ? fallbackMessage!
            : validationError;
      case 401:
        return fallbackMessage?.isNotEmpty == true
            ? fallbackMessage!
            : unauthorized;
      case 403:
        return fallbackMessage?.isNotEmpty == true
            ? fallbackMessage!
            : forbidden;
      case 404:
        return fallbackMessage?.isNotEmpty == true
            ? fallbackMessage!
            : notFound;
      case 408:
        return fallbackMessage?.isNotEmpty == true
            ? fallbackMessage!
            : timeoutError;
      case 500:
      case 502:
      case 503:
      case 504:
        return fallbackMessage?.isNotEmpty == true
            ? fallbackMessage!
            : serverError;
      default:
        return fallbackMessage?.isNotEmpty == true
            ? fallbackMessage!
            : unknownError;
    }
  }
}
