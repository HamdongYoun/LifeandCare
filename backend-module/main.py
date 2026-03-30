from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os
import sys
from pathlib import Path

# --- 1. HARNESS: Clean start & Environment ---
ROOT_DIR = Path(__file__).resolve().parent.parent # aichat (Project Root)
BACKEND_DIR = ROOT_DIR / "backend-module"
ENV_PATH = BACKEND_DIR / ".env"

# Explicitly load from backend-module/.env
load_dotenv(dotenv_path=ENV_PATH, override=True)

# Add backend-module to sys.path
sys.path.append(str(BACKEND_DIR))

# Dynamic Imports to bypass Python identifier restrictions (starting with digits)
import importlib

chat_mod = importlib.import_module("1tab_chat.service")
MapService = importlib.import_module("2tab_map.service").MapService
health_router = importlib.import_module("3tab_health.router").router
ChatService = chat_mod.ChatService

app = FastAPI(title="Life & Care Unified Platform")

# --- 2. CORS Mapping ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 3. Unified Endpoints ---
app.include_router(health_router, tags=["Health Report"])
@app.get("/")
async def serve_index():
    # Directly serve main.html
    frontend_dir = ROOT_DIR / "frontend-module"
    return FileResponse(frontend_dir / "main.html")

@app.get("/config")
async def get_config():
    # 표준 영문 키 명칭으로 전수 복구 및 매핑 (client_id, client_secret, gemini_api_key)
    return {
        "client_id": os.getenv("NAVER_MAP_CLIENT_ID"),
        "client_secret": os.getenv("NAVER_MAP_CLIENT_SECRET"),
        "gemini_api_key": os.getenv("GEMINI_API_KEY"),
        "gemini_active": bool(os.getenv("GEMINI_API_KEY"))
    }

@app.post("/summarize")
async def summarize_proxy(request: Request):
    # Dynamic import for health service
    HealthService = importlib.import_module("3tab_health.service").HealthService
    data = await request.json()
    return await HealthService.summarize_condition(data.get("user_msg"), data.get("ai_msg"))

@app.post("/chat")
async def chat_endpoint(request: Request):
    try:
        data = await request.json()
        message = data.get("message", "")
        lat = data.get("lat")
        lng = data.get("lng")
        return await ChatService.get_chat_response(message, lat, lng)
    except Exception as e:
        print(f"[CHAT ERROR] {e}")
        return {"content": "서버 통신 오류가 발생했습니다.", "message_type": "error"}

# --- 4. NAVER MAP ADVANCED PROXY (Directions 5, Static, Geocode) ---
@app.get("/map-proxy/static")
async def get_static_map(lat: float, lng: float, zoom: int = 15):
    client_id = os.getenv("NAVER_MAP_CLIENT_ID")
    client_secret = os.getenv("NAVER_MAP_CLIENT_SECRET")
    url = "https://naveropenapi.apigw.ntruss.com/map-static/v2/raster"
    params = {"center": f"{lng},{lat}", "level": zoom, "w": 600, "h": 400, "scale": 2, "markers": f"type:d|size:mid|pos:{lng} {lat}"}
    headers = {"X-NCP-APIGW-API-KEY-ID": client_id, "X-NCP-APIGW-API-KEY": client_secret}
    async with httpx.AsyncClient() as client:
        resp = await client.get(url, params=params, headers=headers)
        return Response(content=resp.content, media_type="image/png") if resp.status_code == 200 else {"error": "Static Map Fail"}

@app.get("/map-proxy/route")
async def get_driving_route(start: str, goal: str):
    client_id = os.getenv("NAVER_MAP_CLIENT_ID")
    client_secret = os.getenv("NAVER_MAP_CLIENT_SECRET")
    url = "https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving"
    headers = {"X-NCP-APIGW-API-KEY-ID": client_id, "X-NCP-APIGW-API-KEY": client_secret}
    async with httpx.AsyncClient() as client:
        resp = await client.get(url, params={"start": start, "goal": goal, "option": "trafast"}, headers=headers)
        return resp.json()

@app.get("/map-proxy/geocode")
async def get_geocode(query: str):
    client_id = os.getenv("NAVER_MAP_CLIENT_ID")
    client_secret = os.getenv("NAVER_MAP_CLIENT_SECRET")
    url = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode"
    headers = {"X-NCP-APIGW-API-KEY-ID": client_id, "X-NCP-APIGW-API-KEY": client_secret}
    async with httpx.AsyncClient() as client:
        resp = await client.get(url, params={"query": query}, headers=headers)
        return resp.json()

# --- 5. HOSPITAL & EMERGENCY DATA BRIDGE ---
@app.get("/hospitals")
async def get_hospitals(lat: float, lng: float, query: str = None):
    # Dynamic import for map router
    fetch_hospitals = importlib.import_module("2tab_map.router").get_hospitals
    try:
        # Passing query to lower level router/service
        return await fetch_hospitals(lat, lng, query)
    except Exception as e:
        print(f"[HOSPITAL BRIDGE ERROR] {e}")
        return []

# --- 4. Static Files Mount ---
FRONTEND_DIR = ROOT_DIR / "frontend-module"
app.mount("/", StaticFiles(directory=str(FRONTEND_DIR), html=True), name="frontend")

if __name__ == "__main__":
    import uvicorn
    # Use standard port 8000
    uvicorn.run(app, host="127.0.0.1", port=8000)