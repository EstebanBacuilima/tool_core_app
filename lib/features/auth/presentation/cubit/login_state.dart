import 'package:equatable/equatable.dart';

/// States of the login screen: initial / loading / success / failure(code).
sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginFailure extends LoginState {
  final String code;

  const LoginFailure(this.code);

  @override
  List<Object?> get props => [code];
}
