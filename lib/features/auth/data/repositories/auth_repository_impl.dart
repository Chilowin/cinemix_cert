import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth);

  final FirebaseAuth _auth;

  AppUser? _toUser(User? user) {
    if (user == null) return null;
    return AppUser(uid: user.uid, email: user.email);
  }

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toUser);

  @override
  AppUser? get currentUser => _toUser(_auth.currentUser);

  @override
  Future<AppUser> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AppUser> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  AppUser _requireUser(User? user) {
    final mapped = _toUser(user);
    if (mapped == null) throw const AuthFailure();
    return mapped;
  }

  Failure _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const AuthFailure(
          'Adresse email invalide.',
          FailureCode.invalidEmail,
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(
          'Email ou mot de passe incorrect.',
          FailureCode.invalidCredentials,
        );
      case 'email-already-in-use':
        return const AuthFailure(
          'Cette adresse email est déjà utilisée.',
          FailureCode.emailInUse,
        );
      case 'weak-password':
        return const AuthFailure(
          'Le mot de passe doit contenir au moins 6 caractères.',
          FailureCode.weakPassword,
        );
      case 'too-many-requests':
        return const AuthFailure(
          'Trop de tentatives, réessayez plus tard.',
          FailureCode.tooManyRequests,
        );
      case 'network-request-failed':
        return const NetworkFailure();
      default:
        return const AuthFailure();
    }
  }
}
