import 'package:cinemix_cert/core/error/failure.dart';
import 'package:cinemix_cert/core/error/failure_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException buildException(DioExceptionType type, {int? statusCode}) {
  final options = RequestOptions(path: '/items');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(requestOptions: options, statusCode: statusCode),
  );
}

void main() {
  group('mapDioException', () {
    test('convertit les délais dépassés en erreur réseau', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          mapDioException(buildException(type)),
          const NetworkFailure('Le délai de connexion a été dépassé.'),
        );
      }
    });

    test('convertit une erreur de connexion en erreur réseau', () {
      expect(
        mapDioException(buildException(DioExceptionType.connectionError)),
        const NetworkFailure(),
      );
    });

    test('convertit un 401 en erreur d\'authentification', () {
      expect(
        mapDioException(
          buildException(DioExceptionType.badResponse, statusCode: 401),
        ),
        const AuthFailure('Session expirée, reconnectez-vous.'),
      );
    });

    test('convertit un 404 en ressource introuvable', () {
      expect(
        mapDioException(
          buildException(DioExceptionType.badResponse, statusCode: 404),
        ),
        const ServerFailure('Ressource introuvable.'),
      );
    });

    test('convertit un 500 en erreur serveur avec le code', () {
      expect(
        mapDioException(
          buildException(DioExceptionType.badResponse, statusCode: 500),
        ),
        const ServerFailure('Erreur serveur (code 500).'),
      );
    });

    test('convertit les autres cas en erreur inconnue', () {
      expect(
        mapDioException(buildException(DioExceptionType.cancel)),
        const UnknownFailure(),
      );
    });
  });
}
