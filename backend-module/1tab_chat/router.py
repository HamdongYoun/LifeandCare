from fastapi import APIRouter, HTTPException
from .models import ChatRequest, ChatResponse
from .service import ChatService

router = APIRouter()

@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        return await ChatService.get_chat_response(request.message, request.lat, request.lng)
    except Exception as e:
        print(f"!!! CHAT ERROR !!!: {str(e)}")
        raise HTTPException(status_code=500, detail="AI 상담 서비스 일시 중단")
