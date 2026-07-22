import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

/// Status of the authentication.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// State of the auth cubit.
class AuthState extends Equatable {
  final AuthStatus status;
  final UserProfile? user;

  const AuthState._({required this.status, this.user});

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated(UserProfile user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}
