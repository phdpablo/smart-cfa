@echo off
setlocal

echo Starting RStudio...

REM Start/resume container (will resume if paused, create if doesn't exist)
docker compose -f docker-compose.yml up -d

echo Container starting. Waiting about 30 seconds for RStudio to be ready...
timeout /t 30 /nobreak

REM Open the RStudio URL in the default browser
start http://127.0.0.1:8787

endlocal
exit /b 0