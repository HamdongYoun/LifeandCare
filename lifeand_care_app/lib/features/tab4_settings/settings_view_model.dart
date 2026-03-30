import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      // Mock successful login
      _isLoggedIn = true;
    } catch (e) {
      throw Exception("Login failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check Location Permission
      LocationPermission permission = await Geolocator.checkPermission();
      _isLocationEnabled = (permission == LocationPermission.always || permission == LocationPermission.whileInUse);

      // 2. Check Backend Connectivity
      final url = Uri.parse('http://127.0.0.1:8000/status'); // Assuming health check endpoint
      final resp = await http.get(url).timeout(const Duration(seconds: 3));
      _isBackendConnected = (resp.statusCode == 200);
      
    } catch (e) {
      _isBackendConnected = false;
      print("[SettingsVM] Check failed: $e");
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
