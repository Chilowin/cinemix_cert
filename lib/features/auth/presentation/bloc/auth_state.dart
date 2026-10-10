part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.failure,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool isSubmitting;
  final Failure? failure;

  @override
  List<Object?> get props => [status, user, isSubmitting, failure];
}
