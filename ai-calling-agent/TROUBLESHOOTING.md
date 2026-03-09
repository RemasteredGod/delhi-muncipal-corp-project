# 🔧 Troubleshooting Guide

Complete troubleshooting guide for the AI Calling Agent system.

---

## Quick Diagnostics

Run these commands first to identify the issue:

```bash
# Check if all containers are running
docker compose ps

# Check logs for errors
docker compose logs --tail=50

# Check system resources
docker stats --no-stream

# Test API endpoint
curl http://localhost:8000/
```

---

## Common Issues

### ❌ Issue 1: Docker Compose Won't Start

**Symptoms:**

- `docker compose up` fails
- Containers exit immediately
- Port already in use errors

**Solutions:**

**A. Port Conflicts**

```bash
# Check what's using the port
netstat -ano | findstr :8000    # Windows
lsof -i :8000                   # Linux/Mac

# Kill the process or change port in docker-compose.yml
```

**B. Docker Not Running**

```bash
# Windows: Start Docker Desktop
# Linux:
sudo systemctl start docker
sudo systemctl enable docker
```

**C. Insufficient Resources**

```bash
# Increase Docker memory in Docker Desktop settings
# Recommended: 8GB+ RAM, 4+ CPUs
```

**D. Corrupted Containers**

```bash
docker compose down -v
docker system prune -a
docker compose up --build -d
```

---

### ❌ Issue 2: Ollama Model Not Found

**Symptoms:**

- API returns "model not found"
- LLM responses fail
- Ollama logs show "model 'mistral' not found"

**Solutions:**

**A. Pull the Model**

```bash
bash ollama_setup.sh

# Or manually:
CONTAINER=$(docker ps --filter "ancestor=ollama/ollama" --format "{{.ID}}" | head -n1)
docker exec -it $CONTAINER ollama pull mistral
```

**B. Check Available Models**

```bash
docker exec -it $CONTAINER ollama list
```

**C. Try Different Model**

```bash
# Pull alternative model
docker exec -it $CONTAINER ollama pull llama3

# Update api/main.py to use it:
"model": "llama3"
```

---

### ❌ Issue 3: Whisper Transcription Fails

**Symptoms:**

- Empty transcriptions
- 500 Internal Server Error
- "ffmpeg not found"

**Solutions:**

**A. Check Whisper Service**

```bash
# Test health
curl http://localhost:5001/

# Check logs
docker compose logs whisper
```

**B. FFmpeg Missing**

```bash
# Rebuild with ffmpeg
docker compose up --build whisper -d
```

**C. Audio Format Issues**

```bash
# Whisper supports: mp3, wav, m4a, flac
# Ensure audio URL is accessible
curl -I "your-audio-url.mp3"
```

**D. Model Download Failed**

```bash
# Whisper downloads model on first run
# Check if download completed:
docker compose logs whisper | grep "load"

# Retry:
docker compose restart whisper
```

---

### ❌ Issue 4: TTS Not Generating Audio

**Symptoms:**

- No audio file returned
- TTS service crashes
- "espeak-ng" errors

**Solutions:**

**A. Check TTS Service**

```bash
curl http://localhost:5002/

# Test generation
curl -X POST http://localhost:5002/speak \
  -H "Content-Type: application/json" \
  -d '{"text": "Test"}'
```

**B. espeak-ng Missing**

```bash
# Rebuild TTS container
docker compose up --build tts -d
```

**C. Out of Memory**

```bash
# Check container memory
docker stats tts

# Increase Docker memory limit
# Edit docker-compose.yml:
services:
  tts:
    deploy:
      resources:
        limits:
          memory: 2G
```

**D. Model Download Failed**

```bash
# Clear and retry
docker compose down tts
docker volume rm ai-calling-agent_tts_models
docker compose up tts -d
```

---

### ❌ Issue 5: Twilio Webhook Not Working

**Symptoms:**

- Calls don't reach the system
- Twilio shows "11200 HTTP retrieval failure"
- No logs when calling

**Solutions:**

**A. Check Webhook URL**

```bash
# Verify API is accessible
curl http://your-server.com/twilio/incoming

# Should return TwiML XML
```

**B. ngrok Issues (Local Development)**

```bash
# Restart ngrok
pkill ngrok
ngrok http 8000

# Use HTTPS URL from ngrok
# Update Twilio webhook to: https://xyz.ngrok.io/twilio/incoming
```

**C. Check ngrok Web Interface**

```
Open: http://localhost:4040
View request/response details
```

**D. Firewall Blocking**

```bash
# Allow port 8000
sudo ufw allow 8000/tcp    # Linux
# Windows: Check Windows Firewall settings
```

**E. Twilio IP Whitelist**

```bash
# If behind firewall, whitelist Twilio IPs
# https://www.twilio.com/docs/ips
```

---

### ❌ Issue 6: Redis Connection Refused

**Symptoms:**

- "Connection refused" errors
- Call history not saving
- Dashboard shows no data

**Solutions:**

**A. Check Redis Service**

```bash
docker compose ps redis
docker compose logs redis

# Test connection
docker exec -it <redis-container> redis-cli ping
# Should return: PONG
```

**B. Redis Not Running**

```bash
docker compose up redis -d
```

**C. Wrong Host/Port**

```bash
# In api/main.py, ensure:
redis_client = redis.Redis(host="redis", port=6379, decode_responses=True)

# "redis" refers to service name in docker-compose.yml
```

**D. Redis Out of Memory**

```bash
# Check memory usage
docker stats redis

# Clear data
docker exec -it <redis-container> redis-cli FLUSHALL
```

---

### ❌ Issue 7: Dashboard Not Loading

**Symptoms:**

- Blank page
- 404 Not Found
- CORS errors in browser console

**Solutions:**

**A. Check Frontend Files**

```bash
# Ensure frontend directory exists
ls frontend/
# Should show: index.html, style.css, dashboard.js
```

**B. API Not Serving Static Files**

```bash
# Check api/main.py has:
app.mount("/dashboard", StaticFiles(directory=frontend_path, html=True), name="dashboard")
```

**C. Browser Console Errors**

```
Open browser developer tools (F12)
Check Console tab for errors
Check Network tab for failed requests
```

**D. CORS Issues**

```bash
# Verify CORS is enabled in api/main.py
# Try accessing directly: http://localhost:8000/dashboard/
```

**E. Cache Issues**

```bash
# Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
# Or clear browser cache
```

---

### ❌ Issue 8: Slow Response Times

**Symptoms:**

- Calls take >10 seconds to respond
- System feels sluggish
- High CPU/memory usage

**Solutions:**

**A. Check Resource Usage**

```bash
docker stats

# Look for containers using >90% CPU or memory
```

**B. Use Smaller Models**

```bash
# Whisper: Use "tiny" or "base" instead of "large"
# Edit whisper/stt.py:
model = whisper.load_model("base")

# Ollama: Use smaller model
docker exec -it <ollama-container> ollama pull phi
```

**C. Increase Resources**

```bash
# Docker Desktop → Settings → Resources
# Increase CPUs to 8 and Memory to 16GB
```

**D. Cold Start Issues**

```bash
# First call is always slower (models loading)
# Subsequent calls should be faster
# Keep containers running
```

**E. Network Latency**

```bash
# Test audio download speed
time curl -o test.mp3 "your-audio-url.mp3"

# If slow, consider caching
```

---

### ❌ Issue 9: Multiple Concurrent Calls Failing

**Symptoms:**

- First call works, second fails
- System crashes under load
- Out of memory errors

**Solutions:**

**A. Increase System Resources**

```yaml
# docker-compose.yml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 4G

  whisper:
    deploy:
      resources:
        limits:
          memory: 4G

  ollama:
    deploy:
      resources:
        limits:
          memory: 8G
```

**B. Scale Services**

```bash
# Run multiple Whisper instances
docker compose up --scale whisper=3 -d
```

**C. Add Load Balancer**

```bash
# Use nginx to distribute load
# See DEPLOYMENT.md for configuration
```

**D. Optimize Redis**

```bash
# Enable persistence
docker exec -it <redis-container> redis-cli CONFIG SET save "60 1"
```

---

### ❌ Issue 10: Audio Quality Issues

**Symptoms:**

- Robotic voice
- Garbled audio
- Unclear speech

**Solutions:**

**A. Improve TTS Quality**

```bash
# Use better TTS model
# Edit tts/tts.py:
tts = TTS(model_name="tts_models/en/vctk/vits")
```

**B. Use ElevenLabs API (Premium)**

```bash
# Add to requirements.txt: elevenlabs
# Update tts/tts.py to use ElevenLabs SDK
```

**C. Audio Encoding Issues**

```bash
# Ensure proper audio format
# Twilio prefers: 8kHz, mono, μ-law
```

**D. Whisper Model Size**

```bash
# Larger model = better accuracy
# Edit whisper/stt.py:
model = whisper.load_model("medium")  # or "large"
```

---

## Error Code Reference

### HTTP Error Codes

| Code | Meaning               | Solution                                |
| ---- | --------------------- | --------------------------------------- |
| 404  | Endpoint not found    | Check URL and route                     |
| 500  | Internal server error | Check logs for stack trace              |
| 502  | Bad gateway           | Service down, check docker compose ps   |
| 503  | Service unavailable   | Service overloaded or starting up       |
| 504  | Gateway timeout       | Request took too long, increase timeout |

### Twilio Error Codes

| Code  | Meaning                | Solution                             |
| ----- | ---------------------- | ------------------------------------ |
| 11200 | HTTP retrieval failure | Check webhook URL accessibility      |
| 11205 | Invalid URL            | Verify webhook URL format            |
| 11206 | Invalid method         | Ensure webhook is POST               |
| 13227 | Closed connection      | Webhook timed out, optimize response |

---

## Debug Mode

### Enable Verbose Logging

**API (api/main.py):**

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

**Docker Compose:**

```yaml
services:
  api:
    environment:
      - LOG_LEVEL=DEBUG
```

### View Real-Time Logs

```bash
# All services
docker compose logs -f

# Specific service with timestamps
docker compose logs -f --timestamps api

# Last 100 lines
docker compose logs --tail=100 api
```

---

## System Health Check Script

Create `health_check.sh`:

```bash
#!/bin/bash

echo "=== AI Calling Agent Health Check ==="
echo ""

# Check Docker
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Docker is not running"
    exit 1
fi
echo "✅ Docker is running"

# Check containers
CONTAINERS=("api" "whisper" "tts" "ollama" "redis")
for container in "${CONTAINERS[@]}"; do
    if docker compose ps $container | grep -q "Up"; then
        echo "✅ $container is running"
    else
        echo "❌ $container is NOT running"
    fi
done

# Check endpoints
echo ""
echo "=== Endpoint Tests ==="

# API
if curl -s http://localhost:8000/ | grep -q "status"; then
    echo "✅ API is responding"
else
    echo "❌ API is not responding"
fi

# Whisper
if curl -s http://localhost:5001/ | grep -q "status"; then
    echo "✅ Whisper is responding"
else
    echo "❌ Whisper is not responding"
fi

# TTS
if curl -s http://localhost:5002/ | grep -q "status"; then
    echo "✅ TTS is responding"
else
    echo "❌ TTS is not responding"
fi

# Dashboard
if curl -s http://localhost:8000/dashboard/ | grep -q "AI Calling Agent"; then
    echo "✅ Dashboard is accessible"
else
    echo "❌ Dashboard is not accessible"
fi

echo ""
echo "=== Resource Usage ==="
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo ""
echo "Health check complete!"
```

Run with: `bash health_check.sh`

---

## Recovery Procedures

### Procedure 1: Soft Reset

```bash
docker compose restart
```

### Procedure 2: Hard Reset

```bash
docker compose down
docker compose up -d
```

### Procedure 3: Full Reset (Nuclear Option)

```bash
# ⚠️ WARNING: This deletes ALL data
docker compose down -v
docker system prune -a -f
docker compose up --build -d
bash ollama_setup.sh
```

### Procedure 4: Restore from Backup

```bash
# Restore Redis data
docker exec -i <redis-container> redis-cli --pipe < backup.rdb

# Or copy backup file
docker cp backup.rdb <redis-container>:/data/dump.rdb
docker compose restart redis
```

---

## Getting Help

### Before Asking for Help

1. ✅ Run health check script
2. ✅ Collect logs: `docker compose logs > logs.txt`
3. ✅ Note error messages
4. ✅ Document steps to reproduce
5. ✅ Check this troubleshooting guide

### Information to Include

- Operating system and version
- Docker version: `docker --version`
- Docker Compose version: `docker compose version`
- Error logs
- Container status: `docker compose ps`
- System resources: `docker stats`

### Support Channels

- 📖 Check README.md
- 📋 Review TESTING.md
- 🚀 See DEPLOYMENT.md
- 💬 Open GitHub issue
- 📧 Contact support

---

## Prevention Tips

### Best Practices

1. **Regular Updates**

   ```bash
   git pull
   docker compose pull
   docker compose up -d
   ```

2. **Monitor Resources**

   ```bash
   # Set up alerts for high CPU/memory
   docker stats --no-stream
   ```

3. **Backup Redis Data**

   ```bash
   docker exec <redis-container> redis-cli BGSAVE
   docker cp <redis-container>:/data/dump.rdb ./backup/
   ```

4. **Test After Changes**

   ```bash
   bash health_check.sh
   ```

5. **Keep Logs**
   ```bash
   docker compose logs > "logs-$(date +%Y%m%d).txt"
   ```

---

**Still stuck? Don't hesitate to open an issue with detailed logs!**
