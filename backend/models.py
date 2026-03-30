from pydantic import BaseModel
from typing import List, Optional

class ChatRequest(BaseModel):
    message: str
    lat: float | None = None
    lng: float | None = None

class ChatResponse(BaseModel):
    content: str
    message_type: str # 'text', 'hospital_card', 'emergency'

class ReportRequest(BaseModel):
    history: str

class ReportResponse(BaseModel):
    summary: str

class SummaryRequest(BaseModel):
    user_msg: str
    ai_msg: str

class SummaryResponse(BaseModel):
    status: str  # "0": 정상, "1": 위험/응급
    summary: str # 증상 요약

class SummarySessionRequest(BaseModel):
    history: str

class SummarySessionResponse(BaseModel):
    note: str
