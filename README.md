# 🏥 Life & Care - Intelligent Medical Chatbot Platform

AI 기반 증상 분석 및 주변 응급 실시간 정보를 제공하는 지능형 의료 챗봇 플랫폼입니다.

---

## 📁 프로젝트 구조 (Clean Architecture)

본 프로젝트는 높은 유지보수성과 확장성을 위해 각 도메인별로 역할이 명확히 분리된 구조를 채택하고 있습니다.

- **`backend/`**: FastAPI 기반의 RESTful API 서버 (Python)
- **`frontend/`**: 웹 기반 사용자 인터페이스 (HTML/CSS/JS)
- **`mobile/`**: Flutter 기반의 모바일 애플리케이션 (MVVM + Riverpod)
- **`docs/`**: 프로젝트 기획서 및 API 명세서 등 기술 문서
- **`tests/`**: API 테스트 및 디버깅을 위한 격리된 스크립트

---

## 🚀 시작하기 (How to Use)

### 1. 저장소 복제
```bash
git clone https://github.com/hdy4567/lifeAndCare.git
cd lifeAndCare
```

### 2. 백엔드 서버 설정 (Python)
백엔드는 **FastAPI**를 사용하며, 로컬 환경에서 다음과 같이 실행합니다.

```bash
# 가상환경 생성 및 활성화
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 필수 라이브러리 설치
pip install -r backend/requirements.txt

# 서버 실행 (uvicorn)
cd backend
python -m uvicorn main:app --reload
```
서버가 실행되면 **`http://localhost:8000`**에서 웹 인터페이스를 확인하실 수 있습니다.

### 3. API 키 설정 (중요 🔑)
프로젝트의 모든 기능을 사용하려면 `backend/.env` 파일을 생성하고 아래의 키들을 본인의 것으로 입력해야 합니다.

```env
# Gemini AI
GEMINI_API_KEY=your_gemini_key

# 공공데이터포털 (HIRA, E-Gen)
HIRA_API_KEY=your_portal_key
EGEN_API_KEY=your_portal_key

# 네이버 클라우드 플랫폼 (지도 API)
NAVER_MAP_CLIENT_ID=your_client_id
NAVER_MAP_CLIENT_SECRET=your_client_secret
```

### 4. 모바일 앱 실행 (Flutter)
모바일 프로젝트는 **Flutter v3.x** 이상이 필요합니다.

```bash
cd mobile
flutter pub get
flutter run
```

---

## 🛠️ 주요 기술 스택

- **Backend**: FastAPI, Uvicorn, Google Generative AI (Gemini-1.5-flash)
- **Frontend**: Vanilla JS, Kakao/Naver Map API, Leaflet (Fallback)
- **Mobile**: Flutter, Riverpod (State Management), Dio (Networking)
- **Data**: 공공데이터포털(건강보험심사평가원, 응급의료정보제공 등) API 연동

---

## 👨‍💻 기여 및 문의
문의 사항이나 기능 제안은 Issue를 통해 남겨주세요.
