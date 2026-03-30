# 🏛️ Life & Care - Target Clean Architecture

본 문서는 프로젝트의 지속 가능한 확장과 유지보수를 위해 지향해야 할 **최종 백엔드 아키텍처** 구조를 정의합니다. 현재의 평면적(Flat) 구조에서 계층화된(Layered) 구조로의 전환을 목표로 합니다.

---

## 📂 최종 목표 디렉토리 구조

```text
backend/
├── app/
│   ├── api/            # 외부 인터페이스 계층 (Routes, Controllers)
│   │   ├── endpoints/  # 각 도메인별 API 라우트 (chat.py, maps.py 등)
│   │   └── deps.py     # 의존성 주입 (Dependency Injection)
│   ├── core/           # 시스템 핵심 설정 (Config, Security, Logging)
│   ├── models/         # 데이터 스키마 (Pydantic Models, DTOs)
│   ├── services/       # 비즈니스 로직 계층 (AI Logic, Map Logic)
│   └── main.py         # 애플리케이션 진입점 (FastAPI 인스턴스 초기화)
├── scripts/            # 유틸리티 및 관리를 위한 독립 실행 스크립트
├── tests/              # 단위 테스트 및 통합 테스트 코드
├── .env                # 환경 변수 (Secret Keys)
├── requirements.txt    # 의존성 패키지 관리
└── .gitignore          # Git 추적 제외 설정
```

---

## 🛠️ 계층별 역할 정의

### 1. API 계층 (`app/api/`)
-   사용자의 요청을 받고 응답을 반환하는 유효성 검사 및 라우팅 담당.
-   **Rule**: 비즈니스 로직을 직접 포함하지 않으며, `services` 계층을 호출합니다.

### 2. 비즈니스 서비스 계층 (`app/services/`)
-   프로젝트의 핵심 로직(Gemini AI 프롬프트 구성, 병원 데이터 가공 등) 수행.
-   **Rule**: 도메인 모델과 데이터 소스 간의 가교 역할을 하며, 특정 프레임워크(FastAPI 등)에 종속되지 않는 작성이 권장됩니다.

### 3. 데이터 모델 계층 (`app/models/`)
-   API 요청/응답 형식과 내부 데이터 구조를 정의합니다 (Pydantic 사용).
-   **Rule**: 데이터의 '모양'을 정의하며, 로직은 포함하지 않습니다.

### 4. 핵심 설정 계층 (`app/core/`)
-   `.env` 로드, 전역 상수 선언, 보안 설정 등을 관리합니다.

---

## 🌟 왜 이 구조로 가야 하는가?

1.  **관심사 분리 (Separation of Concerns)**: 코드의 위치가 명확해져 유지보수가 쉬워집니다.
2.  **테스트 용이성**: 비즈니스 로직(`services`)이 독립되어 있어 단위 테스트 작성이 매우 쉬워집니다.
3.  **확장성**: 새로운 기능(예: 결제, 회원관리 등)이 추가될 때 기존 코드에 영향을 주지 않고 폴더 단위로 확장이 가능합니다.
4.  **클린 코드**: `main.py`가 비대해지는 'God Object' 현상을 방지합니다.

---

> [!TIP]
> **전환 가이드**: 새로운 기능을 추가할 때마다 이 구조를 하나씩 적용해 보세요. `main.py`에 있는 함수를 `services/`로 옮기고, 라우트는 `api/`로 분리하는 것부터 시작할 수 있습니다.
