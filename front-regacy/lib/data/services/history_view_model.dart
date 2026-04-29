import 'package:flutter/material.dart';

class HistoryItem {
  final String id;
  final String summary;
  final DateTime date;
  final String fullLog;

  HistoryItem({
    required this.id,
    required this.summary,
    required this.date,
    required this.fullLog,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'date': date.toIso8601String(),
      'full_log': fullLog,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? '',
      summary: json['summary'] ?? '',
      date: DateTime.parse(json['date']),
      fullLog: json['full_log'] ?? '',
    );
  }
}

class HistoryViewModel extends ChangeNotifier {
  final List<HistoryItem> _history = [];
  List<HistoryItem> get history => _history;

  void addNote(String log, String summary) {
    if (log.isEmpty) return;
    
    final newItem = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      summary: summary.isEmpty ? "간략 증상 기록" : summary,
      date: DateTime.now(),
      fullLog: log,
    );

    _history.insert(0, newItem);
    notifyListeners();
  }

  void deleteNote(String id) {
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  HistoryItem? get latestReport => _history.isNotEmpty ? _history.first : null;
}
