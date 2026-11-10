@echo off
setlocal
where docker >nul 2>&1
if errorlevel 1 goto failed
docker info >nul 2>&1
if errorlevel 1 goto failed
docker compose version >nul 2>&1
if errorlevel 1 goto failed
if not exist "%~dp0..\docs" mkdir "%~dp0..\docs"
if errorlevel 1 goto failed
docker compose -f "%~dp0docker-compose.yml" run --rm --no-deps --pull missing audit
if errorlevel 1 goto failed
echo Results exported to the project's docs folder.
exit /b 0
:failed
echo Audit failed. Check the error above and ensure Docker Desktop is running.
exit /b 1
