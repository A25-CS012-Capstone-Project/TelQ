/// Represents a single chat message in the conversation.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  /// Create a user message
  factory ChatMessage.user(String text) => ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  /// Create a bot message
  factory ChatMessage.bot(String text) => ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      );
}
