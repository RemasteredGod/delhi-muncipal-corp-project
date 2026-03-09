#!/bin/bash

# ========================================
#  Backend Services Startup (No Docker)
# ========================================

echo "Starting all backend services..."
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python3 not found. Please install Python 3.10+"
    exit 1
fi

# Check if Redis is running
echo "Checking Redis connection..."
if ! redis-cli ping &> /dev/null; then
    echo "[WARNING] Redis not running. Install Redis or use Docker for Redis:"
    echo "  docker run -d -p 6379:6379 redis:latest"
    echo ""
fi

# Check if Ollama is running
echo "Checking Ollama connection..."
if ! curl -s http://localhost:11434/api/tags &> /dev/null; then
    echo "[WARNING] Ollama not running. Install from: https://ollama.ai"
    echo "  Then run: ollama serve"
    echo ""
fi

echo ""
echo "========================================"
echo "Starting services in background..."
echo "========================================"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start Whisper STT Service
echo "[1/4] Starting Whisper STT Service (Port 5001)..."
cd "$SCRIPT_DIR/whisper"
python3 -m pip install -q -r requirements.txt
nohup python3 stt.py > ../logs/whisper.log 2>&1 &
WHISPER_PID=$!
echo "  PID: $WHISPER_PID"

sleep 2

# Start TTS Service
echo "[2/4] Starting TTS Service (Port 5002)..."
cd "$SCRIPT_DIR/tts"
python3 -m pip install -q -r requirements.txt
nohup python3 tts.py > ../logs/tts.log 2>&1 &
TTS_PID=$!
echo "  PID: $TTS_PID"

sleep 2

# Start Main API Service
echo "[3/4] Starting Main API Service (Port 8000)..."
cd "$SCRIPT_DIR/api"
python3 -m pip install -q -r requirements.txt
nohup uvicorn main:app --host 0.0.0.0 --port 8000 --reload > ../logs/api.log 2>&1 &
API_PID=$!
echo "  PID: $API_PID"

sleep 3

echo "[4/4] All services started!"
echo ""
echo "========================================"
echo " Backend Services Running"
echo "========================================"
echo ""
echo " API Server:      http://localhost:8000"
echo " API Docs:        http://localhost:8000/docs"
echo " Dashboard:       http://localhost:8000/dashboard/"
echo " Whisper STT:     http://localhost:5001"
echo " TTS:             http://localhost:5002"
echo ""
echo " [Required External Services]"
echo " Ollama:          http://localhost:11434"
echo " Redis:           localhost:6379"
echo ""
echo " [Process IDs]"
echo " Whisper PID:     $WHISPER_PID"
echo " TTS PID:         $TTS_PID"
echo " API PID:         $API_PID"
echo ""
echo "========================================"
echo " Logs saved to: $SCRIPT_DIR/logs/"
echo "========================================"
echo ""
echo "To stop all services:"
echo "  kill $WHISPER_PID $TTS_PID $API_PID"
echo ""

# Save PIDs to file for easy cleanup
echo $WHISPER_PID > "$SCRIPT_DIR/logs/whisper.pid"
echo $TTS_PID > "$SCRIPT_DIR/logs/tts.pid"
echo $API_PID > "$SCRIPT_DIR/logs/api.pid"

echo "Opening dashboard in browser..."
sleep 2

# Open browser (works on Linux and macOS)
if command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:8000/dashboard/
elif command -v open &> /dev/null; then
    open http://localhost:8000/dashboard/
else
    echo "Please open http://localhost:8000/dashboard/ in your browser"
fi

echo ""
echo "Services running! Press Ctrl+C when done."
echo ""

# Keep script running
tail -f "$SCRIPT_DIR/logs/api.log"
