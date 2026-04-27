from fastapi import APIRouter, HTTPException
from typing import List
from .models import ReportSaveRequest, ReportSaveResponse, ReportItem
from .service import save_report, get_all_reports

router = APIRouter()

# 리포트 저장 엔드포인트
@router.post("/save", response_model=ReportSaveResponse)
async def save_report_endpoint(request: ReportSaveRequest):
    result = save_report(request.user_input, request.ai_response, request.stage)
    
    if result["status"] == "blocked":
        raise HTTPException(status_code=403, detail=result["message"])
    elif result["status"] == "error":
        raise HTTPException(status_code=500, detail=result["message"])
        
    return result

# 리포트 목록 조회 엔드포인트
@router.get("/list", response_model=List[ReportItem])
async def get_reports_endpoint():
    return get_all_reports()
