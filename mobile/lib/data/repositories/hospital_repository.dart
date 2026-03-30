import 'dart:convert';
import 'package:http/http.dart' as http;

class Hospital {
  final String name;
  final String address;
  final String tel;
  final double lat;
  final double lng;

  Hospital({
    required this.name,
    required this.address,
    required this.tel,
    required this.lat,
    required this.lng,
  });
}

class HospitalRepository {
  final String _apiKey = 'YOUR_HIRA_API_KEY';

  Future<List<Hospital>> searchNearbyHospitals(double lat, double lng) async {
    // 실제 HIRA API 호출 로직 (예시 구조)
    // final response = await http.get(Uri.parse('http://apis.data.go.kr/...&xPos=$lng&yPos=$lat&radius=3000'));
    
    // Mock Data (HIRA API 연동 시 이 부분을 실제 파싱 코드로 대체)
    await Future.delayed(const Duration(seconds: 1));
    return [
      Hospital(
        name: '서울대학교병원',
        address: '서울특별시 종로구 대학로 101',
        tel: '1588-5700',
        lat: 37.5796,
        lng: 127.0003,
      ),
      Hospital(
        name: '삼성서울병원',
        address: '서울특별시 강남구 일원로 81',
        tel: '1599-3114',
        lat: 37.4882,
        lng: 127.0851,
      ),
    ];
  }
}
