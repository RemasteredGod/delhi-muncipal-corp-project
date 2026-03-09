# 🤖 Delhi Municipal Corporation - AI Calling Agent

**A Prototype AI-Powered Phone Assistant for Citizen Services**

This repository contains a complete AI calling agent system capable of handling inbound phone calls, understanding speech, generating intelligent responses, and speaking back naturally to callers.

---

## 📋 Quick Overview

**What is this?**
An AI-powered phone assistant that can handle 1-5 simultaneous calls, designed for the Delhi Municipal Corporation to assist citizens with queries about property tax, water supply, garbage collection, complaints, and permits.

**Key Features:**

- ✅ Inbound call handling via Twilio
- ✅ Speech recognition (Whisper AI)
- ✅ Natural conversation (Mistral LLM)
- ✅ Voice synthesis (Coqui TTS)
- ✅ Real-time monitoring dashboard
- ✅ Conversation history storage
- ✅ Docker-based deployment

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites

- Docker Desktop installed and running
- 16GB RAM (minimum 8GB)
- Twilio account with phone number
- ngrok (for local testing)

### Step 1: Start the Backend

```powershell
# Navigate to project directory
cd "e:\delhi muncipal corp project\ai-calling-agent"

# Windows users - Run automated setup
.\setup.ps1

# OR manually:
# 1. Copy environment file
cp .env.example .env

# 2. Edit .env and add your Twilio credentials
# TWILIO_ACCOUNT_SID=your_sid
# TWILIO_AUTH_TOKEN=your_token
# TWILIO_PHONE_NUMBER=your_number

# 3. Start all services
docker compose up -d --build

# 4. Download AI model (first time only)
bash ollama_setup.sh
```

### Step 2: Start ngrok (Expose Backend)

```powershell
# In a new terminal
ngrok http 8000
```

Copy the HTTPS URL (e.g., `https://abc123.ngrok.io`)

### Step 3: Configure Twilio

1. Go to [Twilio Console](https://console.twilio.com)
2. Navigate to: **Phone Numbers** → **Manage** → **Active Numbers**
3. Click your phone number
4. Under **Voice Configuration**:
   - Set "A Call Comes In" to: **Webhook**
   - URL: `https://YOUR_NGROK_URL/twilio/incoming`
   - Method: **POST**
5. Click **Save**

### Step 4: Access the Dashboard

Open your browser to:

```
http://localhost:8000/dashboard/
```

**Dashboard Features:**

- View active calls in real-time
- See conversation transcripts
- Monitor system status
- Track call history

---

## 📞 Testing the System

### Make a Test Call

1. Call your Twilio phone number
2. Wait for the AI greeting
3. Speak your query after the beep
4. The AI will respond naturally
5. Check the dashboard to see the conversation

**Expected Flow:**

```
🤖 AI: "Hello. Welcome to Delhi Municipal Corporation helpline.
       Please speak your query after the beep."

👤 You: "Hello, I have a complaint"

🤖 AI: "Hello! I'm sorry to hear that. Could you please describe
       the issue?"

👤 You: "My water supply is not working"

🤖 AI: "Thank you for reporting this. I have registered your
       complaint. Our team will look into it shortly."
```

---

## 📁 Project Structure

```
delhi-muncipal-corp-project/
├── ai-calling-agent/              # Main AI calling agent system
│   ├── api/                       # FastAPI backend
│   │   ├── main.py               # Main API with webhooks
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── whisper/                   # Speech-to-Text service
│   │   ├── stt.py                # Whisper transcription
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── tts/                       # Text-to-Speech service
│   │   ├── tts.py                # Coqui TTS
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── frontend/                  # Web dashboard
│   │   ├── index.html            # Dashboard UI
│   │   ├── style.css             # Styling
│   │   └── dashboard.js          # Real-time updates
│   │
│   ├── docker-compose.yml         # Service orchestration
│   ├── setup.ps1                 # Windows setup script
│   ├── ollama_setup.sh           # Download AI model
│   │
│   └── Documentation/
│       ├── README.md             # Detailed documentation
│       ├── QUICKSTART.md         # Fast setup guide
│       ├── TESTING.md            # Testing procedures
│       ├── DEPLOYMENT.md         # Production deployment
│       ├── TROUBLESHOOTING.md    # Issue resolution
│       ├── CHECKLIST.md          # Setup checklist
│       └── PROJECT_SUMMARY.md    # Complete overview
│
├── prompt.md                      # Original requirements
└── ai_calling_agent_prototype_setup.md  # Setup notes
```

---

## 🖥️ Starting Services

### Start All Services (Backend + Frontend)

```powershell
# Navigate to project directory
cd ai-calling-agent

# Start all services
docker compose up -d

# Check status
docker compose ps
```

**Services Running:**

- **API Backend**: http://localhost:8000
- **Dashboard (Frontend)**: http://localhost:8000/dashboard/
- **Whisper STT**: http://localhost:5001
- **TTS**: http://localhost:5002
- **Ollama LLM**: http://localhost:11434
- **Redis**: localhost:6379

### Start Individual Services

```powershell
# Start only backend API
docker compose up api -d

# Start only frontend (served by API)
# Frontend is automatically served at /dashboard/

# Start Whisper only
docker compose up whisper -d

# Start TTS only
docker compose up tts -d
```

### View Logs

```powershell
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f api
docker compose logs -f whisper
docker compose logs -f tts
docker compose logs -f ollama
```

### Stop Services

```powershell
# Stop all services
docker compose down

# Stop and remove volumes (clean restart)
docker compose down -v
```

### Restart Services

```powershell
# Restart all services
docker compose restart

# Restart specific service
docker compose restart api
```

---

## 🌐 API Endpoints

### Backend API (Port 8000)

| Endpoint                   | Method | Description                   |
| -------------------------- | ------ | ----------------------------- |
| `/`                        | GET    | Health check                  |
| `/twilio/incoming`         | POST   | Twilio incoming call webhook  |
| `/twilio/handle-recording` | POST   | Process caller audio          |
| `/twilio/call-status`      | POST   | Track call status             |
| `/calls`                   | GET    | List all call sessions        |
| `/calls/{call_sid}`        | GET    | Get call conversation details |
| `/dashboard/`              | GET    | Web dashboard (Frontend)      |

### Service Endpoints

| Service   | URL                              | Port  |
| --------- | -------------------------------- | ----- |
| API       | http://localhost:8000            | 8000  |
| Dashboard | http://localhost:8000/dashboard/ | 8000  |
| Whisper   | http://localhost:5001            | 5001  |
| TTS       | http://localhost:5002            | 5002  |
| Ollama    | http://localhost:11434           | 11434 |
| Redis     | localhost:6379                   | 6379  |

---

## 🧪 Testing Endpoints

### Test Backend

```powershell
# Health check
curl http://localhost:8000/

# List calls
curl http://localhost:8000/calls

# Get specific call
curl http://localhost:8000/calls/CA1234567890
```

### Test Services

```powershell
# Test Whisper
curl http://localhost:5001/

# Test TTS
curl http://localhost:5002/

# Test Ollama
curl http://localhost:11434/api/tags
```

---

## 🎨 Frontend Dashboard

Access the dashboard at: **http://localhost:8000/dashboard/**

### Dashboard Features

**Statistics:**

- Active calls count
- Total sessions
- Total messages
- System status indicator (live)

**Call Monitoring:**

- Real-time call list
- Conversation transcripts
- User messages (blue)
- AI responses (gray)

**Controls:**

- Refresh button (manual update)
- Auto-refresh toggle (updates every 3 seconds)

### Dashboard Screenshots

```
┌─────────────────────────────────────────────────┐
│      🤖 AI Calling Agent Dashboard              │
│   Delhi Municipal Corporation - Helpline        │
├─────────────────────────────────────────────────┤
│  Active: 2  │  Sessions: 15  │  Messages: 47   │
├─────────────────────────────────────────────────┤
│  📞 Call: CA123...789  [4 messages]             │
│  👤 Caller: Hello, I have a complaint           │
│  🤖 AI: I'm sorry to hear that...              │
│  👤 Caller: Water supply issue                  │
│  🤖 AI: Thank you for reporting...             │
└─────────────────────────────────────────────────┘
```

---

## ⚡ Performance

**Response Times:**

- Speech Recognition: 1-2 seconds
- LLM Response: ~1 second
- TTS Generation: <1 second
- **Total: 2-4 seconds per exchange**

**Capacity:**

- Concurrent Calls: 1-5 (prototype scale)
- Calls per Hour: ~30-50
- Calls per Day: ~500-1000

**Resource Usage:**

- CPU: 4-8 cores recommended
- RAM: 16GB recommended (8GB minimum)
- Disk: 50GB (for models and storage)

---

## 🔧 Troubleshooting

### Services Won't Start

```powershell
# Check Docker is running
docker ps

# Rebuild containers
docker compose down
docker compose up --build -d

# Check logs for errors
docker compose logs
```

### Ollama Model Not Found

```powershell
# Download model manually
$ollamaContainer = docker ps --filter "ancestor=ollama/ollama" --format "{{.ID}}" | Select-Object -First 1
docker exec -it $ollamaContainer ollama pull mistral
```

### Dashboard Not Loading

```powershell
# Check API is running
curl http://localhost:8000/

# Clear browser cache
# Try: Ctrl+Shift+R (hard refresh)

# Check logs
docker compose logs api
```

### Twilio Webhook Not Working

```powershell
# Verify ngrok is running
curl http://localhost:4040

# Check webhook URL in Twilio console
# Must be: https://YOUR_NGROK_URL/twilio/incoming

# Test webhook manually
curl -X POST http://localhost:8000/twilio/incoming
```

**For detailed troubleshooting**, see [TROUBLESHOOTING.md](ai-calling-agent/TROUBLESHOOTING.md)

---

## 📚 Complete Documentation

| Document                                                  | Description                    |
| --------------------------------------------------------- | ------------------------------ |
| [README.md](ai-calling-agent/README.md)                   | Complete setup and usage guide |
| [QUICKSTART.md](ai-calling-agent/QUICKSTART.md)           | Get started in 10 minutes      |
| [TESTING.md](ai-calling-agent/TESTING.md)                 | Comprehensive testing guide    |
| [DEPLOYMENT.md](ai-calling-agent/DEPLOYMENT.md)           | Production deployment guide    |
| [TROUBLESHOOTING.md](ai-calling-agent/TROUBLESHOOTING.md) | Common issues and solutions    |
| [CHECKLIST.md](ai-calling-agent/CHECKLIST.md)             | Step-by-step setup checklist   |
| [PROJECT_SUMMARY.md](ai-calling-agent/PROJECT_SUMMARY.md) | Complete project overview      |

---

## 🎯 Common Tasks

### Update AI Model

```powershell
# Pull a different model
docker exec -it <ollama-container-id> ollama pull llama3

# Update api/main.py to use new model
# Change: "model": "llama3"
```

### Customize AI Responses

Edit `ai-calling-agent/api/main.py`:

```python
system_prompt = (
    "You are a helpful AI assistant for [Your Organization]. "
    "Answer queries about [your topics]. "
    "Be concise and friendly."
)
```

### Change TTS Voice

Edit `ai-calling-agent/tts/tts.py`:

```python
# Use a different TTS model
tts = TTS(model_name="tts_models/en/vctk/vits")
```

### Export Call History

```powershell
# Connect to Redis
docker exec -it <redis-container-id> redis-cli

# In Redis CLI:
KEYS call:*                # List all calls
LRANGE call:CAxxxx 0 -1    # View specific call
```

---

## 🚀 Production Deployment

For production deployment on cloud platforms:

1. **Review**: [DEPLOYMENT.md](ai-calling-agent/DEPLOYMENT.md)
2. **Choose Platform**: AWS, Azure, GCP, or Kubernetes
3. **Security**: Enable SSL, authentication, rate limiting
4. **Monitoring**: Set up logging and alerts
5. **Scaling**: Configure auto-scaling and load balancing

**Estimated Monthly Cost**: $110-180 (depends on platform and usage)

---

## 💡 Use Cases

- **Citizen Helpline**: Answer queries about municipal services
- **Complaint Registration**: Log citizen complaints automatically
- **Information Desk**: Provide information about taxes, permits
- **Appointment Booking**: Schedule appointments for services
- **Status Updates**: Check complaint/application status
- **Emergency Hotline**: Route urgent calls to human operators

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](ai-calling-agent/LICENSE) for details.

---

## 🆘 Support

**Need Help?**

1. Check [TROUBLESHOOTING.md](ai-calling-agent/TROUBLESHOOTING.md)
2. Review [FAQ section](#faq)
3. Check Docker logs: `docker compose logs`
4. Open a GitHub issue with detailed information

**Resources:**

- Twilio Documentation: https://www.twilio.com/docs
- Docker Documentation: https://docs.docker.com
- FastAPI Documentation: https://fastapi.tiangolo.com

---

## ❓ FAQ

### How do I start just the backend?

```powershell
cd ai-calling-agent
docker compose up api whisper tts ollama redis -d
```

### How do I access just the frontend?

The frontend is served by the backend at: http://localhost:8000/dashboard/

### How do I change the port?

Edit `docker-compose.yml` and change the port mapping:

```yaml
api:
  ports:
    - '9000:8000' # Change 8000 to 9000
```

### Can I use a different LLM?

Yes! You can use GPT, Claude, or any other LLM. Just modify `api/main.py` to call your preferred API.

### How do I make outbound calls?

See Twilio's [outbound calling documentation](https://www.twilio.com/docs/voice/make-calls). Modify `api/main.py` to initiate calls.

### What languages are supported?

Whisper supports 96+ languages. Modify the language parameter in `whisper/stt.py`.

### Can I record calls?

Yes! Add Twilio's recording parameter in the TwiML response. See Twilio docs for details.

---

## 🎉 Quick Command Reference

```powershell
# Start everything
cd ai-calling-agent
docker compose up -d

# View logs
docker compose logs -f

# Stop everything
docker compose down

# Restart a service
docker compose restart api

# Check status
docker compose ps

# View resource usage
docker stats

# Access dashboard
start http://localhost:8000/dashboard/

# Check API health
curl http://localhost:8000/
```

---

## 📊 System Status Check

Run this to check if everything is working:

```powershell
# Check Docker
docker ps

# Check services
curl http://localhost:8000/        # API
curl http://localhost:5001/        # Whisper
curl http://localhost:5002/        # TTS
curl http://localhost:8000/calls   # Calls API

# Check dashboard
start http://localhost:8000/dashboard/
```

All should return success responses!

---

**🎊 Your AI Calling Agent is ready to handle calls!**

For detailed setup instructions, see [QUICKSTART.md](ai-calling-agent/QUICKSTART.md)

---

_Built with ❤️ for the Delhi Municipal Corporation_
