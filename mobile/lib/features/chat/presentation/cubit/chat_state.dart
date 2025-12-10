import '../../domain/entities/chat_message.dart';

enum ChatStatus { idle, sending, error }

class ChatState {
  final List<ChatMessage> messages;
  final ChatStatus status;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.status = ChatStatus.idle,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      error: error,
    );
  }

  /// Initial state with welcome message
  factory ChatState.initial() {
    return ChatState(
      messages: [
        ChatMessage.bot(
          'Halo! Ada yang bingung soal rekomendasi paketnya? Tanya aku aja! 😊',
        ),
      ],
    );
  }
}
