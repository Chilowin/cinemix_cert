import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<AppUser> login(String email, String password);

  Future<AppUser> register(String email, String password);

  Future<void> logout();
}
