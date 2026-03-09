@echo off
REM ========================================
REM  Ollama Model Setup (Windows)
REM ========================================
REM Run this ONCE after "docker compose up" to download the Mistral AI model

echo.
echo ========================================
echo  Ollama Model Setup
echo ========================================
echo.

REM Find Ollama container ID
echo Checking for Ollama container...
for /f "tokens=*" %%i in ('docker ps --filter "ancestor=ollama/ollama" --format "{{.ID}}"') do set CONTAINER=%%i

if "%CONTAINER%"=="" (
    echo [ERROR] Ollama container is not running!
    echo.
    echo Please start it first with:
    echo   docker compose up -d
    echo.
    pause
    exit /b 1
)

echo Found container: %CONTAINER%
echo.
echo Downloading Mistral model (this may take a few minutes)...
echo.

REM Pull the mistral model
docker exec -it %CONTAINER% ollama pull mistral

echo.
echo ========================================
echo  Done! Mistral model is ready.
echo ========================================
echo.
echo You can now make calls and the AI will respond.
echo.
pause
