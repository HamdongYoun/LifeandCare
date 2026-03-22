# [aichat] RASA 자연어 처리 의도 및 엔티티 매핑 정의서

## 1. 핵심 의도 (Intents)
- ask_symptom: 사용자가 통증이나 특정 아픈 부위를 설명하는 의도
- find_hospital: 위치 정보를 바탕으로 주변 병원을 찾는 의도
- emergency_report: 심각한 사고나 위급 상황을 알리는 의도
- greet: 대화 시작 및 기본 인사
- thank: 정보 제공에 대한 감사 표현

## 2. 추출 엔티티 (Entities)
- body_part: 머리, 배, 다리 등 통증 부위
- pain_level: 콕콕 쑤심, 끊어질듯함 등 통증 강도 및 양상
- duration: 어제부터, 한 시간 전부터 등 지속 시간
- age_group: 아이, 노인 등 대상 정보

## 3. 대화 흐름 (Stories & Rules)
- 증상 감지 -> 추가 질문 (부위/시간) -> 분석 응답 (Text)
- 위치 요청 -> 주변 정보 조회 -> 결과 노출 (Hospital Card)
- 위급 키워드 감지 -> 즉시 제어 -> 응급 모드 (Emergency Alert)

## 4. 학습 데이터 기준
- 답변 정확도를 기반으로 RASA NLU 엔진을 주기적으로 재학습함
- 신조어 및 의료 전문 용어에 대한 사전(Synonym) 데이터 지속적 업데이트 포함
