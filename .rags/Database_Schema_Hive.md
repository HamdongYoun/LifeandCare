# [aichat] Hive 로컬 데이터베이스 스키마 정의서

## 1. 개요
- 박스 이름: chat_box
- 목적: 애플리케이션 내 대화 기록(History) 영속성 유지 및 성능 최적화

## 2. 메시지 객체 구조 (ChatMessage Model)
- sender: user, bot, system (Role 구분)
- message_type: text, hospitalCard, emergencyAlert (타입 구분)
- content: 메시지 본문 (텍스트 혹은 JSON String)
- timestamp: ISO-8601 형식의 생성 시각
- action_command: 119, navigate 등 명령어 데이터 (nullable)
- countdown_seconds: 응급 상황 대기 시간 (int)

## 3. 데이터 저장 형식 (JSON Mapping)
- Hive 박스 내 history 키에 List<Map> 형태로 직렬화하여 저장
- 앱 시작 시 ChatViewModel.loadMessages() 함수를 통해 객체로 역직렬화 수행

## 4. 주의 사항
- 필드 추가 시 기존 데이터와의 호환성을 위해 기본값(defaultValue) 설정 필수
- 데이터 무결성을 위해 대화 삭제(clearChat) 기능은 박스 전체를 비우는 방식으로 구현
