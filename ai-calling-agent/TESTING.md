# 🧪 Testing Guide

Comprehensive testing guide for the AI Calling Agent system.

---

## Pre-Testing Checklist

Before running tests, ensure:

- ✅ All Docker containers are running: `docker compose ps`
- ✅ Mistral model is downloaded: `bash ollama_setup.sh`
- ✅ ngrok tunnel is active (for Twilio testing)
- ✅ Twilio webhook is configured correctly

---

## Unit Tests

### Test 1: Service Health Checks

Test if all services are responding:

```bash
# Test API (should return {"status": "AI Calling Agent is running"})
curl http://localhost:8000/

# Test Whisper STT (should return {"status": "Whisper STT service running"})
curl http://localhost:5001/

# Test TTS (should return {"status": "TTS service running"})
curl http://localhost:5002/

# Test Redis
docker exec -it <redis-container-id> redis-cli ping
# Expected: PONG
```

### Test 2: Whisper Speech-to-Text

Test transcription with a sample audio file:

```bash
# Download a sample audio file
curl -o test.mp3 https://www2.cs.uic.edu/~i101/SoundFiles/CantinaBand3.wav

# Test transcription
curl -X POST http://localhost:5001/transcribe \
  -H "Content-Type: application/json" \
  -d '{"audio_url": "https://www2.cs.uic.edu/~i101/SoundFiles/preamble.wav"}'

# Expected: {"text": "transcribed text here"}
```

### Test 3: Text-to-Speech

Test TTS generation:

```bash
# Generate speech
curl -X POST http://localhost:5002/speak \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, this is a test of the text to speech system."}'

# Expected: {"audio_file": "/tmp/tts_output/response_xxxxx.wav"}
```

### Test 4: LLM Generation

Test Ollama LLM:

```bash
# Generate text
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistral",
    "prompt": "Hello, how are you?",
    "stream": false
  }'

# Expected: {"model": "mistral", "response": "AI response here"}
```

### Test 5: Redis Storage

Test Redis data persistence:

```bash
# Store data
docker exec -it <redis-container-id> redis-cli SET test_key "test_value"

# Retrieve data
docker exec -it <redis-container-id> redis-cli GET test_key
# Expected: "test_value"

# List all keys
docker exec -it <redis-container-id> redis-cli KEYS "*"
```

---

## Integration Tests

### Test 6: Dashboard API Endpoints

```bash
# Get all calls
curl http://localhost:8000/calls

# Expected: {"active_calls": 0, "calls": []}

# Get specific call (replace with actual call_sid)
curl http://localhost:8000/calls/CA1234567890abcdef

# Expected: {"call_sid": "...", "conversation": [...]}
```

### Test 7: Simulated Call Flow

Simulate a complete call flow:

```bash
# Step 1: Create a test audio URL
TEST_AUDIO_URL="https://www2.cs.uic.edu/~i101/SoundFiles/preamble.wav"

# Step 2: Test the full processing pipeline
curl -X POST "http://localhost:8000/process?audio_url=$TEST_AUDIO_URL"

# This should:
# 1. Download the audio
# 2. Transcribe it with Whisper
# 3. Generate LLM response
# 4. Convert response to speech
# 5. Return audio file path
```

### Test 8: Dashboard Functionality

1. Open browser to: http://localhost:8000/dashboard/
2. Click "Refresh" button - should show "Active Calls: 0"
3. Toggle "Auto-Refresh" - button should change to "ON"
4. Verify system status shows green dot (●)

---

## End-to-End Tests

### Test 9: Live Phone Call Test

This is the ultimate test of the entire system:

1. **Make a call** to your Twilio number
2. **Wait for greeting**: "Hello. Welcome to Delhi Municipal Corporation..."
3. **Speak after beep**: "Hello, I need help"
4. **Wait for AI response**: Should respond naturally
5. **Continue conversation**: Have a 2-3 turn conversation
6. **Hang up**

**Expected Flow:**

```
You: "Hello"
AI: "Hello! How can I assist you today?"

You: "I want to file a complaint"
AI: "I'm sorry to hear that. Could you please describe the issue?"

You: "My water supply is not working"
AI: "Thank you. I have registered your complaint..."
```

### Test 10: Multiple Concurrent Calls

Test system capacity:

1. Have 2-3 people call simultaneously
2. Check dashboard shows multiple active calls
3. Verify each call maintains separate conversation history
4. Monitor system performance with `docker stats`

---

## Performance Tests

### Test 11: Response Time Test

Measure end-to-end latency:

```bash
# Use time command to measure
time curl -X POST "http://localhost:8000/process?audio_url=https://www2.cs.uic.edu/~i101/SoundFiles/preamble.wav"

# Target: 2-4 seconds total
# Breakdown:
# - STT: ~1-2s
# - LLM: ~1s
# - TTS: <1s
```

### Test 12: Load Test

Test with multiple concurrent requests:

```bash
# Install Apache Bench (ab)
# On Windows: included with Apache
# On Linux: sudo apt install apache2-utils

# Run 50 requests with 5 concurrent
ab -n 50 -c 5 http://localhost:8000/

# Monitor with:
docker stats
```

### Test 13: Memory Usage Test

Monitor resource usage during operation:

```bash
# Watch container stats
docker stats --no-stream

# Expected ranges:
# - API: 100-200MB
# - Whisper: 1-2GB (model loaded)
# - TTS: 500MB-1GB
# - Ollama: 3-5GB (model loaded)
# - Redis: 10-50MB
```

---

## Error Handling Tests

### Test 14: Invalid Audio URL

```bash
curl -X POST http://localhost:5001/transcribe \
  -H "Content-Type: application/json" \
  -d '{"audio_url": "https://invalid.url/notfound.mp3"}'

# Should handle gracefully with error message
```

### Test 15: Service Failure Simulation

Test resilience:

```bash
# Stop Whisper service
docker compose stop whisper

# Try to process audio
curl -X POST "http://localhost:8000/process?audio_url=..."

# Should show connection error

# Restart service
docker compose start whisper
```

### Test 16: Redis Failure

```bash
# Stop Redis
docker compose stop redis

# Make a call - should still work but without history

# Restart Redis
docker compose start redis
```

---

## Test Data

### Sample Audio URLs for Testing

```
# Short greeting (English)
https://www2.cs.uic.edu/~i101/SoundFiles/preamble.wav

# Medium length
https://www2.cs.uic.edu/~i101/SoundFiles/gettysburg10.wav

# Background noise test
# (upload your own test files)
```

### Sample Conversation Scripts

**Script 1: Basic Query**

```
User: Hello
AI: Hello! How can I assist you today?
User: What is your service?
AI: I'm an AI assistant for Delhi Municipal Corporation...
```

**Script 2: Complaint Filing**

```
User: I want to file a complaint
AI: I'm sorry to hear that. Could you describe the issue?
User: Water supply problem
AI: Thank you for reporting...
```

**Script 3: Information Request**

```
User: How do I pay property tax?
AI: You can pay property tax online...
```

---

## Monitoring Commands

### View Real-Time Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f whisper
docker compose logs -f tts
docker compose logs -f ollama

# Last 50 lines
docker compose logs --tail=50 api
```

### Check Container Health

```bash
# List all containers
docker compose ps

# Inspect specific container
docker inspect <container-id>

# Check resource usage
docker stats
```

### Check Redis Data

```bash
# Connect to Redis CLI
docker exec -it <redis-container-id> redis-cli

# Inside Redis CLI:
KEYS call:*              # List all call keys
LRANGE call:CAxxxx 0 -1  # View conversation history
FLUSHALL                 # Clear all data (careful!)
```

---

## Automated Test Script

Create a test script `test.sh`:

```bash
#!/bin/bash

echo "Running AI Calling Agent Tests..."

# Test 1: Health checks
echo "Test 1: Health checks"
curl -s http://localhost:8000/ | grep "status" && echo "✓ API OK" || echo "✗ API FAILED"
curl -s http://localhost:5001/ | grep "status" && echo "✓ Whisper OK" || echo "✗ Whisper FAILED"
curl -s http://localhost:5002/ | grep "status" && echo "✓ TTS OK" || echo "✗ TTS FAILED"

# Test 2: Dashboard
echo "Test 2: Dashboard"
curl -s http://localhost:8000/dashboard/ | grep "AI Calling Agent" && echo "✓ Dashboard OK" || echo "✗ Dashboard FAILED"

# Test 3: Calls API
echo "Test 3: Calls API"
curl -s http://localhost:8000/calls | grep "active_calls" && echo "✓ Calls API OK" || echo "✗ Calls API FAILED"

echo "Tests complete!"
```

Make it executable: `chmod +x test.sh`

Run it: `./test.sh`

---

## Troubleshooting Test Failures

### If health checks fail:

1. Check if containers are running: `docker compose ps`
2. Check logs: `docker compose logs`
3. Restart services: `docker compose restart`

### If Whisper fails:

1. Check if ffmpeg is installed in container
2. Verify audio URL is accessible
3. Try with different audio format

### If LLM fails:

1. Verify Mistral model is downloaded
2. Check Ollama logs: `docker compose logs ollama`
3. Try pulling model again: `bash ollama_setup.sh`

### If calls don't show in dashboard:

1. Verify Redis is running
2. Check browser console for errors
3. Verify API CORS is enabled
4. Try refreshing with auto-refresh enabled

---

## Success Criteria

A successful test should demonstrate:

✅ All services respond to health checks
✅ Whisper transcribes audio correctly
✅ LLM generates appropriate responses
✅ TTS produces audible speech
✅ Phone calls connect and respond
✅ Dashboard shows active calls
✅ Conversation history stored in Redis
✅ Response time under 5 seconds
✅ System handles 1-5 concurrent calls

---

## Reporting Issues

When reporting bugs, include:

1. Test that failed
2. Expected behavior
3. Actual behavior
4. Docker logs: `docker compose logs > logs.txt`
5. System specs (CPU, RAM)
6. Steps to reproduce

---

**Remember:** Run tests in sequence, not all at once!

Good luck testing! 🧪
