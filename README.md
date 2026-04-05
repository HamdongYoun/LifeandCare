# 🏥 Life & Care - Modular Intelligence Medical Platform

AI 기반 증상 분석, 실시간 병원 검색, 개인 맞춤형 건강 리포트를 제공하는 **수직 슬라이스 아키텍처(Vertical Slice Architecture)** 기반 의료 플랫폼입니다.

---


1. git clone https://github.com/HamdongYoun/LifeandCare

2. docker 키기 

3. 
backend-module/.env 파일 생성 (API 키 입력)
4. docker build -t life-and-care .
5. docker run -it -p 8000:8000 life-and-care



## 🏗️ 프로젝트 아키텍처 (Modular Clean Architecture)

본 프로젝트는 도메인 중심의 모듈화를 통해 각 기능(상담, 지도, 건강)이 전용 로직과 스타일을 갖는 독립적인 구조를 지향합니다.

### 📂 디렉토리 구조 (Repository Layout)

- **`frontend-module/`**: 원자적 디자인 시스템 기반의 독립 모듈형 프론트엔드
    - `1tab_chat/`: AI 상담 엔진 및 실시간 대화 전용 모듈 (View/VM)
    - `2tab_map/`: 네이버/Leaflet 하이브리드 지도 및 주변 병원 검색 모듈
    - `3tab_health/`: 기기 내 저장된 기록 기반 AI 종합 분석 및 리포트 모듈
    - `shared-logic/css/`: 전역 디자인 토큰(`base`), 앱 쉘(`layout`), 공통 UI(`components`)의 원자적 분할
- **`backend-module/`**: 서비스 지향적 백엔드 (FastAPI)
    - 각 탭별 독립 라우터 및 서비스 레이어 구조로 연동
- **`mobile/`**: Flutter 기반 크로스 플랫폼 모바일 앱 (Riverpod)
- **`coredocs/`**: 기술 기획문서, API 명세 및 아키텍처 설계 가이드라인
- **`tests/`**: 모듈별 기능 검증용 테스팅 시나리오

---

## 🚀 빠른 시작 (Quick Start)
1. **저장소 복제:** `git clone https://github.com/HamdongYoun/LifeandCare` 후 폴더로 이동합니다.
2. **도커 실행:** Docker Desktop 또는 도커 엔진을 실행합니다.
3. **환경 설정:** `backend-module/.env` 파일을 만들고 필수 API 키를 입력합니다.
4. **이미지 빌드:** `docker build -t life-and-care .` 명령으로 이미지를 생성합니다.
5. **컨테이너 구동:** `docker run -it -p 8000:8000 life-and-care` 명령으로 서버를 시작합니다. (접속: `http://localhost:8000`)

---

### 1. 저장소 복제 및 이동
```bash
git clone https://github.com/hdy4567/lifeAndCare.git
cd lifeAndCare
```

### 2. 백엔드 서버 구동 (Python 3.10+)
FastAPI를 통해 모듈형 라우터를 통합 실행합니다.

```bash
# 가상환경 설정 및 라이브러리 설치
python -m venv venv
source venv/bin/activate  # OS 환경에 맞춰 활성화

pip install -r backend-module/requirements.txt

# 서버 실행 (uvicorn)
cd backend-module
python main.py  # 동적 모듈 로딩 방식 적용됨
```
서버 구동 후 `http://localhost:8000`에서 웹 인터페이스를 즉시 확인할 수 있습니다.

### 3. 환경 설정 (.env)
`backend-module/.env` 파일을 생성하여 필수 API 키를 설정해야 합니다.

```env
GEMINI_API_KEY=your_gemini_key
NAVER_MAP_CLIENT_ID=your_id
NAVER_MAP_CLIENT_SECRET=your_secret
HIRA_API_KEY=your_portal_key
EGEN_API_KEY=your_portal_key
```

---

## 🛠️ 핵심 기술 가이드 (Tech Stack)

- **AI Core**: Gemini-1.5-Flash (고속 요약 및 진단 보조)
- **Frontend Architecture**: 
    - **Atomic CSS**: `base.css`, `layout.css`, `components.css` 분할 로드
    - **Modular JS**: `NavigationModule` 중심의 탭간 인터럽트 프리 레이아웃
- **Map Hybrid Engine**: 네이버 맵 인증 실패 시 Leaflet 엔진 자동 폴백 적용
- **Data Persistence**: `IndexedDB` 기반의 오프라인 상담 내역 영속성 확보

---

## 🔄 주요 기능 시나리오 (Key Scenarios)

1. **지능형 상담**: 증상 입력 시 AI가 위험도를 분석하고 실시간으로 건강 배지를 업데이트합니다.
2. **병원 연계**: 상담 중 병원 방문이 필요할 경우, 키워드를 지도 모듈로 전달하여 즉시 주변 전문 병원을 검색합니다.
3. **건강 리포트**: 1탭에서의 상담 기록을 요약하여 기록하고, 3탭에서 모든 누적 기록을 종합하여 AI 정밀 분석 보고서를 생성합니다.

---

## 👨‍💻 기여 가이드
모든 코드는 **클린 아키텍처 원칙**에 따라 폴더별 독립성을 유지해야 합니다. 신규 기능 추가 시 프론트/백엔드 모듈 하위의 전용 디렉토리 내에서만 작업을 권장합니다.
