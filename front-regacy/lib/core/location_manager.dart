import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class LocationManager extends ChangeNotifier {
  static final LocationManager _instance = LocationManager._internal();
  factory LocationManager() => _instance;
  LocationManager._internal();

  NLatLng _currentPosition = const NLatLng(37.5665, 126.9780); // Default: Seoul
  NLatLng get currentPosition => _currentPosition;

  bool _isServiceEnabled = false;
  bool get isServiceEnabled => _isServiceEnabled;

  Future<void> init() async {
    _isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (_isServiceEnabled) {
      await updatePosition();
    }
  }

  Future<void> updatePosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        _currentPosition = NLatLng(position.latitude, position.longitude);
        notifyListeners();
      }
    } catch (e) {
      print("[LocationManager] Positioning failed: $e");
    }
  }
}
