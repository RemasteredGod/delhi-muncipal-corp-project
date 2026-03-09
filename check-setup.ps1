#!/usr/bin/env pwsh
# Outbound Calling Setup Checker

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   Outbound Calling Setup Checker" -ForegroundColor White
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: API Server
Write-Host "1. Checking API Server..." -ForegroundColor Yellow
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:8000/" -UseBasicParsing -TimeoutSec 3
    if ($apiResponse.StatusCode -eq 200) {
        Write-Host "   [OK] API Server is running on port 8000" -ForegroundColor Green
    }
} catch {
    Write-Host "   [ERROR] API Server not responding on port 8000" -ForegroundColor Red
    Write-Host "      Run: cd ai-calling-agent/api ; python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload" -ForegroundColor Gray
    $allGood = $false
}

# Check 2: BASE_URL Environment Variable
Write-Host ""
Write-Host "2. Checking BASE_URL..." -ForegroundColor Yellow
$baseUrl = $env:BASE_URL
if ($baseUrl) {
    Write-Host "   [OK] BASE_URL is set: $baseUrl" -ForegroundColor Green
    
    if ($baseUrl -match "localhost" -or $baseUrl -match "127\.0\.0\.1") {
        Write-Host "   [ERROR] BASE_URL is localhost - Twilio needs a public URL!" -ForegroundColor Red
        Write-Host "      You need ngrok! See SETUP_NGROK.md" -ForegroundColor Gray
        $allGood = $false
    } elseif ($baseUrl -match "ngrok") {
        Write-Host "   [OK] ngrok URL detected!" -ForegroundColor Green
    } else {
        Write-Host "   [INFO] Custom URL: $baseUrl" -ForegroundColor Cyan
    }
} else {
    Write-Host "   [ERROR] BASE_URL not set" -ForegroundColor Red
    Write-Host "      1. Start ngrok: ngrok http 8000" -ForegroundColor Gray
    Write-Host "      2. Set: `$env:BASE_URL='https://your-url.ngrok.io'" -ForegroundColor Gray
    Write-Host "      3. See: SETUP_NGROK.md for details" -ForegroundColor Gray
    $allGood = $false
}

# Check 3: Dashboard
Write-Host ""
Write-Host "3. Checking Dashboard..." -ForegroundColor Yellow
try {
    $dashboardResponse = Invoke-WebRequest -Uri "http://localhost:8000/dashboard/" -UseBasicParsing -TimeoutSec 3
    if ($dashboardResponse.StatusCode -eq 200 -and $dashboardResponse.Content -match "call-button") {
        Write-Host "   [OK] Dashboard is accessible with call button" -ForegroundColor Green
    }
} catch {
    Write-Host "   [ERROR] Dashboard not accessible" -ForegroundColor Red
    $allGood = $false
}

# Final Summary
Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "   ALL SYSTEMS GO!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[OK] You're ready to make outbound calls!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "   1. Open: http://localhost:8000/dashboard/" -ForegroundColor Cyan
    Write-Host "   2. Click 'Call Now' button" -ForegroundColor Cyan
    Write-Host "   3. Watch real-time updates!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Opening dashboard..." -ForegroundColor Magenta
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:8000/dashboard/"
} else {
    Write-Host "   SETUP INCOMPLETE" -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Action items above show what needs fixing." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Helpful docs:" -ForegroundColor Cyan
    Write-Host "   - SETUP_NGROK.md - ngrok setup guide" -ForegroundColor White
    Write-Host "   - OUTBOUND_CALLING_GUIDE.md - complete guide" -ForegroundColor White
    Write-Host "   - START.md - basic setup" -ForegroundColor White
}

Write-Host ""
