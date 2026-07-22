import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_durations.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState.unknown());

  /// Checks if a session exists and fetches the user profile.
  /// The splash stays visible at least [AppDurations.splashMinDisplay]:
  /// the resulting state is only emitted after that delay elapses.
  Future<void> checkSession() async {
    final minDisplay = Future<void>.delayed(AppDurations.splashMinDisplay);

    AuthState next;
    if (!await _repository.hasSession()) {
      next = const AuthState.unauthenticated();
    } else {
      try {
        final user = await _repository.getProfile();
        await _resolveActiveCompany(user);
        next = AuthState.authenticated(user);
      } catch (_) {
        await _repository.logout();
        next = const AuthState.unauthenticated();
      }
    }

    await minDisplay;
    emit(next);
  }

  /// Sets the authenticated user and resolves the active company.
  Future<void> setAuthenticated(UserProfile user) async {
    await _resolveActiveCompany(user);
    emit(AuthState.authenticated(user));
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }

  /// Handles session expiration.
  void sessionExpired() {
    if (state.status == AuthStatus.authenticated) {
      emit(const AuthState.unauthenticated());
    }
  }

  /// Set the active company.
  Future<void> _resolveActiveCompany(UserProfile user) async {
    if (user.companyCodes.isEmpty) return;
    final current = await _repository.getActiveCompany();
    if (current != null && user.companyCodes.contains(current)) return;
    await _repository.setActiveCompany(user.companyCodes.first);
  }
}
