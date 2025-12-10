import 'dart:convert';
import 'dart:io';

import 'package:telq_mobile/core/error/exception.dart';
import 'package:telq_mobile/core/network/api_client.dart';

import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<UserDto> login({required String email, required String password});
  Future<UserDto> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String customerId,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient api;
  AuthRemoteDataSourceImpl({required this.api});

  @override
  Future<UserDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await api.post(
        '/api/v1/auth/login',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && body['success'] == true && body['user'] != null) {
        return UserDto.fromJson(body['user'] as Map<String, dynamic>);
      }

      final message = body['error']?.toString() ?? 'Login failed';
      if (resp.statusCode == 401) throw UnauthorizedException(message);
      if (resp.statusCode == 404) throw NotFoundException(message);
      throw ServerException(message, statusCode: resp.statusCode);
    } on SocketException {
      throw ConnectionException();
    } on FormatException {
      throw ServerException('Invalid response format');
    }
  }

  @override
  Future<UserDto> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String customerId,
  }) async {
    try {
      final resp = await api.post(
        '/api/v1/auth/register',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'password': password,
          'customer_id': customerId,
        }),
      );

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final success = body['success'] == true;
      
      // Backend returns 201 with success:true but no user object
      // So we create UserDto from input data
      if ((resp.statusCode == 200 || resp.statusCode == 201) && success) {
        // If user object is returned, use it. Otherwise create from input.
        if (body['user'] != null) {
          return UserDto.fromJson(body['user'] as Map<String, dynamic>);
        } else {
          return UserDto(
            customerId: customerId,
            firstname: firstname,
            email: email,
          );
        }
      }

      final message = body['error']?.toString() ?? 'Registration failed';
      if (resp.statusCode == 401) throw UnauthorizedException(message);
      if (resp.statusCode == 404) throw NotFoundException(message);
      if (resp.statusCode == 409) throw AlreadyExistsException(message);
      throw ServerException(message, statusCode: resp.statusCode);
    } on SocketException {
      throw ConnectionException();
    } on FormatException {
      throw ServerException('Invalid response format');
    }
  }
}
