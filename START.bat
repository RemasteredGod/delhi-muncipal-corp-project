@echo off
REM AI Calling Agent - Quick Start Script for Windows
REM Double-click this file to start all services

echo ================================================
echo   AI Calling Agent - Quick Start
echo ================================================
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running!
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)

echo [1/3] Docker is running...
echo.

REM Navigate to ai-calling-agent directory
cd /d "%~dp0ai-calling-agent"

REM Check if .env file exists
if not exist .env (
    echo WARNING: .env file not found!
    echo Creating from .env.example...
    copy .env.example .env
    echo.
    echo Please edit .env file and add your Twilio credentials:
    echo - TWILIO_ACCOUNT_SID
    echo - TWILIO_AUTH_TOKEN
    echo - TWILIO_PHONE_NUMBER
    echo.
    echo Then run this script again.
    pause
    exit /b 1
)

echo [2/3] Starting services...
echo This may take a few minutes on first run...
echo.

REM Start all services
docker compose up -d

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to start services!
    echo Check logs with: docker compose logs
    pause
    exit /b 1
)

echo.
echo [3/3] Services started successfully!
echo.

REM Wait a moment for services to initialize
timeout /t 5 /nobreak >nul

echo ================================================
echo   Services Running
echo ================================================
echo.
echo Backend API:       http://localhost:8000
echo Frontend Dashboard: http://localhost:8000/dashboard/
echo Whisper STT:       http://localhost:5001
echo TTS:               http://localhost:5002
echo Ollama LLM:        http://localhost:11434
echo.
echo ================================================
echo   Next Steps
echo ================================================
echo.
echo 1. Download AI model (first time only):
echo    bash ollama_setup.sh
echo.
echo 2. Start ngrok to expose your server:
echo    ngrok http 8000
echo.
echo 3. Configure Twilio webhook with ngrok URL:
echo    https://your-ngrok-url/twilio/incoming
echo.
echo 4. Open dashboard:
echo    http://localhost:8000/dashboard/
echo.
echo 5. Make a test call to your Twilio number!
echo.
echo ================================================
echo   Useful Commands
echo ================================================
echo.
echo View logs:    docker compose logs -f
echo Stop:         docker compose down
echo Restart:      docker compose restart
echo Status:       docker compose ps
echo.
echo ================================================

REM Ask if user wants to open the dashboard
echo.
set /p OPEN_DASHBOARD="Open dashboard in browser? (y/n): "
if /i "%OPEN_DASHBOARD%"=="y" (
    start http://localhost:8000/dashboard/
)

echo.
echo Press any key to exit...
pause >nul
