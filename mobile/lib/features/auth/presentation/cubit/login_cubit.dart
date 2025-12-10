import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telq_mobile/core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUser loginUser;
  LoginCubit(this.loginUser) : super(const LoginState());

  void emailChanged(String value) => emit(state.copyWith(email: value));
  void passwordChanged(String value) => emit(state.copyWith(password: value));

  Future<void> submit() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(status: LoginStatus.failure, error: 'Email and password required'));
      return;
    }
    emit(state.copyWith(status: LoginStatus.loading, error: null));
    try {
      final user = await loginUser(email: state.email, password: state.password);
      emit(state.copyWith(status: LoginStatus.success, user: user));
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(status: LoginStatus.failure, error: message));
    }
  }
}
