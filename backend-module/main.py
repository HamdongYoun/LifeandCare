from dotenv import load_dotenv
import os
import sys
import httpx
import importlib
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pathlib import Path

# --- 1. 경로 설정 및 환경 변수 로드 ---
# 현재 파일(main.py)은 backend-module 안에 있다고 가정합니다.
BACKEND_DIR = Path(__file__).resolve().parent 
ROOT_DIR = BACKEND_DIR.parent
ENV_PATH = BACKEND_DIR / ".env"

load_dotenv(dotenv_path=ENV_PATH, override=True)
sys.path.append(str(BACKEND_DIR))

# --- 2. 동적 임포트 (언더바 포함된 폴더명 대응) ---
# 우리가 만든 로직들을 연결합니다.
chat_service = importlib.import_module("_1tab_chat.service")
map_service = importlib.import_module("_2tab_map.service")
health_router = importlib.import_module("_3tab_health.router").router

# --- 3. LIFESPAN: 비동기 클라이언트 관리 ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    async with httpx.AsyncClient(timeout=httpx.Timeout(10.0, connect=5.0)) as client:
        app.state.client = client
        yield

app = FastAPI(title="Life & Care Unified Platform", lifespan=lifespan)

# --- 4. CORS 설정 (Flutter 연동 필수) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 5. 라우터 및 엔드포인트 통합 ---

# [3번 탭] 리포트 라우터 연결
app.include_router(health_router, prefix="/api/v1/health", tags=["Health Report"])

# [1번 탭] 채팅 엔드포인트 (우리가 만든 analyze_and_chat 연결)
@app.post("/api/v1/chat")
async def chat_endpoint(request: Request):
    try:
        data = await request.json()
        user_input = data.get("user_input", "") # Flutter 앱의 키값에 맞춤
        # service.py의 analyze_and_chat 함수 호출
        return chat_service.analyze_and_chat(user_input)
    except Exception as e:
        return {"stage": 1, "message": f"서버 오류: {str(e)}", "show_emergency_btn": False}

# [2번 탭] 병원 찾기 엔드포인트
@app.get("/api/v1/map/hospitals")
async def get_map_hospitals(category: str = None, lat: float = None, lng: float = None, query: str = None):
    try:
        results = map_service.get_nearby_hospitals(category, lat, lng, query)
        return {"count": len(results), "hospitals": results}
    except Exception as e:
        return {"count": 0, "hospitals": [], "error": str(e)}

# --- 6. 네이버 지도 API Proxy (기존 코드 유지) ---
@app.get("/map-proxy/static")
async def get_static_map(request: Request, lat: float, lng: float, zoom: int = 15):
    client_id = os.getenv("NAVER_MAP_CLIENT_ID")
    client_secret = os.getenv("NAVER_MAP_CLIENT_SECRET")
    url = "https://naveropenapi.apigw.ntruss.com/map-static/v2/raster"
    params = {"center": f"{lng},{lat}", "level": zoom, "w": 600, "h": 400, "scale": 2, "markers": f"type:d|size:mid|pos:{lng} {lat}"}
    headers = {"X-NCP-APIGW-API-KEY-ID": client_id, "X-NCP-APIGW-API-KEY": client_secret}
    
    resp = await request.app.state.client.get(url, params=params, headers=headers)
    return Response(content=resp.content, media_type="image/png")

# --- 7. 프론트엔드 서빙 (Flutter Web 빌드 파일) ---
# Flutter 프로젝트의 build/web 폴더 위치를 지정하세요.
FLUTTER_WEB_DIR = ROOT_DIR / "lifeand_care_app" / "build" / "web"

if FLUTTER_WEB_DIR.exists():
    app.mount("/main", StaticFiles(directory=str(FLUTTER_WEB_DIR)), name="web")
    @app.get("/")
    async def serve_root():
        return FileResponse(FLUTTER_WEB_DIR / "index.html")
else:
    @app.get("/")
    async def welcome():
        return {"message": "Backend Server is running. UI build not found."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
