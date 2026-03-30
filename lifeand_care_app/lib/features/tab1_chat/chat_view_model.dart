import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lifeand_care_app/data/services/history_view_model.dart';
import 'package:lifeand_care_app/core/api_config.dart';

class ChatMessage {
  final String content;
  final String type; // 'user' or 'ai'
  final DateTime timestamp;

  ChatMessage({required this.content, required this.type, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
  
  // Legacy support for 'text' and 'isUser' if needed in other parts
  String get text => content;
  bool get isUser => type == 'user';
}

class ChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isAiAvailable = true;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isAiAvailable => _isAiAvailable;

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
    notifyListeners();
  }
}
