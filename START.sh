#!/bin/bash
# AI Calling Agent - Quick Start Script for Linux/Mac
# Run: bash START.sh

echo "================================================"
echo "  AI Calling Agent - Quick Start"
echo "================================================"
echo ""

# Check if Docker is running
if ! docker ps > /dev/null 2>&1; then
    echo "❌ ERROR: Docker is not running!"
    echo "Please start Docker and try again."
    echo ""
    exit 1
fi

echo "✅ [1/3] Docker is running..."
echo ""

# Navigate to ai-calling-agent directory
cd "$(dirname "$0")/ai-calling-agent" || exit 1

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  WARNING: .env file not found!"
    echo "Creating from .env.example..."
    cp .env.example .env
    echo ""
    echo "Please edit .env file and add your Twilio credentials:"
    echo "- TWILIO_ACCOUNT_SID"
    echo "- TWILIO_AUTH_TOKEN"
    echo "- TWILIO_PHONE_NUMBER"
    echo ""
    echo "Then run this script again."
    echo ""
    exit 1
fi

echo "✅ [2/3] Starting services..."
echo "This may take a few minutes on first run..."
echo ""

# Start all services
docker compose up -d

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ ERROR: Failed to start services!"
    echo "Check logs with: docker compose logs"
    exit 1
fi

echo ""
echo "✅ [3/3] Services started successfully!"
echo ""

# Wait a moment for services to initialize
sleep 5

echo "================================================"
echo "  Services Running"
echo "================================================"
echo ""
echo "Backend API:        http://localhost:8000"
echo "Frontend Dashboard: http://localhost:8000/dashboard/"
echo "Whisper STT:        http://localhost:5001"
echo "TTS:                http://localhost:5002"
echo "Ollama LLM:         http://localhost:11434"
echo ""
echo "================================================"
echo "  Next Steps"
echo "================================================"
echo ""
echo "1. Download AI model (first time only):"
echo "   bash ollama_setup.sh"
echo ""
echo "2. Start ngrok to expose your server:"
echo "   ngrok http 8000"
echo ""
echo "3. Configure Twilio webhook with ngrok URL:"
echo "   https://your-ngrok-url/twilio/incoming"
echo ""
echo "4. Open dashboard:"
echo "   http://localhost:8000/dashboard/"
echo ""
echo "5. Make a test call to your Twilio number!"
echo ""
echo "================================================"
echo "  Useful Commands"
echo "================================================"
echo ""
echo "View logs:    docker compose logs -f"
echo "Stop:         docker compose down"
echo "Restart:      docker compose restart"
echo "Status:       docker compose ps"
echo ""
echo "================================================"
echo ""

# Ask if user wants to open the dashboard
read -p "Open dashboard in browser? (y/n): " OPEN_DASHBOARD
if [ "$OPEN_DASHBOARD" = "y" ] || [ "$OPEN_DASHBOARD" = "Y" ]; then
    # Detect OS and open browser
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open http://localhost:8000/dashboard/
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        xdg-open http://localhost:8000/dashboard/ 2>/dev/null || echo "Please open http://localhost:8000/dashboard/ in your browser"
    fi
fi

echo ""
echo "✅ Setup complete! Your AI Calling Agent is running."
echo ""
