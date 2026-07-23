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

  /// Resolves the active company AND workshop (tenant context).
  /// Keeps the stored ones if still valid, otherwise falls back to the
  /// first membership. A picker screen can replace this later.
  Future<void> _resolveActiveCompany(UserProfile user) async {
    if (user.companies.isEmpty) return;

    final currentCompany = await _repository.getActiveCompany();
    final company = user.companies.firstWhere(
      (c) => c.code == currentCompany,
      orElse: () => user.companies.first,
    );
    await _repository.setActiveCompany(company.code);

    // Services/inventory are per workshop: resolve one within the company.
    if (company.workshops.isEmpty) return;
    final currentWorkshop = await _repository.getActiveWorkshop();
    final workshop = company.workshops.firstWhere(
      (w) => w.code == currentWorkshop,
      orElse: () => company.workshops.first,
    );
    await _repository.setActiveWorkshop(workshop.code);
  }
}
