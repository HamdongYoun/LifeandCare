from fastapi import APIRouter, HTTPException
from .models import ReportRequest, ReportResponse, SummaryRequest, SummaryResponse, SummarySessionRequest, SummarySessionResponse
from .service import HealthService

router = APIRouter()

@router.post("/report", response_model=ReportResponse)
async def report_endpoint(request: ReportRequest):
    try:
        return await HealthService.generate_report(request.history)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/summarize", response_model=SummaryResponse)
async def summarize_endpoint(request: SummaryRequest):
    try:
        return await HealthService.summarize_condition(request.user_msg, request.ai_msg)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/summarize_session", response_model=SummarySessionResponse)
async def summarize_session_endpoint(request: SummarySessionRequest):
    try:
        return await HealthService.summarize_session(request.history)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
