import '../../domain/entities/user.dart';

class UserDto {
  final String customerId;
  final String firstname;
  final String email;

  UserDto({required this.customerId, required this.firstname, required this.email});

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        customerId: json['customer_id'] ?? '',
        firstname: json['firstname'] ?? '',
        email: json['email'] ?? '',
      );

  User toEntity() => User(customerId: customerId, firstname: firstname, email: email);
}
