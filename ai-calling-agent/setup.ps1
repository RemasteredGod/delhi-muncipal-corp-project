#!/usr/bin/env pwsh
# AI Calling Agent - Windows Setup Script
# Run this script to automatically set up the entire system

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  AI Calling Agent - Automatic Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Docker
if (Test-Command docker) {
    Write-Host "✓ Docker is installed" -ForegroundColor Green
} else {
    Write-Host "✗ Docker is NOT installed" -ForegroundColor Red
    Write-Host "  Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Check if Docker is running
try {
    docker ps | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is NOT running" -ForegroundColor Red
    Write-Host "  Please start Docker Desktop" -ForegroundColor Yellow
    exit 1
}

# Check .env file
if (Test-Path .env) {
    Write-Host "✓ .env file exists" -ForegroundColor Green
} else {
    Write-Host "⚠ .env file not found" -ForegroundColor Yellow
    Write-Host "  Creating .env from .env.example..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "  Please edit .env and add your Twilio credentials" -ForegroundColor Yellow
    Write-Host "  Then run this script again" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Step 1: Building Docker containers" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "This may take 5-10 minutes on first run..." -ForegroundColor Yellow
Write-Host ""

docker compose up --build -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to start containers" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Containers started successfully" -ForegroundColor Green
Write-Host ""

# Wait for services to initialize
Write-Host "Waiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Step 2: Downloading AI Model (Mistral)" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "This will download ~4GB. Please be patient..." -ForegroundColor Yellow
Write-Host ""

# Get Ollama container ID
$ollamaContainer = docker ps --filter "ancestor=ollama/ollama" --format "{{.ID}}" | Select-Object -First 1

if (-not $ollamaContainer) {
    Write-Host "✗ Ollama container not found" -ForegroundColor Red
    Write-Host "  Please check if all containers are running: docker compose ps" -ForegroundColor Yellow
    exit 1
}

Write-Host "Pulling Mistral model..." -ForegroundColor Yellow
docker exec $ollamaContainer ollama pull mistral

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Mistral model downloaded successfully" -ForegroundColor Green
} else {
    Write-Host "⚠ Failed to download Mistral model" -ForegroundColor Yellow
    Write-Host "  You can try again later with: bash ollama_setup.sh" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Step 3: Testing Services" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Test API
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ API service is running (port 8000)" -ForegroundColor Green
} catch {
    Write-Host "✗ API service is not responding" -ForegroundColor Red
}

# Test Whisper
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5001/" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Whisper service is running (port 5001)" -ForegroundColor Green
} catch {
    Write-Host "✗ Whisper service is not responding" -ForegroundColor Red
}

# Test TTS
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5002/" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ TTS service is running (port 5002)" -ForegroundColor Green
} catch {
    Write-Host "✗ TTS service is not responding" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Step 4: Setting up ngrok tunnel" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Command ngrok) {
    Write-Host "✓ ngrok is installed" -ForegroundColor Green
    Write-Host ""
    Write-Host "Starting ngrok tunnel..." -ForegroundColor Yellow
    Write-Host "NOTE: ngrok will run in a new window" -ForegroundColor Yellow
    Write-Host ""
    
    # Start ngrok in a new window
    Start-Process -FilePath "ngrok" -ArgumentList "http", "8000"
    
    Start-Sleep -Seconds 3
    
    try {
        $ngrokResponse = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -TimeoutSec 5
        $publicUrl = $ngrokResponse.tunnels[0].public_url
        
        Write-Host "✓ ngrok tunnel is active" -ForegroundColor Green
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Green
        Write-Host "  Your Webhook URL:" -ForegroundColor Green
        Write-Host "  $publicUrl/twilio/incoming" -ForegroundColor Cyan
        Write-Host "================================================" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "⚠ Could not get ngrok URL automatically" -ForegroundColor Yellow
        Write-Host "  Check ngrok dashboard: http://localhost:4040" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ ngrok is not installed" -ForegroundColor Yellow
    Write-Host "  Download from: https://ngrok.com/download" -ForegroundColor Yellow
    Write-Host "  Or manually expose port 8000 to the internet" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Copy your webhook URL (shown above)" -ForegroundColor White
Write-Host "2. Go to Twilio Console: https://console.twilio.com" -ForegroundColor White
Write-Host "3. Configure your phone number with the webhook URL" -ForegroundColor White
Write-Host "4. Make a test call to your Twilio number" -ForegroundColor White
Write-Host "5. View dashboard: http://localhost:8000/dashboard/" -ForegroundColor White
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Yellow
Write-Host "  View logs:       docker compose logs -f" -ForegroundColor White
Write-Host "  Stop services:   docker compose down" -ForegroundColor White
Write-Host "  Restart:         docker compose restart" -ForegroundColor White
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  README.md       - Full documentation" -ForegroundColor White
Write-Host "  QUICKSTART.md   - Quick reference guide" -ForegroundColor White
Write-Host ""
Write-Host "Happy calling! 🎉" -ForegroundColor Green
