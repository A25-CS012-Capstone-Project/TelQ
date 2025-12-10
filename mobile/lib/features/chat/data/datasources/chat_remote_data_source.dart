import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_response_dto.dart';

/// Remote data source for chat API
class ChatRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  ChatRemoteDataSource({
    required this.baseUrl,
    required this.client,
  });

  /// Send a chat message and get AI response
  /// 
  /// [message] - The user's message
  /// [userName] - The user's name for personalization
  /// [topProduct] - Optional recommended product name
  /// [reason] - Optional reason for the recommendation
  Future<ChatResponseDto> sendMessage({
    required String message,
    String? userName,
    String? topProduct,
    String? reason,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/chat');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'context': {
          'user_name': userName ?? 'Pelanggan',
          'top_product': topProduct,
          'reason': reason,
        },
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ChatResponseDto.fromJson(json);
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }
}
