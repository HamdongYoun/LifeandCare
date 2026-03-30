import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:lifeand_care_app/core/api_config.dart';

class HospitalModel {
  final String name;
  final double lat;
  final double lng;
  final String addr;
  final String status;
  final String erBeds;
  final String category; // [Upgrade] 필수 속성 추가

  HospitalModel({
    required this.name,
    required this.lat,
    required this.lng,
    required this.addr,
    required this.status,
    required this.erBeds,
    required this.category, // [Birth Guard] 생성 시 강제
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      name: json['name'] ?? json['dutyName'] ?? '이름 없음',
      lat: (json['lat'] ?? json['wgs84Lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? json['wgs84Lon'] ?? 0.0).toDouble(),
      addr: json['addr'] ?? json['dutyAddr'] ?? '주소 없음',
      status: json['status'] ?? '정상',
      erBeds: json['er_beds'] ?? '정보 없음',
      category: json['category'] ?? '병원', // 기본값 병원
    );
  }
}

class MapViewModel extends ChangeNotifier {
  LatLng _userPosition = const LatLng(37.5665, 126.9780); 
  final List<HospitalModel> _allModels = []; // 원본 데이터 보존
  Set<Marker> _markers = {};
  bool _isLoading = false;
  String _selectedCategory = '전체';

  LatLng get userPosition => _userPosition;
  Set<Marker> get markers => _markers;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  Future<void> startLocationTracking() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      _userPosition = LatLng(position.latitude, position.longitude);
      notifyListeners();
      searchHospitals();
    } catch (e) {
      debugPrint("[MapVM] Location Tracking failed: $e");
    }
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _markers.clear();
    
    // 내 위치 마커는 항상 표시
    _markers.add(Marker(
      markerId: const MarkerId('user_loc'),
      position: _userPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: '내 위치'),
    ));

    for (var model in _allModels) {
      if (_selectedCategory == '전체' || model.category == _selectedCategory) {
        _markers.add(Marker(
          markerId: MarkerId(model.name),
          position: LatLng(model.lat, model.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            model.category == '약국' ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed
          ),
          infoWindow: InfoWindow(
            title: model.name,
            snippet: "[${model.category}] ${model.addr}",
          ),
        ));
      }
    }
  }

  Future<void> searchHospitals([String? query]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/map/hospitals?lat=${_userPosition.latitude}&lng=${_userPosition.longitude}&query=${query ?? ""}');
      final resp = await http.get(url).timeout(ApiConfig.timeout);
      
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        _allModels.clear();
        
        for (var h in data) {
          _allModels.add(HospitalModel.fromJson(h));
        }
        _applyFilter();
      }
    } catch (e) {
      debugPrint("[MapVM] Search failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
