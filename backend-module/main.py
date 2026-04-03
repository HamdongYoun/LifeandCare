from dotenv import load_dotenv
import os
import sys
import httpx
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
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

# --- 1-1. LIFESPAN: Global AsyncClient Management ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    # 서버 기동 시 통신망(Client) 개설
    async with httpx.AsyncClient(timeout=httpx.Timeout(10.0, connect=5.0)) as client:
        app.state.client = client
        print("[LIFESPAN] Global AsyncClient established.")
        yield
    # 서버 종료 시 통신망 폐쇄
    print("[LIFESPAN] Global AsyncClient closed.")

app = FastAPI(
    title="Life & Care Unified Platform",
    lifespan=lifespan
)

# --- 2. CORS (Cross-Origin Resource Sharing) Setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allowing all origins for local Flutter development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 3. Unified API Endpoints ---
app.include_router(health_router, prefix="/api", tags=["Health Report"])

@app.get("/api/health")
async def health_check():
    return {"status": "ok", "service": "Life & Care API Server", "version": "2.0.0"}

@app.get("/config")
async def get_config():
    # 표준 영문 키 명칭으로 전수 복구 및 매핑 (client_id, client_secret, gemini_api_key)
    return {
        "client_id": os.getenv("NAVER_MAP_CLIENT_ID"),
        "client_secret": os.getenv("NAVER_MAP_CLIENT_SECRET"),
        "gemini_api_key": os.getenv("GEMINI_API_KEY"),
        "gemini_active": bool(os.getenv("GEMINI_API_KEY"))
    }


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
    url = "https://naveropenapi.apigw.ntruss.com/map-static/v2/raster"
    params = {"center": f"{lng},{lat}", "level": zoom, "w": 600, "h": 400, "scale": 2, "markers": f"type:d|size:mid|pos:{lng} {lat}"}
    headers = {"X-NCP-APIGW-API-KEY-ID": client_id, "X-NCP-APIGW-API-KEY": client_secret}
    
    # [OPTIMIZED] 전역 클라이언트 재사용
    resp = await request.app.state.client.get(url, params=params, headers=headers)
    return Response(content=resp.content, media_type="image/png") if resp.status_code == 200 else {"error": "Static Map Fail"}

@app.get("/map-proxy/route")
async def get_driving_route(request: Request, start: str, goal: str):
    client_id = os.getenv("NAVER_MAP_CLIENT_ID")
    client_secret = os.getenv("NAVER_MAP_CLIENT_SECRET")
    url = "https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving"
    headers = {"X-NCP-APIGW-API-KEY-ID": client_id, "X-NCP-APIGW-API-KEY": client_secret}
    
    # [OPTIMIZED] 전역 클라이언트 재사용
    resp = await request.app.state.client.get(url, params={"start": start, "goal": goal, "option": "trafast"}, headers=headers)
    return resp.json()

@app.get("/map-proxy/geocode")
async def get_geocode(request: Request, query: str):
    client_id = os.getenv("NAVER_MAP_CLIENT_ID")
    client_secret = os.getenv("NAVER_MAP_CLIENT_SECRET")
    url = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode"
    headers = {"X-NCP-APIGW-API-KEY-ID": client_id, "X-NCP-APIGW-API-KEY": client_secret}
    
    # [OPTIMIZED] 전역 클라이언트 재사용
    resp = await request.app.state.client.get(url, params={"query": query}, headers=headers)
    return resp.json()

# --- 5. HOSPITAL & EMERGENCY DATA BRIDGE ---
@app.get("/map/hospitals")
async def get_map_hospitals(lat: float, lng: float, query: str = None):
    # Dynamic import for map router
    fetch_hospitals = importlib.import_module("2tab_map.router").get_hospitals
    try:
        # Standardizing output for Flutter HospitalModel
        raw_data = await fetch_hospitals(lat, lng, query)
        refined_data = []
        for h in raw_data:
            refined_data.append({
                "name": h.get("dutyName") or h.get("name"),
                "lat": h.get("wgs84Lat") or h.get("lat"),
                "lng": h.get("wgs84Lon") or h.get("lng"),
                "addr": h.get("dutyAddr") or h.get("address"),
                "status": h.get("dutyEryn") or h.get("status", "정상"),
                "er_beds": h.get("hvec") or h.get("er_beds", "정보 없음")
            })
        return refined_data
    except Exception as e:
        print(f"[HOSPITAL BRIDGE ERROR] {e}")
        return []

# --- 6. Static Files Mount (Flutter Web) - PREMIUM SPA SERVING ---
FLUTTER_WEB_DIR = ROOT_DIR / "lifeand_care_app" / "build" / "web"

@app.middleware("http")
async def add_cache_control_header(request: Request, call_next):
    response = await call_next(request)
    # index.html과 JS 파일은 캐시하지 않도록 설정 (실무 필수)
    if request.url.path.endswith((".html", ".js", ".json")):
        response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
        response.headers["Pragma"] = "no-cache"
    return response

if FLUTTER_WEB_DIR.exists():
    # 1. Mount Sub-directories first (assets, canvaskit, etc)
    if (FLUTTER_WEB_DIR / "assets").exists():
        app.mount("/assets", StaticFiles(directory=str(FLUTTER_WEB_DIR / "assets")), name="assets")
    if (FLUTTER_WEB_DIR / "canvaskit").exists():
        app.mount("/canvaskit", StaticFiles(directory=str(FLUTTER_WEB_DIR / "canvaskit")), name="canvaskit")
    
    # 2. Serve Static Files (Top-level JS/CSS/WASM)
    @app.get("/{file_path:path}")
    async def serve_static_or_spa(file_path: str):
        full_path = FLUTTER_WEB_DIR / file_path
        if full_path.is_file():
            # JS MIME 타입 명시적 보정
            content_type = "application/javascript" if file_path.endswith(".js") else None
            return FileResponse(full_path, media_type=content_type)
        
        # 3. SPA Fallback: 존재하지 않는 경로는 index.html로 (탭 직접 접속 대응)
        return FileResponse(FLUTTER_WEB_DIR / "index.html")

    # 4. Root explicitly
    @app.get("/")
    async def serve_root():
        return FileResponse(FLUTTER_WEB_DIR / "index.html")
else:
    print(f"[WARNING] Flutter Web build directory not found at: {FLUTTER_WEB_DIR}")
    @app.get("/")
    async def fallback_root():
        return {"error": "Frontend build not found. Please run 'flutter build web'."}

if __name__ == "__main__":
    import uvicorn
    # Use standard port 8000
    uvicorn.run(app, host="127.0.0.1", port=8000)