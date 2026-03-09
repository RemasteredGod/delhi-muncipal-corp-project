@echo off
REM ========================================
REM  Stop All Backend Services
REM ========================================

echo Stopping all backend services...
echo.

REM Kill processes by window title
taskkill /FI "WindowTitle eq Whisper STT*" /F >nul 2>&1
taskkill /FI "WindowTitle eq TTS Service*" /F >nul 2>&1
taskkill /FI "WindowTitle eq API Service*" /F >nul 2>&1

REM Also kill by port if still running
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5001" ^| findstr "LISTENING"') do taskkill /F /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5002" ^| findstr "LISTENING"') do taskkill /F /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8000" ^| findstr "LISTENING"') do taskkill /F /PID %%a >nul 2>&1

echo.
echo All services stopped!
echo.
pause
