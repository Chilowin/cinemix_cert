import 'package:equatable/equatable.dart';

enum FailureCode {
  noConnection,
  timeout,
  serverError,
  notFound,
  sessionExpired,
  authFailed,
  invalidCredentials,
  invalidEmail,
  emailInUse,
  weakPassword,
  tooManyRequests,
  noCache,
  unknown,
}

abstract class Failure extends Equatable implements Exception {
  const Failure(this.message, this.code, [this.statusCode]);

  final String message;
  final FailureCode code;
  final int? statusCode;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Aucune connexion réseau.',
    super.code = FailureCode.noConnection,
  ]);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Le serveur a rencontré une erreur.',
    super.code = FailureCode.serverError,
    super.statusCode,
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Authentification impossible.',
    super.code = FailureCode.authFailed,
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Aucune donnée disponible hors ligne.',
    super.code = FailureCode.noCache,
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Une erreur inattendue est survenue.',
    super.code = FailureCode.unknown,
  ]);
}
