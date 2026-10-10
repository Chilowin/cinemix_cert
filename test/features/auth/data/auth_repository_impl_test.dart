import 'package:cinemix_cert/core/error/failure.dart';
import 'package:cinemix_cert/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cinemix_cert/features/auth/domain/entities/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  const email = 'alice@example.com';
  const password = 'secret1';
  const appUser = AppUser(uid: 'uid-1', email: email);

  late MockFirebaseAuth auth;
  late MockUserCredential credential;
  late MockUser firebaseUser;
  late AuthRepositoryImpl repository;

  setUp(() {
    auth = MockFirebaseAuth();
    credential = MockUserCredential();
    firebaseUser = MockUser();
    when(() => firebaseUser.uid).thenReturn('uid-1');
    when(() => firebaseUser.email).thenReturn(email);
    when(() => credential.user).thenReturn(firebaseUser);
    repository = AuthRepositoryImpl(auth);
  });

  group('login', () {
    test('retourne l\'utilisateur en cas de succès', () async {
      when(
        () => auth.signInWithEmailAndPassword(email: email, password: password),
      ).thenAnswer((_) async => credential);

      expect(await repository.login(email, password), appUser);
    });

    test('échoue si Firebase ne renvoie aucun utilisateur', () async {
      when(() => credential.user).thenReturn(null);
      when(
        () => auth.signInWithEmailAndPassword(email: email, password: password),
      ).thenAnswer((_) async => credential);

      await expectLater(
        repository.login(email, password),
        throwsA(const AuthFailure()),
      );
    });

    const expectations = <String, Failure>{
      'wrong-password': AuthFailure('Email ou mot de passe incorrect.'),
      'user-not-found': AuthFailure('Email ou mot de passe incorrect.'),
      'invalid-credential': AuthFailure('Email ou mot de passe incorrect.'),
      'invalid-email': AuthFailure('Adresse email invalide.'),
      'too-many-requests':
          AuthFailure('Trop de tentatives, réessayez plus tard.'),
      'network-request-failed': NetworkFailure(),
      'code-inconnu': AuthFailure(),
    };

    expectations.forEach((code, expected) {
      test('traduit le code Firebase $code', () async {
        when(
          () => auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => throw FirebaseAuthException(code: code));

        await expectLater(
          repository.login(email, password),
          throwsA(expected),
        );
      });
    });
  });

  group('register', () {
    test('retourne l\'utilisateur créé', () async {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => credential);

      expect(await repository.register(email, password), appUser);
    });

    test('signale une adresse déjà utilisée', () async {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer(
        (_) async => throw FirebaseAuthException(code: 'email-already-in-use'),
      );

      await expectLater(
        repository.register(email, password),
        throwsA(const AuthFailure('Cette adresse email est déjà utilisée.')),
      );
    });

    test('signale un mot de passe trop faible', () async {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer(
        (_) async => throw FirebaseAuthException(code: 'weak-password'),
      );

      await expectLater(
        repository.register(email, password),
        throwsA(
          const AuthFailure(
            'Le mot de passe doit contenir au moins 6 caractères.',
          ),
        ),
      );
    });
  });

  group('session', () {
    test('logout appelle la déconnexion Firebase', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => auth.signOut()).called(1);
    });

    test('authStateChanges convertit l\'utilisateur Firebase', () {
      when(() => auth.authStateChanges())
          .thenAnswer((_) => Stream.value(firebaseUser));

      expect(repository.authStateChanges, emits(appUser));
    });

    test('authStateChanges émet null sans session', () {
      when(() => auth.authStateChanges())
          .thenAnswer((_) => Stream<User?>.value(null));

      expect(repository.authStateChanges, emits(isNull));
    });

    test('currentUser reflète la session en cours', () {
      when(() => auth.currentUser).thenReturn(firebaseUser);
      expect(repository.currentUser, appUser);

      when(() => auth.currentUser).thenReturn(null);
      expect(repository.currentUser, isNull);
    });
  });
}
