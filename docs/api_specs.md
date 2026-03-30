# Core API Specifications (v2.1)

본 문서는 'Life & Care' 플랫폼에서 사용하는 핵심 API들의 기술 규격과 데이터 요구사항을 정의합니다.

---

## 1. Google Gemini 2.0 Flash
AI 상담 및 분석의 핵심 엔진입니다.

*   **API가 제공하는 기능**: 고성능 자연어 이해(NLU), 한국어 최적화, 맥락 유지, JSON/텍스트 기반 답변 생성.
*   **우리가 필요한 데이터/기능**: 
    - **채팅 분석**: 사용자의 증상을 분석하여 진료과 추천(Tagging).
    - **상태 예측**: [EMERGENCY] 긴급 상황 감지 및 [HOSPITAL] 추천.
    - **리포트 생성**: 세션 로그를 바탕으로 한 종합 건강 리포트 요약.
*   **Endpoint**: `gemini-2.0-flash` (Python SDK)

---

## 2. HIRA (건강보험심사평가원)
병원 기본 정보 및 위치 정보 원천 데이터입니다.

*   **API가 제공하는 기능**: 전국 병/의원 목록, 주소, 전화번호, 진료 과목, 시설 정보, 좌표(X/Y).
*   **우리가 필요한 데이터/기능**: 
    - **위치 기반 검색**: 현재 좌표(lat, lng) 기준 5km 이내 병원 목록.
    - **기본 속성**: `yadmNm`(기관명), `addr`(주소), `telno`(전화번호), `XPos/YPos`(경도/위도).
*   **Endpoint**: `getHospBasisList` (공공데이터포털)

---

## 3. E-Gen (국립중앙의료원)
실시간 응급실 가용 상태를 추적합니다.

*   **API가 제공하는 기능**: 전국 응급의료기관 실시간 가용 병상 수, 수술 가능 여부, 소아 응급실 여부.
*   **우리가 필요한 데이터/기능**: 
    - **가용 병상 수**: `hvec`(응급실 가용 병상) 데이터를 실시간으로 수신.
    - **이름 매칭**: HIRA 데이터와 `dutyName` 기반의 매칭을 통한 실시간 정보 통합.
*   **Endpoint**: `getEmrrmRltmUsefulSckbdInfoInqire`

---

## 4. Naver Maps (Platform API)
지도 렌더링 및 경로 분석을 담당합니다.

*   **API가 제공하는 기능**: Interactive Maps (JS), Directions (Driving/Walking), Geocoding, Search.
*   **우리가 필요한 데이터/기능**: 
    - **Map Rendering**: Naver Maps SDK를 이용한 고해상도 지도 표시 (Leaflet 대비 국내 데이터 풍성).
    - **Route Finding**: `/route` 엔드포인트를 통해 출발지와 목적지 사이의 최적 주행 경로(Trafast) 수신.
*   **Endpoint**: `naveropenapi.apigw.ntruss.com/map-direction/v1/driving`

---

## [API Flow Chart]
1.  **AI 분석**: Gemini가 '[HOSPITAL:내과]' 추천.
2.  **병원 검색**: HIRA가 내과 5곳 검색.
3.  **실시간 검증**: E-Gen이 해당 병원들의 응급실 자리를 확인.
4.  **지도 렌더링**: Naver Maps가 결과를 지도 위에 뿌림.
5.  **경로 탐색**: 사용자가 병원 클릭 시 Naver Directions로 경로 안내.
