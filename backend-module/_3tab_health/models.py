from pydantic import BaseModel
from typing import List, Optional, Dict, Any

# 리포트 저장 요청 규격
class ReportSaveRequest(BaseModel):
    user_input: str
    ai_response: str
    stage: int

# 리포트 저장 결과 응답 규격
class ReportSaveResponse(BaseModel):
    status: str
    message: Optional[str] = None
    summary: Optional[str] = None
    file: Optional[str] = None

# 리포트 목록 개별 항목 규격
class ReportItem(BaseModel):
    id: str
    date: str
    stage: int
    summary: str
    raw_data: Dict[str, str]
    meta: Dict[str, str]
