from fastapi import APIRouter, HTTPException
from .models import ChatRequest, ChatResponse
from .service import analyze_and_chat  # service.py에서 함수 임포트

router = APIRouter()

@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    if not request.user_input.strip():
        raise HTTPException(status_code=400, detail="내용을 입력해주세요.")
    
    # service.py에 있는 로직을 실행하여 결과 반환
    result = analyze_and_chat(request.user_input)
    return result
