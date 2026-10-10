import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState()) {
    on<AuthSessionChanged>(_onSessionChanged);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);

    _subscription = _repository.authStateChanges.listen(
      (user) => add(AuthSessionChanged(user)),
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  void _onSessionChanged(AuthSessionChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) {
    return _submit(emit, () => _repository.login(event.email, event.password));
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) {
    return _submit(
      emit,
      () => _repository.register(event.email, event.password),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    return _submit(emit, _repository.logout);
  }

  Future<void> _submit(
    Emitter<AuthState> emit,
    Future<void> Function() action,
  ) async {
    emit(AuthState(status: state.status, user: state.user, isSubmitting: true));
    try {
      await action();
    } on Failure catch (failure) {
      emit(
        AuthState(
          status: state.status,
          user: state.user,
          errorMessage: failure.message,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
