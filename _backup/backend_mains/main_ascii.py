from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os
from pathlib import Path
from dotenv import load_dotenv

# 현재 파일(main.py)의 디렉토리를 기준으로 절대경로 계산
BASE_DIR = Path(__file__).resolve().parent
ENV_PATH = BASE_DIR / ".env"
FRONTEND_DIR = BASE_DIR.parent / "frontend-module"

load_dotenv(dotenv_path=ENV_PATH) # 명시적 .env 로드

# 숫자 시작 폴더 금지 규정에 맞춰 수정된 라우터 임포트
from .map_1tab.router import router as map_router
from .chat_2tab.router import router as chat_router
from .health_3tab.router import router as health_router

app = FastAPI(title="Life & Care API")

# CORS (모바일 및 웹 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 연결 (기능별 슬라이스 통합)
app.include_router(map_router, tags=["Map & Hospital"])
app.include_router(chat_router, tags=["AI Consultation"])
app.include_router(health_router, tags=["Health Report"])

@app.get("/config")
def get_config():
    return {"naver_map_client_id": os.getenv("NAVER_MAP_CLIENT_ID", "")}

@app.get("/health")
def health():
    return {"status": "ok", "architecture": "Vertical Slice"}

@app.get("/")
def read_root():
    return FileResponse(FRONTEND_DIR / "main.html")

# 정적 파일 서빙: 프론트엔드 모듈의 절대 경로 마운트
app.mount("/", StaticFiles(directory=str(FRONTEND_DIR), html=True), name="frontend")
