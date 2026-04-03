# --- [STAGE 1] Build Frontend (Flutter Web) ---
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .
WORKDIR /app/lifeand_care_app
RUN flutter pub get --no-analytics
RUN flutter build web --release --base-href / --web-renderer canvaskit --no-tree-shake-icons

# --- [STAGE 2] Assemble Production Image (FastAPI + Static Web) ---
FROM python:3.11-slim

WORKDIR /app
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# [DEPENDENCIES] Install Backend Core
COPY backend-module/requirements.txt ./
RUN pip install --no-cache-dir -r backend-module/requirements.txt

# [ARTEFACT-SYNC] Import build results from the BUILD stage
# Path: /app/lifeand_care_app/build/web (Matches main.py's expected directory)
COPY --from=build /app/lifeand_care_app/build/web /app/lifeand_care_app/build/web

# [SOURCE-SYNC] Copy backend business logic
COPY backend-module /app/backend-module

# [NETWORK] Expose and Launch
EXPOSE 8000
CMD ["uvicorn", "backend-module.main:app", "--host", "0.0.0.0", "--port", "8000"]
