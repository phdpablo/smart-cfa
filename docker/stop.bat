@echo off
setlocal

echo Pausing RStudio container...
docker compose -f docker-compose.yml stop

if %ERRORLEVEL% equ 0 (
  echo Container paused. Your data is preserved.
  echo Run 'start.bat' to resume your work.
) else (
  echo Error stopping container.
  exit /b 1
)

endlocal
exit /b 0
