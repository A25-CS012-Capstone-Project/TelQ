part of 'login_cubit.dart';

enum LoginStatus { idle, loading, success, failure }

class LoginState extends Equatable {
  final String email;
  final String password;
  final LoginStatus status;
  final String? error;
  final User? user;

  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.idle,
    this.error,
    this.user,
  });

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    String? error,
    User? user,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      error: error,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [email, password, status, error, user];
}
