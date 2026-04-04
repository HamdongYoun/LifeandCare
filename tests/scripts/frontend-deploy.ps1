# Life & Care - Production Deployment Script
# 1. Flutter Build (Web / CanvasKit)
cd lifeand_care_app
flutter build web --release --no-tree-shake-icons --web-renderer canvaskit
cd ..

# 2. Docker Image Creation
docker build -t lifeand_care_app:latest .

# 3. GitHub Source Synchronization
git add .
git commit --amend --no-edit
git push origin main --force

Write-Host "🚀 Deployment Successful! Naver Map Edition updated." -ForegroundColor Green
