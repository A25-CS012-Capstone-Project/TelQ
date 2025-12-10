import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<User> call({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String customerId,
  }) {
    return repository.register(
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
      customerId: customerId,
    );
  }
}
