# [aichat] Riverpod 기반 MVVM 아키텍처 구현 명세서

## 1. 아키텍처 개요 (MVVM + Riverpod)
- View: 상태를 구독(watch)하여 화면 렌더링. 사용자의 액션을 ViewModel에 전달.
- ViewModel (Notifier): 비즈니스 로직 처리 및 상태(State) 업데이트.
- Model: 데이터 구조 및 직렬화 정의.
- Repository: 외부 API(Gemini, RASA) 및 로컬 저장소(Hive)와의 통신 추상화.

## 2. 주요 레이어 및 구성 요소
- lib/data/models/: ChatMessage, HospitalCard 등 데이터 모델.
- lib/data/repositories/: ChatRepository (백엔드 통신 담당).
- lib/providers/: 
    - chatProvider (StateNotifierProvider): 채팅 리스트 및 입력 상태 관리.
    - mapProvider (StateProvider): 현재 선택된 병원/맵 검색어 관리.
    - emergencyProvider (ChangeNotifierProvider): 응급 카운트다운 로직 관리.
- lib/ui/views/: 메인 채팅 화면, 지도 웹뷰 화면 등.

## 3. 데이터 흐름 (Data Flow)
- 단계 1: 사용자가 메시지 입력 -> ChatNotifier.sendMessage() 호출.
- 단계 2: ChatNotifier가 Geolocator를 통해 위치 획득 후 ChatRepository에 API 요청.
- 단계 3: Gemini 분석 결과 수신 -> 상태(State) 업데이트 -> UI 자동 리렌더링.
- 단계 4: 결과가 응급 상황일 경우 emergencyProvider 트리거 및 레이어 노출.

## 4. 구현 가이드
- 전역 상태 관리: main.dart 최상단을 ProviderScope로 감싸기.
- 가독성 원칙: 뷰 내부에 비즈니스 로직을 직접 넣지 않고 반드시 Provider를 통해 read/watch 수행.
- 에러 핸들링: 비즈니스 로직 내 try-catch 결과를 전역 상태 앱바/스낵바 알림으로 연결.
