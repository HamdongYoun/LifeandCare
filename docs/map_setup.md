# Map Module Permission & Auth Guide

이 문서는 Life & Care 서비스의 지도 시스템(Leaflet/Naver Maps) 권한 및 인증 설정을 설명합니다.

## 1. Browser Geolocation (위치 정보 권한)
사용자의 실시간 위치 추적을 위해 브라우저 표준 Geolocation API를 사용합니다.

### 권한 요청 흐름
- **요청 시점**: '지도(Map)' 탭에 최초 진입하거나, 채팅 중 병원 추천([HOSPITAL] 태그) 메시지가 발생할 때 브라우저 팝업을 통해 권한을 요청합니다.
- **실시간 추적**: `navigator.geolocation.watchPosition`을 사용하여 사용자의 이동 경로를 실시간으로 추적합니다.
- **예외 처리**: 
    - 권한 거부 시: 기본 위치(서울시청)를 기준으로 서비스를 제공합니다.
    - 신호 약함/타임아웃: 마지막으로 확인된 위치 정보를 유지합니다.

---

## 2. API Authentication (인터페이스 인증)
지도의 고도화된 기능과 병원 데이터 조회를 위해 다음 API 키 설정이 필요합니다.

### A. HIRA API (공공데이터포털)
- **용도**: 주변 병원 정보(주소, 전화번호, 응급실 운영 등) 조회.
- **설정**: `.env` 파일의 `HIRA_API_KEY` 항목에 입력.
- **상태 확인**: `http://localhost:8000/hospitals` 호출 시 정상 데이터(JSON) 반환 여부.

### B. Naver Maps API (고도화용)
- **용도**: 향후 Leaflet에서 Naver Maps SDK로 전환하거나, Static Map/Geocoding 기능을 강화할 때 사용.
- **신청**: [네이버 클라우드 플랫폼](https://www.ncloud.com/product/applicationService/maps)에서 클라이언트 ID 발급.
- **설정**: `NAVER_MAP_CLIENT_ID` 환경 변수 사용.

---

## 3. UI Status Indicator (권한 상태 확인)
사용자는 앱 내 **'설정(Settings)'** 탭에서 현재 위치 정보 권한 상태를 확인할 수 있습니다.
- **정상**: 🟢 위치 정보 수신 중
- **거부/오류**: 🔴 위치 정보 접근 불가 (기본 위치 기반 제공)

---

## 4. Perfect Implementation Success Factors (성공 요인 분석)

현재 서비스의 지도 및 병원 데이터 연동이 완벽하게 구동되는 기술적 요인은 다음과 같습니다.

### ✅ Naver Maps Directions 5 최적화
- **공식 엔드포인트 준수**: `naveropenapi.apigw.ntruss.com` 대신 최신 공식 문서 권장 도메인인 `maps.apigw.ntruss.com`을 사용하여 인증 안정성을 확보했습니다.
- **Header Naming**: API Gateway의 케이스 민감도를 고려하여 헤더를 소문자(`x-ncp-apigw-api-key-id`)로 통일했습니다.
- **Response Flattening**: Directions 5의 복잡한 응답 구조(`route.trafast[0].path`)를 백엔드 레이어에서 추출하여 프론트엔드가 즉시 렌더링할 수 있는 단순 구조(`{path: [...]}`)로 변환하여 실시간성을 높였습니다.

### ✅ E-Gen 실시간 데이터 복구
- **Service Path 수정**: 기존의 잘못된 경로(`HsptlAsembySearchService`)를 최신 API 규격인 `ErmctInfoInqireService`로 정정하여 404 에러를 원천적으로 해결했습니다.

### ✅ Frontend 안정화 (Fail-safe)
- **초기화 루프 방지**: 지도 컨테이너 높이가 0일 때 발생하는 `setTimeout` 무한 루프에 최대 시도 횟수 제한 및 `isInitializing` 플래그를 도입하여 브라우저 메모리 고갈을 방지했습니다.
- **자동 엔진 전환**: 네이버 지도 인증 실패(401/403) 발생 시, 사용자에게 에러를 보여주는 대신 즉시 Leaflet 엔진으로 자동 전환(Fallback)하여 서비스 연속성을 보장합니다.