from pydantic import BaseModel

class ChatRequest(BaseModel):
    message: str
    lat: float | None = None
    lng: float | None = None

class ChatResponse(BaseModel):
    content: str
    message_type: str # 'text', 'hospital_card', 'emergency'
