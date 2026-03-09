# 🚀 Running Without Docker

Quick guide to run the AI Calling Agent without Docker containers.

---

## ⚡ Two Commands to Run Everything

### **Windows**

```cmd
# 1. Start all backend services (API + Whisper + TTS)
cd ai-calling-agent
run_backend.bat

# 2. Dashboard opens automatically at http://localhost:8000/dashboard/
```

### **Linux/Mac**

```bash
# 1. Start all backend services (API + Whisper + TTS)
cd ai-calling-agent
bash run_backend.sh

# 2. Dashboard opens automatically at http://localhost:8000/dashboard/
```

---

## 📋 Prerequisites

### 1. **Python 3.10+**

```bash
python --version  # Should be 3.10 or higher
```

### 2. **Redis** (Required for session storage)

**Option A: Use Docker for Redis only**

```bash
docker run -d -p 6379:6379 redis:latest
```

**Option B: Install Redis locally**

- **Windows**: Download from https://github.com/microsoftarchive/redis/releases
- **Linux**: `sudo apt install redis-server`
- **Mac**: `brew install redis`

### 3. **Ollama** (Required for AI responses)

**Download & Install**

```bash
# Visit https://ollama.ai and download installer
# After installation, run:
ollama serve

# In another terminal, download the model:
ollama pull mistral
```

### 4. **FFmpeg** (Required for Whisper audio processing)

- **Windows**: Download from https://ffmpeg.org/download.html
- **Linux**: `sudo apt install ffmpeg`
- **Mac**: `brew install ffmpeg`

---

## 🎯 What Each Command Does

### `run_backend.bat` / `run_backend.sh`

This single script starts **all 3 Python services**:

1. **Whisper STT** (Port 5001) - Speech-to-Text transcription
2. **TTS Service** (Port 5002) - Text-to-Speech generation
3. **API Service** (Port 8000) - Main backend + Frontend dashboard

**The frontend is automatically served by the API at `/dashboard/`**

---

## 🌐 Service URLs

After running `run_backend`, access:

| Service       | URL                              |
| ------------- | -------------------------------- |
| **Dashboard** | http://localhost:8000/dashboard/ |
| API Docs      | http://localhost:8000/docs       |
| API Root      | http://localhost:8000            |
| Whisper STT   | http://localhost:5001            |
| TTS           | http://localhost:5002            |
| Ollama        | http://localhost:11434           |
| Redis         | localhost:6379                   |

---

## 🛑 Stopping Services

### **Windows**

```cmd
cd ai-calling-agent
stop_backend.bat
```

### **Linux/Mac**

```bash
cd ai-calling-agent
bash stop_backend.sh
```

**Or press `Ctrl+C` in the terminal running the services**

---

## 📊 Viewing Logs

All service logs are saved to `ai-calling-agent/logs/`

```bash
# View API logs
tail -f ai-calling-agent/logs/api.log

# View Whisper logs
tail -f ai-calling-agent/logs/whisper.log

# View TTS logs
tail -f ai-calling-agent/logs/tts.log
```

---

## 🔧 Manual Installation (Alternative)

If you prefer to install dependencies manually:

```bash
# Install API dependencies
cd ai-calling-agent/api
pip install -r requirements.txt

# Install Whisper dependencies
cd ../whisper
pip install -r requirements.txt

# Install TTS dependencies
cd ../tts
pip install -r requirements.txt
```

Then run each service manually:

```bash
# Terminal 1: Whisper
cd ai-calling-agent/whisper
python stt.py

# Terminal 2: TTS
cd ai-calling-agent/tts
python tts.py

# Terminal 3: API (serves frontend too)
cd ai-calling-agent/api
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

## ⚙️ Configuration

Don't forget to set up your `.env` file:

```bash
cd ai-calling-agent
cp .env.example .env
```

Edit `.env` with your Twilio credentials:

```env
TWILIO_ACCOUNT_SID=your_account_sid_here
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890
```

---

## 🧪 Testing Without Docker

Once services are running, test the API:

```bash
# Test API health
curl http://localhost:8000/

# Test Whisper
curl http://localhost:5001/

# Test TTS
curl -X POST http://localhost:5002/speak \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello from TTS"}'

# Test Ollama
curl http://localhost:11434/api/tags
```

---

## 🐛 Troubleshooting

### **Port Already in Use**

```bash
# Windows
netstat -ano | findstr :8000
taskkill /F /PID <PID>

# Linux/Mac
lsof -ti:8000 | xargs kill -9
```

### **Redis Connection Failed**

```bash
# Check if Redis is running
redis-cli ping
# Should return: PONG

# If not running, start Redis:
redis-server  # or: docker run -d -p 6379:6379 redis
```

### **Ollama Not Found**

```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Start Ollama service
ollama serve

# Download model
ollama pull mistral
```

### **Module Not Found Errors**

```bash
# Reinstall dependencies
cd ai-calling-agent/api
pip install -r requirements.txt --force-reinstall
```

---

## 📦 Why Not Use Docker?

**Docker is still recommended** for:

- ✅ Easier setup (one command)
- ✅ Consistent environment
- ✅ Isolated dependencies
- ✅ Production deployment

**Running without Docker is useful for**:

- 🔧 Development debugging
- 🧪 Testing individual services
- 💻 Limited Docker resources
- 🎓 Learning the architecture

---

## 🔄 Switching Back to Docker

To switch back to Docker:

```bash
cd ai-calling-agent
docker compose up -d
```

No code changes needed - the same codebase works for both!

---

## 📝 Summary

**Two commands to run everything:**

1. **Backend (all 3 services)**: `run_backend.bat` or `bash run_backend.sh`
2. **Frontend**: Automatically served at http://localhost:8000/dashboard/

**External dependencies (install once):**

- Redis (port 6379)
- Ollama (port 11434)

**Stop everything**: `stop_backend.bat` or `bash stop_backend.sh`

That's it! 🎉
