# Life & Care API 신청 및 발급 가이드

이 문서는 프로젝트에서 Mock 데이터를 제거하고 실제 데이터를 사용하기 위해 필요한 외부 서비스 API 신청 방법입니다.

---

## 0. 개요
본 프로젝트는 Google Gemini, 공공데이터포털(HIRA/E-Gen), Naver Maps API를 연동하여 통합 의료 가이드를 제공합니다.
- **상세 데이터 규격**: 각 API의 제공 데이터 및 서비스 요구사항은 [CORE_API_SPECIFICATIONS.md](docs/CORE_API_SPECIFICATIONS.md)를 참고하세요.

## 1. 사전 준비 (Prerequisites)
모든 Mock 데이터가 제거되었으므로, 아래 키들을 `server/.env`에 등록해야 정상 작동합니다.

- [ ] **Google Gemini API**: 상담 및 리포트 생성 엔진
- [ ] **HIRA 병원정보 API**: 주변 병원 기본 정보 제공
- [ ] **E-Gen(응급의료포털) API**: 실시간 응급실 가용 병상 정보 제공 (필수)

---

## 1. Google Gemini API (상담 엔진)
현재 채팅 로직 및 리포트 분석의 핵심 모듈입니다.
- **신청 주소**: [Google AI Studio](https://aistudio.google.com/app/apikey)
- **설정**: `GEMINI_API_KEY`에 발급받은 키 입력.
- **[중요] 모델 선택 및 쿼터 제한(Rate Limit) 가이드**:
  - `gemini-2.5-flash`: 고성능 모델이나, 무료 티어의 분당 요청(RPM) 한도가 매우 낮아 개발/테스트 중 쉽게 `429 Quota Exceeded` 오류가 발생합니다.
  - `gemini-2.5-flash-lite`: `flash` 대비 속도가 빠르고 **무료 티어 한도가 훨씬 관대하게 부여**되어 무중단 서비스 테스트에 적합합니다. (`1.5` 시리즈는 Deprecated)
  - **해결책**: 백엔드에서는 `gemini-2.5-flash-lite`를 기본으로 사용하고, 쿼터 제한 도달 시 `gemini-2.5-flash`로 우회하는 **Auto-Fallback 체인**을 구축하여 안정성을 극대화했습니다.

## 2. 공공데이터포털 - HIRA API (병원 정보)
건강보험심사평가원에서 제공하는 실시간 병원 데이터입니다.
- **신청 주소**: [공공데이터포털 (data.go.kr)](https://www.data.go.kr/data/15001695/openapi.do)
- **항목**: '건강보험심사평가원_병원정보서비스' 활용 신청.
- **설정**: `HIRA_API_KEY`에 '일반 승인키(Decoding)' 입력.

## 3. 공공데이터포털 - E-Gen API (실시간 응급실)
국립중앙의료원에서 제공하는 실시간 응급실 가용 병상 정보입니다.
- **신청 주소**: [공공데이터포털 (data.go.kr)](https://www.data.go.kr/data/15000563/openapi.do)
- **항목**: '국립중앙의료원_전국 응급의료기관 정보 조회 서비스' 활용 신청.
- **설정**: `EGEN_API_KEY`에 '일반 승인키(Decoding)' 입력.

## 4. Naver Maps API (지도 고도화 - 선택)
현재 기본은 Leaflet이지만, 고도화된 기능이 필요할 때 사용합니다.
- **신청 주소**: [네이버 클라우드 플랫폼 Maps](https://www.ncloud.com/product/applicationService/maps)
- **무료 한도 (매월 계정당)**:
    - **Web Dynamic Map**: 60,000건 (무료)
    - **Mobile Dynamic Map (SDK)**: 1,000만건 (무료)
    - **Geocoding (주소-좌표 변환)**: 300만건 (무료)
    - **Static Map (이미지 지도)**: 200만건 (무료)
- **설정**: `NAVER_MAP_CLIENT_ID`에 Client ID 입력.

---

## 🛠 .env 설정 예시
```env
GEMINI_API_KEY=your_gemini_key_here
HIRA_API_KEY=your_hira_key_here
EGEN_API_KEY=your_egen_key_here
```
