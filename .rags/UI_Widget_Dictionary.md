# [aichat] 플러터 전용 의료 위젯 명세서 (WebView 대응)

## 1. HospitalCardWidget
- 구성 요소: 병원 이미지, 병원명, 거리 정보, 진료 여부.
- 인터랙션: 클릭 시 해당 병원의 지도를 2번 탭(MapWebViewTab)에서 열도록 명령 전달.

## 2. MapWebViewTab (신규)
- 역할: 앱 내 2번째 탭으로 동작하며 국내 주요 지도를 웹뷰로 렌더링.
- 특징: webview_flutter를 사용하며, 검색어나 좌표 위주의 초기 URL 설정 기능 포함.

## 3. EmergencyAlertWidget
- 특징: 전체 화면 Overlay, 배경 빨간색 애니메이션, 카운트다운.
- 동작: 카운트다운 완료 시 url_launcher를 통해 tel:119 연동.

## 4. WaveLoadingAnimation
- 특격: AI 분석 중임을 나타내는 waveDots 타입 애니메이션 (loading_animation_widget 패키지).
