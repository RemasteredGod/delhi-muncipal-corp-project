#!/bin/bash

# ========================================
#  Stop All Backend Services
# ========================================

echo "Stopping all backend services..."
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Read PIDs from files and kill
if [ -f "$SCRIPT_DIR/logs/whisper.pid" ]; then
    WHISPER_PID=$(cat "$SCRIPT_DIR/logs/whisper.pid")
    echo "Stopping Whisper (PID: $WHISPER_PID)..."
    kill $WHISPER_PID 2>/dev/null
    rm "$SCRIPT_DIR/logs/whisper.pid"
fi

if [ -f "$SCRIPT_DIR/logs/tts.pid" ]; then
    TTS_PID=$(cat "$SCRIPT_DIR/logs/tts.pid")
    echo "Stopping TTS (PID: $TTS_PID)..."
    kill $TTS_PID 2>/dev/null
    rm "$SCRIPT_DIR/logs/tts.pid"
fi

if [ -f "$SCRIPT_DIR/logs/api.pid" ]; then
    API_PID=$(cat "$SCRIPT_DIR/logs/api.pid")
    echo "Stopping API (PID: $API_PID)..."
    kill $API_PID 2>/dev/null
    rm "$SCRIPT_DIR/logs/api.pid"
fi

# Also kill by port if still running
echo "Cleaning up any remaining processes..."
lsof -ti:5001 | xargs kill -9 2>/dev/null
lsof -ti:5002 | xargs kill -9 2>/dev/null
lsof -ti:8000 | xargs kill -9 2>/dev/null

echo ""
echo "All services stopped!"
echo ""
