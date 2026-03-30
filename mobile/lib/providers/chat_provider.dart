import '../data/services/secure_storage_service.dart';

const String _tempApiKey = 'YOUR_ACTUAL_GEMINI_API_KEY';
const String _chatBoxName = 'chat_history_secure'; // 보안을 위해 새로운 박스 이름 사용

final chatRepositoryProvider = Provider((ref) => ChatRepository(_tempApiKey));

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository, ref);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatRepository _repository;
  final Ref _ref;
  late Box<ChatMessage> _box;
  bool _isTyping = false; // 타이핑 상태 추가

  bool get isTyping => _isTyping;

  ChatNotifier(this._repository, this._ref) : super([]) {
    _initHive();
  }

  Future<void> _initHive() async {
    // 1. 암호화 키 획득
    final encryptionKey = await SecureStorageService.getOrCreateEncryptionKey();

    // 2. 암호화된 박스 열기
    _box = await Hive.openBox<ChatMessage>(
      _chatBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    state = _box.values.toList();
  }

  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessage(
      content: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];
    await _box.add(userMessage);

    _isTyping = true;
    state = [...state]; // 상태를 강제로 리프레시하여 UI에 타이핑 알림 반영

    double? lat;
    double? lng;
    
    // (위치 획득 로직 생략 - 동일)
    try {
      Position position = await _determinePosition();
      lat = position.latitude;
      lng = position.longitude;
    } catch (e) {
      print('Location error: $e');
    }

    final botResponse = await _repository.sendMessage(text, lat: lat, lng: lng);

    _isTyping = false;
    await _box.add(botResponse);
    state = [...state, botResponse];

    try {
      Position position = await _determinePosition();
      lat = position.latitude;
      lng = position.longitude;
    } catch (e) {
      print('위치 정보를 가져올 수 없습니다: $e');
    }
    
    // 2. 실제 API 호출 및 응답 수신
    final botResponse = await _repository.sendMessage(text, lat: lat, lng: lng);

    // 3. 봇 응답 저장 및 상태 추가
    await _box.add(botResponse);
    state = [...state, botResponse];

    // 4. 병원 추천 시 지도 데이터 업데이트
    if (botResponse.messageType == MessageType.hospitalCard) {
      _parseAndSetHospital(botResponse.content);
    }
  }

  void _parseAndSetHospital(String content) {
    // [HOSPITAL:병원명|주소] 형식 파싱
    final regExp = RegExp(r'\[HOSPITAL:(.*?)\|(.*?)\]');
    final match = regExp.firstMatch(content);
    if (match != null) {
      final hospitalName = match.group(1);
      if (hospitalName != null) {
        _ref.read(mapProvider.notifier).setHospitalSearch(hospitalName);
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    
    return await Geolocator.getCurrentPosition();
  }

  void clearChat() async {
    await _box.clear();
    state = [];
  }
}
