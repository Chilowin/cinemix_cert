import 'package:dio/dio.dart';

import 'failure.dart';

Failure mapDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure(
        'Le délai de connexion a été dépassé.',
        FailureCode.timeout,
      );
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final status = exception.response?.statusCode;
      if (status == 401) {
        return const AuthFailure(
          'Session expirée, reconnectez-vous.',
          FailureCode.sessionExpired,
        );
      }
      if (status == 404) {
        return const ServerFailure(
          'Ressource introuvable.',
          FailureCode.notFound,
        );
      }
      return ServerFailure(
        'Erreur serveur (code $status).',
        FailureCode.serverError,
        status,
      );
    default:
      return const UnknownFailure();
  }
}
