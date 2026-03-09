@echo off
REM ========================================
REM  Backend Services Startup (No Docker)
REM ========================================

echo Starting all backend services...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Please install Python 3.10+
    pause
    exit /b 1
)

REM Check if Redis is running
echo Checking Redis connection...
redis-cli ping >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Redis not running. Install Redis or use Docker for Redis:
    echo   docker run -d -p 6379:6379 redis:latest
    echo.
)

REM Check if Ollama is running
echo Checking Ollama connection...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Ollama not running. Install from: https://ollama.ai
    echo   Then run: ollama serve
    echo.
)

echo.
echo ========================================
echo Starting services in new windows...
echo ========================================
echo.

REM Start Whisper STT Service
echo [1/4] Starting Whisper STT Service (Port 5001)...
cd /d "%~dp0whisper"
start "Whisper STT" cmd /k "python -m pip install -q -r requirements.txt && python stt.py"

timeout /t 2 >nul

REM Start TTS Service
echo [2/4] Starting TTS Service (Port 5002)...
cd /d "%~dp0tts"
start "TTS Service" cmd /k "python -m pip install -q -r requirements.txt && python tts.py"

timeout /t 2 >nul

REM Start Main API Service
echo [3/4] Starting Main API Service (Port 8000)...
cd /d "%~dp0api"
start "API Service" cmd /k "python -m pip install -q -r requirements.txt && uvicorn main:app --host 0.0.0.0 --port 8000 --reload"

timeout /t 3 >nul

echo [4/4] All services started!
echo.
echo ========================================
echo  Backend Services Running
echo ========================================
echo.
echo  API Server:      http://localhost:8000
echo  API Docs:        http://localhost:8000/docs
echo  Dashboard:       http://localhost:8000/dashboard/
echo  Whisper STT:     http://localhost:5001
echo  TTS:             http://localhost:5002
echo.
echo  [Required External Services]
echo  Ollama:          http://localhost:11434
echo  Redis:           localhost:6379
echo.
echo ========================================
echo  Press any key to open dashboard...
echo ========================================
pause >nul

start http://localhost:8000/dashboard/

echo.
echo Dashboard opened in browser!
echo To stop services, close all service windows.
echo.
pause
