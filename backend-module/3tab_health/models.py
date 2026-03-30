from pydantic import BaseModel

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
