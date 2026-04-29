import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lifeand_care_app/data/services/history_view_model.dart';
import 'package:lifeand_care_app/core/api_config.dart';

class ChatMessage {
  final String content;
  final String type; // 'user', 'ai', 'error', 'EMERGENCY'
  final DateTime timestamp;
  final bool isDanger;

  ChatMessage({
    required this.content, 
    required this.type, 
    DateTime? timestamp,
    this.isDanger = false,
  }) : timestamp = timestamp ?? DateTime.now();
  
  bool get isUser => type == 'user';
  bool get isAi => type == 'ai';
  bool get isEmergency => type == 'EMERGENCY';
  bool get isError => type == 'error';
  bool get isSystem => type == 'system';
}

class ChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isAiAvailable = true;

  ChatViewModel() {
    _addWelcomeMessage();
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isAiAvailable => _isAiAvailable;

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      content: "안녕하세요! Life & Care AI 상담사입니다.\n오늘 건강 상태는 어떠신가요? 궁금한 점이 있다면 무엇이든 물어보세요!",
      type: 'system',
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(content: text, type: 'user'));
    _isLoading = true;
    notifyListeners();

    try {
      final resp = await http.post(
        Uri.parse(ApiConfig.chatEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      ).timeout(ApiConfig.timeout);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content = data['content'] ?? '응답을 가져올 수 없습니다.';
        _messages.add(ChatMessage(content: content, type: 'ai'));
      } else {
        _messages.add(ChatMessage(content: "서버 응답 오류가 발생했습니다.", type: 'ai'));
      }
    } catch (e) {
      _messages.add(ChatMessage(content: "통신 오류가 발생했습니다: $e", type: 'ai'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  Future<void> saveSession(HistoryViewModel historyVM) async {
    if (_messages.length < 2) return;
    
    final aggregateStr = _messages
        .where((m) => !m.isSystem)
        .map((m) => "${m.isUser ? 'User' : 'Assistant'}: ${m.content}")
        .join("\n");
    _isLoading = true;
    notifyListeners();

    try {
      // Mapping legacy /summarize_session behavior
      final firstMsg = _messages.first.content;
      final summary = firstMsg.length > 30 ? "${firstMsg.substring(0, 30)}..." : firstMsg;
      
      historyVM.addNote(aggregateStr, summary);
      _messages.clear();
      _addWelcomeMessage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
