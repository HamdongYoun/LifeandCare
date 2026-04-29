import 'package:flutter/foundation.dart';

class ApiConfig {
  // Singleton instance
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  // Internal state
  static String _baseUrl = "http://127.0.0.1:8000";
  static bool _isLoaded = false;

  /// Initialize Global Configuration (Singleton Load)
  /// To be called at the very beginning of main()
  static Future<void> init() async {
    if (_isLoaded) return;

    // 1. Build-time Injection (Dart Define)
    // Usage: flutter build web --dart-define=BASE_URL=https://api.yourdomain.com
    const String injectedUrl = String.fromEnvironment('BASE_URL', defaultValue: "");
    
    if (injectedUrl.isNotEmpty) {
      _baseUrl = injectedUrl;
      if (kDebugMode) print("[ApiConfig] Injected BaseURL: $_baseUrl");
    } else {
      // Default fallback for local dev
      _baseUrl = "http://127.0.0.1:8000";
      if (kDebugMode) print("[ApiConfig] Using Default BaseURL: $_baseUrl");
    }

    _isLoaded = true;
  }

  // Getters
  static String get baseUrl => _baseUrl;

  // Vertical Slice Endpoints
  static String get chatEndpoint => "$_baseUrl/chat";
  static String get mapHospitalsEndpoint => "$_baseUrl/map/hospitals";
  static String get healthReportEndpoint => "$_baseUrl/health/report";
  static String get configEndpoint => "$_baseUrl/config";
  static String get staticMapEndpoint => "$_baseUrl/map-proxy/static";
  static String get routeEndpoint => "$_baseUrl/map-proxy/route";
  static String get geocodeEndpoint => "$_baseUrl/map-proxy/geocode";
  static String get backendStatusEndpoint => "$_baseUrl/";

  // Configuration
  static const Duration timeout = Duration(seconds: 20);
}
