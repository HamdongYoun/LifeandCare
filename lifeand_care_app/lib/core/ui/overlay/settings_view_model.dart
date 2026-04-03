import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/**
 * [SettingsViewModel]
 * 글로벌 오버레이 설정 모듈의 상태를 관리합니다.
 * 기존 tab4_settings에서 core/ui/overlay로 승격되었습니다.
 */
class SettingsViewModel extends ChangeNotifier {
  bool _isLocationEnabled = false;
  bool get isLocationEnabled => _isLocationEnabled;

  bool _isBackendConnected = false;
  bool get isBackendConnected => _isBackendConnected;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    _isLoading = true;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      _isLocationEnabled = (permission == LocationPermission.always || permission == LocationPermission.whileInUse);

      // [SYNC] Static Map Backend Health Check
      final url = Uri.parse('http://127.0.0.1:8000/status'); 
      final resp = await http.get(url).timeout(const Duration(seconds: 3));
      _isBackendConnected = (resp.statusCode == 200);
      
    } catch (e) {
      _isBackendConnected = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    _isLocationEnabled = (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
    notifyListeners();
  }
}
