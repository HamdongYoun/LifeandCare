import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lifeand_care_app/data/services/history_view_model.dart';
import 'package:lifeand_care_app/core/api_config.dart';

class HealthReportModel {
  final int score;
  final String status;
  final String content;
  final List<String> suggestions;

  HealthReportModel({
    required this.score,
    required this.status,
    required this.content,
    required this.suggestions,
  });

  factory HealthReportModel.fromJson(Map<String, dynamic> json) {
    return HealthReportModel(
      score: json['score'] ?? 0,
      status: json['status'] ?? '알 수 없음',
      content: json['content'] ?? '분석 데이터가 부족합니다.',
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }

  factory HealthReportModel.empty() {
    return HealthReportModel(
      score: 0,
      status: '데이터 없음',
      content: '히스토리가 비어 있습니다.',
      suggestions: [],
    );
  }
}

class HealthViewModel extends ChangeNotifier {
  final HistoryViewModel _historyVM;
  HealthReportModel _report = HealthReportModel.empty();
  bool _isLoading = false;

  HealthViewModel(this._historyVM);

  HealthReportModel get report => _report;
  bool get isLoading => _isLoading;

  String get healthStatus => _report.status;
  String get statusLabel => _report.status;
  Color get statusColor {
    if (_report.score >= 80) return const Color(0xFF10B981);
    if (_report.score >= 40) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  Future<void> fetchHealthReport() async {
    if (_historyVM.history.isEmpty) {
      _report = HealthReportModel.empty();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final aggregateHistory = _historyVM.history.map((h) => h.summary).join("\n");
      final url = Uri.parse(ApiConfig.healthReportEndpoint);
      
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'history': aggregateHistory}),
      ).timeout(ApiConfig.timeout);
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _report = HealthReportModel.fromJson(data);
      }
    } catch (e) {
      debugPrint("[HealthVM] Data Stream Fetch failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

