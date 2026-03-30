from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os
from typing import List
from dotenv import load_dotenv

load_dotenv() # .env 로드

from backend.models import (
    ChatRequest, ChatResponse, ReportRequest, ReportResponse,
    SummaryRequest, SummaryResponse
)
from backend.services.ai_service import AIService
from backend.services.map_service import MapService

app = FastAPI(title="Life & Care API")

# CORS (모바일 및 웹 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Routes ---

@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        return await AIService.get_chat_response(request.message, request.lat, request.lng)
    except Exception as e:
        print(f"!!! CHAT ERROR !!!: {str(e)}")
        raise HTTPException(status_code=500, detail="AI 상담 서비스 일시 중단")

@app.post("/report", response_model=ReportResponse)
async def report_endpoint(request: ReportRequest):
    try:
        return await AIService.generate_report(request.history)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/summarize", response_model=SummaryResponse)
async def summarize_endpoint(request: SummaryRequest):
    try:
        return await AIService.summarize_condition(request.user_msg, request.ai_msg)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/summarize_session", response_model=SummarySessionResponse)
async def summarize_session_endpoint(request: SummarySessionRequest):
    try:
        return await AIService.summarize_session(request.history)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/hospitals")
async def get_hospitals(lat: float, lng: float):
    # HIRA API (병원 조회) + E-Gen (실시간 응급실) 결합
    hira_key = os.getenv("HIRA_API_KEY")
    egen_key = os.getenv("EGEN_API_KEY")
    
    if not hira_key or "your_" in hira_key:
        return []

    # 1. HIRA 주변 병원 검색
    import httpx
    url = "http://apis.data.go.kr/B551182/hospInfoServicev2/getHospBasisList"
    params = {
        "serviceKey": hira_key, "xPos": lng, "yPos": lat,
        "radius": 3000, "numOfRows": 15, "_type": "json"
    }
    
    result = []
    async with httpx.AsyncClient() as client:
        # 병렬 조회를 위한 E-Gen 호출 (MapService 활용)
        er_data_task = MapService.get_emergency_beds(egen_key)
        hira_resp_task = client.get(url, params=params, timeout=5.0)
        
        # 병렬 처리
        import asyncio
        er_data, hira_resp = await asyncio.gather(er_data_task, hira_resp_task)

        if hira_resp.status_code == 200:
            hira_json = hira_resp.json()
            items = hira_json.get("response", {}).get("body", {}).get("items", {}).get("item", [])
            if isinstance(items, dict): items = [items]
            
            for item in items:
                h_lat = float(item.get("YPos", 0))
                h_lng = float(item.get("XPos", 0))
                name = item.get("yadmNm")
                
                result.append({
                    "name": name, "lat": h_lat, "lng": h_lng,
                    "addr": item.get("addr"), "tel": item.get("telno"),
                    "dist_value": MapService.haversine(lat, lng, h_lat, h_lng),
                    "er_beds": er_data.get(name, "정보 없음")
                })
                
    return sorted(result, key=lambda x: x["dist_value"])

@app.get("/route")
async def get_route(startLats: float, startLngs: float, endLats: float, endLngs: float):
    return await MapService.get_route(startLats, startLngs, endLats, endLngs)

@app.get("/config")
def get_config():
    return {"naver_map_client_id": os.getenv("NAVER_MAP_CLIENT_ID", "")}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/")
def read_root():
    return FileResponse("frontend/main.html")

# 정적 파일 서빙
app.mount("/", StaticFiles(directory="frontend", html=True), name="frontend")
