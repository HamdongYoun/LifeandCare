# [aichat] 플러터/웹 전용 의료 위젯 명세서 (Premium UI)

## 1. ChatInterface (메인 탭 - 1순위)
- 역할: 서비스 진입 시 가장 먼저 보이는 1번 탭.
- 구성: 대화형 UI, AI 아바타, 입력 필드, 전송 버튼.
- 인터랙션: 메시지 전송 시 실시간 피드백 및 Lottie 애니메이션 적용.

## 2. HospitalCardWidget
- 구성 요소: 병원 이미지, 병원명, 거리 정보, 진료 여부.
- 인터랙션: 클릭 시 해당 병원의 지도를 2번 탭(MapTab)에서 열도록 명령 전달.

## 3. MapTab (2순위)
- 역할: 앱 내 2번째 탭으로 동작하며 국내 주요 지도를 웹뷰 또는 네이티브로 렌더링.
- 특징: 검색어나 좌표 위주의 초기 URL 설정 기능 포함.

## 4. HealthReportTab (3순위)
- 역할: 사용자 건강 데이터 요약 및 리포트 제공.
- 시각화: 카드 형태의 요약 정보, 그래프 등.

## 5. EmergencyAlertWidget
- 특징: 전체 화면 Overlay, 배경 빨간색 애니메이션, 카운트다운.
- 동작: 카운트다운 완료 시 url_launcher를 통해 tel:119 연동.

## 6. Premium Aesthetics Notes
- Color: Primary Blue (#3B82F6), Background Gray (#F9FAFB).
- Typography: Outfit (Heading), Inter (Body).
- Shadow: Subtle soft shadows (Elevation equivalent to 4-6 in Flutter).
