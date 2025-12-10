import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_dto.dart';

class ProfileRemoteDataSource {
  final String baseUrl;

  ProfileRemoteDataSource({required this.baseUrl});

  Future<UserProfileDto> getProfile(String customerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/users/profile?customer_id=$customerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserProfileDto.fromJson(json);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to load profile');
    }
  }
}
