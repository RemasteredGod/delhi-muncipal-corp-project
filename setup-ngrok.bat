@echo off
REM ngrok Setup Helper Script
echo.
echo =====================================================
echo          NGROK AUTHENTICATION SETUP
echo =====================================================
echo.
echo STEP 1: Sign up for FREE ngrok account
echo         https://dashboard.ngrok.com/signup
echo.
echo STEP 2: Copy your authtoken from:
echo         https://dashboard.ngrok.com/get-started/your-authtoken
echo.
echo STEP 3: Paste your token below and press ENTER
echo.
set /p AUTHTOKEN="Enter your ngrok authtoken: "

if "%AUTHTOKEN%"=="" (
    echo.
    echo ERROR: No token provided!
    pause
    exit /b 1
)

echo.
echo Configuring ngrok with your authtoken...
ngrok config add-authtoken %AUTHTOKEN%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =====================================================
    echo    SUCCESS! ngrok is now configured!
    echo =====================================================
    echo.
    echo Next step: Start ngrok
    echo   Command: ngrok http 8000
    echo.
    echo Then copy the URL and set it:
    echo   $env:BASE_URL='https://your-url.ngrok.io'
    echo.
    pause
) else (
    echo.
    echo ERROR: Failed to configure ngrok!
    echo Make sure ngrok is installed and in your PATH
    pause
    exit /b 1
)
