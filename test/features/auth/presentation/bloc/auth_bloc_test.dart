import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cinemix_cert/core/error/failure.dart';
import 'package:cinemix_cert/features/auth/domain/entities/app_user.dart';
import 'package:cinemix_cert/features/auth/domain/repositories/auth_repository.dart';
import 'package:cinemix_cert/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const user = AppUser(uid: 'uid-1', email: 'alice@example.com');
  const email = 'alice@example.com';
  const password = 'secret1';

  late MockAuthRepository repository;
  late StreamController<AppUser?> sessions;

  setUp(() {
    repository = MockAuthRepository();
    sessions = StreamController<AppUser?>.broadcast();
    when(() => repository.authStateChanges).thenAnswer((_) => sessions.stream);
  });

  tearDown(() => sessions.close());

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'passe à non authentifié quand la session est absente',
      build: () => AuthBloc(repository),
      act: (_) => sessions.add(null),
      wait: const Duration(milliseconds: 50),
      expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    );

    blocTest<AuthBloc, AuthState>(
      'passe à authentifié quand une session utilisateur est reçue',
      build: () => AuthBloc(repository),
      act: (_) => sessions.add(user),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated, user: user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'appelle le repository lors d\'une demande de connexion',
      build: () {
        when(() => repository.login(email, password))
            .thenAnswer((_) async => user);
        return AuthBloc(repository);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: email, password: password)),
      expect: () => [const AuthState(isSubmitting: true)],
      verify: (_) {
        verify(() => repository.login(email, password)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'expose le message d\'erreur quand la connexion échoue',
      build: () {
        when(() => repository.login(email, password)).thenAnswer(
          (_) async =>
              throw const AuthFailure('Email ou mot de passe incorrect.'),
        );
        return AuthBloc(repository);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: email, password: password)),
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(errorMessage: 'Email ou mot de passe incorrect.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'expose le message d\'erreur quand l\'inscription échoue',
      build: () {
        when(() => repository.register(email, password)).thenAnswer(
          (_) async =>
              throw const AuthFailure('Cette adresse email est déjà utilisée.'),
        );
        return AuthBloc(repository);
      },
      act: (bloc) =>
          bloc.add(const RegisterRequested(email: email, password: password)),
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(errorMessage: 'Cette adresse email est déjà utilisée.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'appelle le repository lors d\'une déconnexion',
      build: () {
        when(() => repository.logout()).thenAnswer((_) async {});
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [const AuthState(isSubmitting: true)],
      verify: (_) {
        verify(() => repository.logout()).called(1);
      },
    );
  });
}
