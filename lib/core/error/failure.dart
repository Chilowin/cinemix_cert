import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable implements Exception {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Aucune connexion réseau.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Le serveur a rencontré une erreur.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentification impossible.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Aucune donnée disponible hors ligne.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inattendue est survenue.']);
}
