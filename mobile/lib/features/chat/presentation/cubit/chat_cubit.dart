import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../domain/entities/chat_message.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRemoteDataSource _dataSource;

  ChatCubit({required ChatRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(ChatState.initial());

  /// Send a message to the AI chatbot
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately
    final userMessage = ChatMessage.user(text);
    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      status: ChatStatus.sending,
    ));

    try {
      // Get user name from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name') ?? 'Pelanggan';

      // Send to API
      final response = await _dataSource.sendMessage(
        message: text,
        userName: userName,
      );

      // Add bot response
      final botMessage = ChatMessage.bot(response.reply);
      emit(state.copyWith(
        messages: [...state.messages, botMessage],
        status: ChatStatus.idle,
      ));
    } catch (e) {
      // Add error message as bot response
      final errorMessage = ChatMessage.bot(
        'Maaf, terjadi kesalahan koneksi. Coba lagi ya! 🙏',
      );
      emit(state.copyWith(
        messages: [...state.messages, errorMessage],
        status: ChatStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Clear chat history and reset to initial state
  void clearChat() {
    emit(ChatState.initial());
  }
}
