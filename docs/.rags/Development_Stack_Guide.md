# [aichat] 개발 스택 및 환경 설정 가이드 (v2.2)

## 1. 프론트엔드 (Mobile App)
- 프레임워크: Flutter (Dart)
- 상태 관리: Provider (ChangeNotifierProvider, Consumer)
- 로직 패턴: MVVM (Model-View-ViewModel)

## 2. 주요 라이브러리 및 패키지
- AI 브레인: Google Gemini 2.0 Flash (최신 모델, 뛰어난 분석 성능)
- 지도/네비게이션: webview_flutter (네이버/카카오 지도 웹뷰 연동 방식)
- 네트워크 통신: Dio, google_generative_ai
- 데이터 저장: Hive (로컬 영속성 관리)
- 위치 서비스: Geolocator
- 시스템 기능: URL Launcher (119 호출용)

## 3. 백엔드 및 대화 엔진
- 대화 분석: RASA (의도 파악 및 스토리 관리)
- 뉘앙스 처리: KoBERT (한국어 문맥 분석 최적화)
- 중계 서버: Python FastAPI (App <-> Gemini <-> RASA)

## 4. 지도 시스템 (WebView 기반)
- 방식: 2번째 탭에서 Naver/Kakao Maps 웹 URL 호출.
- 장점: 별도 SDK 로딩 없이 링크 및 웹 인터페이스 활용 가능.
- 연동: 1번 탭의 병원 카드 클릭 시 해당 병원명을 검색어로 포함한 지도 URL 생성 및 2번 탭으로 전달.
