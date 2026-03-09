# 🚀 START - Quick Launch Guide

**Get your AI Calling Agent running in 3 commands!**

---

## 🎯 Fastest Way to Start

### Option 1: Automated Setup (Windows)

```powershell
cd ai-calling-agent
.\setup.ps1
```

This will:

- ✅ Check prerequisites
- ✅ Start all services (Backend + Frontend + Databases)
- ✅ Download AI model
- ✅ Set up ngrok tunnel
- ✅ Show you the webhook URL

**Done! Skip to "Access the System" section below.**

---

## Option 2: Manual Start (All Platforms)

### Step 1: Start Backend + Frontend

```bash
# Navigate to project
cd ai-calling-agent

# Start all services
docker compose up -d
```

This starts:

- ✅ **Backend API** (FastAPI) - Port 8000
- ✅ **Frontend Dashboard** (HTML/CSS/JS) - Served at /dashboard/
- ✅ **Whisper** (Speech-to-Text) - Port 5001
- ✅ **Ollama** (AI Model) - Port 11434
- ✅ **TTS** (Text-to-Speech) - Port 5002
- ✅ **Redis** (Database) - Port 6379

### Step 2: Download AI Model (First Time Only)

```bash
# Linux/Mac
bash ollama_setup.sh

# Windows (PowerShell)
$container = docker ps --filter "ancestor=ollama/ollama" --format "{{.ID}}" | Select-Object -First 1
docker exec -it $container ollama pull mistral
```

### Step 3: Expose Backend (For Twilio)

```bash
# Start ngrok
ngrok http 8000
```

Copy the HTTPS URL (e.g., `https://abc123.ngrok.io`)

---

## 🌐 Access the System

### Frontend Dashboard

```
http://localhost:8000/dashboard/
```

**Features:**

- View active calls
- See conversation transcripts
- Monitor system status
- Real-time updates

### Backend API

```
http://localhost:8000/
```

**Endpoints:**

- `GET /` - Health check
- `GET /calls` - List all calls
- `GET /calls/{id}` - Get call details
- `POST /twilio/incoming` - Twilio webhook

### Individual Services

```
Whisper (STT):  http://localhost:5001/
TTS:            http://localhost:5002/
Ollama (LLM):   http://localhost:11434/
```

---

## 📞 Configure Twilio (Required for Calls)

1. Go to: https://console.twilio.com
2. Navigate to: **Phone Numbers** → **Active Numbers**
3. Click your phone number
4. Set webhook to: `https://YOUR_NGROK_URL/twilio/incoming`
5. Save

**Now make a test call to your Twilio number!**

---

## 🛑 Stop Services

```bash
# Stop all services
docker compose down

# Stop and remove all data
docker compose down -v
```

---

## 🔄 Restart Services

```bash
# Restart everything
docker compose restart

# Restart specific service
docker compose restart api
docker compose restart whisper
docker compose restart tts
```

---

## 📊 Check Service Status

```bash
# View running containers
docker compose ps

# View logs (all services)
docker compose logs -f

# View logs (specific service)
docker compose logs -f api
docker compose logs -f whisper
docker compose logs -f tts
docker compose logs -f ollama

# Check resource usage
docker stats
```

---

## ✅ Verify Everything is Working

### 1. Check Backend Health

```bash
curl http://localhost:8000/
# Should return: {"status": "AI Calling Agent is running"}
```

### 2. Check Services

```bash
curl http://localhost:5001/  # Whisper
curl http://localhost:5002/  # TTS
```

### 3. Open Dashboard

```
Open browser: http://localhost:8000/dashboard/
Should see the dashboard with statistics
```

### 4. Make a Test Call

```
Call your Twilio number
Speak after the beep
AI should respond within 2-5 seconds
```

---

## 🐛 Quick Troubleshooting

### Services won't start?

```bash
# Check Docker is running
docker ps

# Try rebuilding
docker compose down
docker compose up --build -d
```

### Model not found?

```bash
# Re-download model
bash ollama_setup.sh
```

### Dashboard not loading?

```bash
# Clear browser cache
# Press: Ctrl + Shift + R

# Check API is running
curl http://localhost:8000/
```

### Twilio calls not working?

```bash
# Check ngrok is running
curl http://localhost:4040

# Verify webhook URL in Twilio console
# Format: https://abc123.ngrok.io/twilio/incoming
```

---

## 📁 What's Running?

| Service       | Purpose                           | Port  | URL                              |
| ------------- | --------------------------------- | ----- | -------------------------------- |
| **API**       | Backend server + Frontend hosting | 8000  | http://localhost:8000            |
| **Dashboard** | Web UI (served by API)            | 8000  | http://localhost:8000/dashboard/ |
| **Whisper**   | Speech-to-Text                    | 5001  | http://localhost:5001            |
| **TTS**       | Text-to-Speech                    | 5002  | http://localhost:5002            |
| **Ollama**    | AI Language Model                 | 11434 | http://localhost:11434           |
| **Redis**     | Session storage                   | 6379  | localhost:6379                   |

---

## 🎨 Frontend Files Located At:

```
ai-calling-agent/frontend/
├── index.html      # Main dashboard page
├── style.css       # Styling
└── dashboard.js    # Real-time API calls
```

**Hosted by:** FastAPI backend at `/dashboard/` route

---

## 🔧 Backend Files Located At:

```
ai-calling-agent/api/
├── main.py            # FastAPI app + Twilio webhooks
├── Dockerfile         # Container config
└── requirements.txt   # Python dependencies
```

**Runs on:** Port 8000

---

## 🎯 Development Mode

### Edit Frontend

```bash
# Frontend files are in:
cd ai-calling-agent/frontend

# Edit:
# - index.html (structure)
# - style.css (styling)
# - dashboard.js (functionality)

# Changes are live - just refresh browser
```

### Edit Backend

```bash
# Backend files are in:
cd ai-calling-agent/api

# Edit:
# - main.py (API endpoints, Twilio logic)

# Restart to see changes:
docker compose restart api
```

### View Live Logs

```bash
# Watch all logs
docker compose logs -f

# Watch API logs only
docker compose logs -f api
```

---

## 📚 Next Steps

Once services are running:

1. ✅ Access dashboard: http://localhost:8000/dashboard/
2. ✅ Configure Twilio webhook
3. ✅ Make a test call
4. ✅ View conversation in dashboard
5. ✅ Customize AI responses in `api/main.py`
6. ✅ Read full docs in `ai-calling-agent/README.md`

---

## 💡 Tips

**Keep ngrok running**

- ngrok must stay open for Twilio to reach your server
- If ngrok URL changes, update Twilio webhook

**Monitor resources**

- Use `docker stats` to watch CPU/memory usage
- Recommended: 16GB RAM, 8 CPU cores

**First call is slower**

- Models load on first request (~5-10 seconds)
- Subsequent calls are faster (2-4 seconds)

**Dashboard auto-refresh**

- Toggle "Auto-Refresh" button for live updates
- Updates every 3 seconds when enabled

---

## 🆘 Need Help?

1. Check: [TROUBLESHOOTING.md](ai-calling-agent/TROUBLESHOOTING.md)
2. View logs: `docker compose logs`
3. Check status: `docker compose ps`
4. Read full guide: [README.md](README.md)

---

## 🎉 That's It!

Your AI Calling Agent is now running:

- ✅ Backend API: http://localhost:8000
- ✅ Frontend Dashboard: http://localhost:8000/dashboard/
- ✅ All services operational
- ✅ Ready to receive calls

**Call your Twilio number to test!** 📞

---

_For detailed documentation, see [README.md](README.md)_
