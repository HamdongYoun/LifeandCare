# Life & Care System Architecture

이 문서는 'Life & Care' 프로젝트의 **클린 아키텍처(Clean Architecture)** 및 **공유 코어(Shared Core)** 구조에 대해 설명합니다.

---

## 🏗️ 전체 구조 (High-Level Overview)

본 시스템은 핵심 비즈니스 로직을 서버(Shared Core)에 집중시키고, 각 플랫폼(Mobile, Web)은 사용자 인터페이스(UI)만 담당하는 구조로 설계되었습니다.

### 아키텍처 다이어그램
1. **Clients (UI Layer)**: Flutter App (Mobile), HTML/JS (Web)
2. **Shared Core (Business Logic)**: Python FastAPI Server
3. **External Services**: Google Gemini AI API

---

## 📦 구성 요소 세부 사항

### 1. Shared Core (`server/`)
- **역할**: 모든 클라이언트에서 공통으로 사용하는 '두뇌' 역할.
- **기술**: Python, FastAPI, Google Generative AI (Gemini).
- **기능**:
  - AI 프롬프트 생성 및 응답 파싱 (응급 감지 포함).
  - API Key 등 민감한 정보의 중앙형 관리.

### 2. Mobile App (`mobile/`)
- **역할**: 스마트폰 사용자 전용 UI 레이어.
- **기술**: Flutter, Riverpod.
- **특징**: `ChatRepository`를 통해 공통 API와 통신하며, 모바일 특화 기능(119 카운트다운, 로컬 암호화 저장)을 수행합니다.

### 3. Web Interface (`frontend/`)
- **역할**: 브라우저 기반 상담 UI 레이어.
- **기술**: HTML5, CSS3, Vanilla JavaScript, IndexedDB.
- **특징**:
  - **Persistent Memory**: IndexedDB(`db.js`)를 사용하여 브라우저 종료 후에도 상담 내역 보존.
  - **Summarized Context**: 각 대화 턴을 요약하여 보관함으로써 리포트 생성 시 토큰 효율성 극대화.

---

## 🔒 보안 및 데이터 흐름
1. **입력**: 사용자가 증상을 입력하면 GPS 위치와 함께 서버로 전송됩니다.
2. **처리**: 서버는 AI를 통해 상황을 분석하고, 응급 시 [EMERGENCY] 태그를 붙여 클라이언트에 전달합니다.
3. **저장**: 상담 내용은 각 기기의 로컬 저장소에 안전하게 보관됩니다.
   - **Web**: IndexedDB를 통한 상태 기반(Symptom/Status) 요약 데이터 저장.
   - **Mobile**: Flutter 로컬 저장소 (AES-256 암호화 적용).
