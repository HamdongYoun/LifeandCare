import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final GenerativeModel _model;

  ChatRepository(String apiKey) 
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.3,
            topP: 0.8,
            maxOutputTokens: 1024,
          ),
        );

  Future<ChatMessage> sendMessage(String prompt, {double? lat, double? lng}) async {
    // 1. 시스템 프롬프트 주입 (의료 상담 전문가 페르소나 및 위치 정보 전송)
    final systemContext = "당신은 의료 상담 전문가 'Life & Care AI'입니다. "
        "사용자의 증상을 분석하고 주변 병원 정보를 안내하세요. "
        "현재 위치 좌표: 위도 ${lat ?? '알수없음'}, 경도 ${lng ?? '알수없음'}. "
        "응답은 반드시 한국어로 하며, 위급 시에는 119 호출을 권고하세요.";

    try {
      final content = [
        Content.text(systemContext),
        Content.text(prompt),
      ];
      
      final response = await _model.generateContent(content);
      final textResponse = response.text ?? "죄송합니다. 답변을 생성할 수 없습니다.";

      return ChatMessage(
        content: textResponse,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
        // TODO: textResponse를 분석하여 MessageType(hospitalCard 등) 분류 로직 추가 필요
      );
    } catch (e) {
      return ChatMessage(
        content: "통신 에러가 발생했습니다: $e",
        sender: MessageSender.system,
        timestamp: DateTime.now(),
      );
    }
  }
}
