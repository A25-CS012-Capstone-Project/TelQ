import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telq_mobile/core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/register_user.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUser registerUser;
  RegisterCubit(this.registerUser) : super(const RegisterState());

  void firstnameChanged(String value) => emit(state.copyWith(firstname: value));
  void lastnameChanged(String value) => emit(state.copyWith(lastname: value));
  void emailChanged(String value) => emit(state.copyWith(email: value));
  void passwordChanged(String value) => emit(state.copyWith(password: value));
  void customerIdChanged(String value) => emit(state.copyWith(customerId: value));

  Future<void> submit() async {
    if (state.firstname.isEmpty ||
        state.email.isEmpty ||
        state.password.isEmpty ||
        state.customerId.isEmpty) {
      emit(state.copyWith(status: RegisterStatus.failure, error: 'All required fields must be filled'));
      return;
    }
    emit(state.copyWith(status: RegisterStatus.loading, error: null));
    try {
      final user = await registerUser(
        firstname: state.firstname,
        lastname: state.lastname,
        email: state.email,
        password: state.password,
        customerId: state.customerId,
      );
      emit(state.copyWith(status: RegisterStatus.success, user: user));
    } catch (e) {
      String message;
      if (e is AlreadyExistsFailure) {
        message = 'User already exists';
      } else if (e is Failure) {
        message = e.message;
      } else {
        message = e.toString();
      }
      emit(state.copyWith(status: RegisterStatus.failure, error: message));
    }
  }
}
