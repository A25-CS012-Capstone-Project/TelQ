/// DTO for chat API response
class ChatResponseDto {
  final String reply;
  final String sender;
  final String method;

  const ChatResponseDto({
    required this.reply,
    required this.sender,
    required this.method,
  });

  factory ChatResponseDto.fromJson(Map<String, dynamic> json) {
    return ChatResponseDto(
      reply: json['reply'] as String? ?? '',
      sender: json['sender'] as String? ?? 'bot',
      method: json['method'] as String? ?? 'Unknown',
    );
  }
}
