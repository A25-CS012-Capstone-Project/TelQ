part of 'register_cubit.dart';

enum RegisterStatus { idle, loading, success, failure }

class RegisterState extends Equatable {
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String customerId;
  final RegisterStatus status;
  final String? error;
  final User? user;

  const RegisterState({
    this.firstname = '',
    this.lastname = '',
    this.email = '',
    this.password = '',
    this.customerId = '',
    this.status = RegisterStatus.idle,
    this.error,
    this.user,
  });

  RegisterState copyWith({
    String? firstname,
    String? lastname,
    String? email,
    String? password,
    String? customerId,
    RegisterStatus? status,
    String? error,
    User? user,
  }) {
    return RegisterState(
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      password: password ?? this.password,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      error: error,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [firstname, lastname, email, password, customerId, status, error, user];
}
