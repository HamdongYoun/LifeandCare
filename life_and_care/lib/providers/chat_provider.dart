import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_message.dart';
import '../data/repositories/chat_repository.dart';

// API Key 로딩을 위한 환경 변수 (추후 .env 연동 시 수정)
const String _tempApiKey = 'YOUR_ACTUAL_GEMINI_API_KEY';

final chatRepositoryProvider = Provider((ref) => ChatRepository(_tempApiKey));

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref.watch(chatRepositoryProvider));
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatRepository _repository;

  ChatNotifier(this._repository) : super([]);

  Future<void> sendMessage(String text, {double? lat, double? lng}) async {
    final userMessage = ChatMessage(
      content: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    // 1. 사용자 메시지 상태 추가
    state = [...state, userMessage];

    // 2. 로딩 메시지(시스템) 추가 가능 (UI에서 처리 권장)
    
    // 3. 실제 API 호출 및 응답 수신
    final botResponse = await _repository.sendMessage(text, lat: lat, lng: lng);

    // 4. 봇 응답 상태 추가
    state = [...state, botResponse];
  }

  void clearChat() {
    state = [];
  }
}
