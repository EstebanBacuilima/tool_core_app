import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_cubit.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _repository;
  final AuthCubit _authCubit;

  LoginCubit(this._repository, this._authCubit) : super(const LoginInitial());

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (state is LoginLoading) return;
    emit(const LoginLoading());
    try {
      await _repository.login(username: username, password: password);
      final user = await _repository.getProfile();
      await _authCubit.setAuthenticated(user);
      emit(const LoginSuccess());
    } on ApiException catch (e) {
      emit(LoginFailure(e.code));
    } catch (_) {
      emit(const LoginFailure(ClientErrorCodes.unexpected));
    }
  }
}
