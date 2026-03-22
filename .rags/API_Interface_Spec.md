# [aichat] AI Chat 서버 API 통신 규격서 (Gemini 대응)

## 1. 개요
- 설명: Flutter 앱과 Gemini AI 서버/브릿지 간의 비동기 메시지 송수신 규격 정의.
- 엔진 명칭: Google Gemini 1.5 Flash API

## 2. 메시지 송신 (App -> Gemini/Bridge)
- 호출 방식: Google Generative AI SDK (Flutter 전용)
- 입력 파라미터
```json
{
  "prompt": "사용자가 입력한 증상 텍스트 + (Context)",
  "location": {
    "lat": "number",
    "lng": "number"
  },
  "safety_settings": "BLOCK_NONE (의료 정보 분석을 위함)",
  "generation_config": {
    "temperature": 0.3,
    "topP": 0.8
  }
}
```

## 3. 메시지 수신 및 파싱
- 응답 구조: Gemini의 스트리밍 혹은 완성형 텍스트 응답 수신
- 앱 내 변환 로직
  - 텍스트 분석 중 '심각' 키워드 발견 시 즉시 emergencyAlert 위젯 트리거.
  - 좌표 데이터 기반 병원 검색 결과 포함 시 hospitalCard로 렌더링.

## 4. 예외 및 할당량 처리
- 호출 제한 대응: 분당 호출(RPM) 초과 시 앱 내 큐잉(Queueing) 처리.
- 429 오류 발생 시: 일정 시간 지수 대기(Exponential Backoff) 후 재시도 로직 실행.
