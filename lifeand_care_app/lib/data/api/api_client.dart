import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifeand_care_app/core/api_config.dart';

class ApiClient {
  // Use centralized configuration from ApiConfig

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to connect to backend: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> get(String path) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}$path'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }
}
