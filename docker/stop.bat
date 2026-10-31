@echo off
setlocal

REM Stop without removing the container or its files.
docker compose -f "%~dp0docker-compose.yml" stop
if errorlevel 1 (
  echo Could not stop the container. Check Docker Desktop.
  pause
  exit /b 1
)

echo Container stopped. Files remain in this container until it is removed or recreated.
echo Run start.bat to start it again.
endlocal
exit /b 0
