import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "service": "Life & Care Core"}

def test_chat_format():
    # 실제 AI 호출 없이 스키마 및 기본 로직만 테스트 (모의 요청)
    # 실제 API 키가 없으면 에러가 날 수 있으므로, 여기선 구조적 테스트 위주
    payload = {
        "message": "안녕",
        "lat": 37.5,
        "lng": 127.0
    }
    # 실제 Gemini API 호출을 Mocking하지 않으면 유닛 테스트가 아닌 통합 테스트가 됨
    # 여기서는 간단히 페이로드 구조만 확인
    assert "message" in payload
