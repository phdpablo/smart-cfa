@echo off
setlocal

REM Resolve Compose relative to this script, regardless of the current directory.
set "COMPOSE_FILE=%~dp0docker-compose.yml"

where docker >nul 2>&1
if errorlevel 1 (
  echo Docker was not found. Install Docker Desktop and open it before running this script.
  goto failed
)

echo Checking Docker Desktop...
docker info >nul 2>&1
if errorlevel 1 (
  echo Docker Desktop is not ready or its Linux engine is unavailable.
  echo Open Docker Desktop, wait for the engine to start, then run start.bat again.
  goto failed
)

if not defined RSTUDIO_IP set "RSTUDIO_IP=127.0.0.1"

echo Starting RStudio...
docker compose -f "%COMPOSE_FILE%" up -d
if errorlevel 1 goto failed

REM Wait for RStudio instead of opening the browser after a fixed delay.
for /l %%i in (1,1,60) do (
  docker compose -f "%COMPOSE_FILE%" exec -T article curl --max-time 2 -fsS -o /dev/null http://127.0.0.1:8787/ >nul 2>&1
  if not errorlevel 1 goto ready
  timeout /t 2 /nobreak >nul
)
echo RStudio did not respond within 120 seconds. Check the container logs:
docker compose -f "%COMPOSE_FILE%" logs --tail 50 article
goto failed

:ready
start "" "http://%RSTUDIO_IP%:8787"
endlocal
exit /b 0

:failed
echo.
echo RStudio could not be started. The error is shown above.
pause
endlocal
exit /b 1
