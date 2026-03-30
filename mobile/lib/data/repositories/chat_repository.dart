import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatRepository {
  // 로컬 서버 주소 (모바일 에뮬레이터에서 로컬 호스트 접근 시 10.0.2.2 사용)
  final String _baseUrl = "http://10.0.2.2:8000"; 

  ChatRepository(String apiKey); // 하위 호환성을 위해 유지

  Future<ChatMessage> sendMessage(String message, {double? lat, double? lng}) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "lat": lat,
          "lng": lng,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['content'] as String;
        final typeStr = data['message_type'] as String;

        MessageType type = MessageType.text;
        if (typeStr == "emergency") type = MessageType.emergencyAlert;
        if (typeStr == "hospital_card") type = MessageType.hospitalCard;

        return ChatMessage(
          content: content,
          sender: MessageSender.bot,
          timestamp: DateTime.now(),
          messageType: type,
        );
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      return ChatMessage(
        content: "죄송합니다. 서버와의 연결이 원활하지 않습니다: $e",
        sender: MessageSender.system,
        timestamp: DateTime.now(),
      );
    }
  }
}
