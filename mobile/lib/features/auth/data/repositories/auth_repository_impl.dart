import 'package:telq_mobile/core/error/exception.dart';
import 'package:telq_mobile/core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final dto = await remote.login(email: email, password: password);
      return dto.toEntity();
    } on ConnectionException catch (e) {
      throw ConnectionFailure(e.message);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on AlreadyExistsException catch (e) {
      throw AlreadyExistsFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure('Unexpected error: $e');
    }
  }

  @override
  Future<User> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String customerId,
  }) async {
    try {
      final dto = await remote.register(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
        customerId: customerId,
      );
      return dto.toEntity();
    } on ConnectionException catch (e) {
      throw ConnectionFailure(e.message);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on AlreadyExistsException catch (e) {
      throw AlreadyExistsFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure('Unexpected error: $e');
    }
  }
}
