import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:lifeand_care_app/core/app_theme.dart';
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
  MapViewModel() { // 더미파일 , 실제 데이터 넣을 시 삭제 ///////
    _injectDummyHospitals();
  }

  NLatLng _userPosition = const NLatLng(37.5665, 126.9780); 
  final List<HospitalModel> _allModels = []; 
  Set<NMarker> _markers = {};
  bool _isLoading = false;
  String _selectedCategory = '전체';

  void _injectDummyHospitals() {
    final dummies = [
      HospitalModel( // 더미파일 , 실제 데이터 넣을 시 삭제 ///////
        name: "서울 라이프 종합병원",
        lat: 37.5675,
        lng: 126.9880,
        addr: "서울특별시 중구 남통동 11-2",
        status: "진료중",
        erBeds: "12/20",
        category: "종합병원",
      ),
      HospitalModel( // 더미파일 , 실제 데이터 넣을 시 삭제 ///////
        name: "강남 바른케어 내과",
        lat: 37.5650,
        lng: 126.9680,
        addr: "서울특별시 강남구 역삼로 542",
        status: "진료중",
        erBeds: "정보 없음",
        category: "내과",
      ),
      HospitalModel(
        name: "스마트 헬스 검진센터",
        lat: 37.5710,
        lng: 127.0010,
        addr: "서울특별시 종로구 대학로 101",
        status: "예약제",
        erBeds: "정보 없음",
        category: "검진센터",
      ),
      HospitalModel(
        name: "우리마음 정신건강의학과",
        lat: 37.5590,
        lng: 126.9720,
        addr: "서울특별시 서초구 반포대로 22",
        status: "상담가능",
        erBeds: "정보 없음",
        category: "정신건강",
      ),
      HospitalModel(
        name: "튼튼 정형외과",
        lat: 37.5820,
        lng: 126.9810,
        addr: "서울특별시 송파구 가락동 77-1",
        status: "야간진료",
        erBeds: "정보 없음",
        category: "정형외과",
      ),
    ];
    _allModels.addAll(dummies);
    _applyFilter(); // 초기 마커 생성
  }

  NLatLng get userPosition => _userPosition;
  Set<NMarker> get markers => _markers;
  List<HospitalModel> get allModels => _allModels; 
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  Future<void> startLocationTracking() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _userPosition = NLatLng(position.latitude, position.longitude);
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
    
    for (var model in _allModels) {
      if (_selectedCategory == '전체' || model.category == _selectedCategory) {
        final marker = NMarker(
          id: model.name,
          position: NLatLng(model.lat, model.lng),
        );
        marker.setCaption(NOverlayCaption(text: model.name));
        _markers.add(marker);
      }
    }
    // [SYNC] Update existing controller if available
    _mapController?.addOverlayAll(_markers);
  }

  NaverMapController? _mapController;

  void onMapReady(NaverMapController controller) {
    _mapController = controller;
    _mapController?.addOverlayAll(_markers);
  }

  void animateTo(NLatLng target) {
    _mapController?.updateCamera(
      NCameraUpdate.withParams(
        target: target,
        zoom: 16,
      )..setAnimation(duration: const Duration(milliseconds: 500)),
    );
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
  Future<void> launchNaverMap(String hospitalName) async {
    final query = Uri.encodeComponent(hospitalName);
    final url = Uri.parse("https://map.naver.com/v5/search/$query");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("[MapVM] Could not launch Naver Map for: $hospitalName");
    }
  }
}
