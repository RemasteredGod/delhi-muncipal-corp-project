# 🤖 AI Calling Agent Prototype

A fully-featured AI calling agent capable of handling **1-5 simultaneous phone calls** using **Twilio**, **Whisper (STT)**, **Ollama (LLM)**, and **Coqui TTS**.

This system is designed for **prototype and hackathon use**, demonstrating how to build an intelligent phone assistant for handling citizen queries.

---

## 🏗️ Architecture Overview

```
Caller
  ↓
Twilio Voice
  ↓
FastAPI Backend (Webhook Server)
  ↓
Speech-to-Text (Whisper)
  ↓
LLM Conversation Engine (Ollama - Mistral)
  ↓
Text-to-Speech (Coqui TTS)
  ↓
Audio Response → Twilio → Caller
```

---

## 🚀 Features

- ✅ **Inbound Call Handling** via Twilio
- ✅ **Speech Recognition** using OpenAI Whisper
- ✅ **AI Conversation** powered by Ollama (Mistral/Llama3)
- ✅ **Natural Voice Responses** using Coqui TTS
- ✅ **Session Management** with Redis
- ✅ **Real-time Dashboard** to monitor active calls
- ✅ **Conversation History** stored per call
- ✅ **Dockerized Services** for easy deployment

---

## 📦 Tech Stack

| Component         | Technology                    |
| ----------------- | ----------------------------- |
| Backend           | Python, FastAPI, Uvicorn      |
| Speech-to-Text    | OpenAI Whisper (base model)   |
| LLM               | Ollama (Mistral)              |
| Text-to-Speech    | Coqui TTS                     |
| Memory            | Redis                         |
| Phone Integration | Twilio                        |
| Frontend          | HTML, CSS, Vanilla JavaScript |
| Deployment        | Docker, Docker Compose        |

---

## 📋 Prerequisites

Before you begin, ensure you have:

- **Docker** and **Docker Compose** installed
- **Twilio Account** (free trial works fine)
- **ngrok** (for local development) or a public server
- **4-8 CPU cores** and **16GB RAM** recommended

---

## ⚙️ Installation & Setup

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd ai-calling-agent
```

### Step 2: Configure Environment Variables

Create a `.env` file in the root directory:

```env
# Twilio Credentials (get from https://console.twilio.com)
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1234567890

# Optional: ElevenLabs for better TTS (premium)
ELEVENLABS_API_KEY=your_api_key
```

### Step 3: Build and Start Services

```bash
# Build and start all containers
docker compose up --build -d

# Wait for services to initialize (30-60 seconds)
```

### Step 4: Pull the Mistral LLM Model

```bash
# Run this ONCE to download the Mistral model
bash ollama_setup.sh
```

This will take 5-10 minutes depending on your internet speed. The Mistral model is approximately 4GB.

### Step 5: Set Up Twilio Webhook

#### Option A: Using ngrok (Local Development)

```bash
# In a separate terminal
ngrok http 8000
```

Copy the ngrok URL (e.g., `https://abc123.ngrok.io`) and configure it in Twilio:

1. Go to **Twilio Console** → **Phone Numbers**
2. Select your phone number
3. Under **Voice Configuration**:
   - **A Call Comes In**: Webhook
   - **URL**: `https://abc123.ngrok.io/twilio/incoming`
   - **HTTP Method**: POST

#### Option B: Using a Public Server

If you're deploying on a server with a public IP:

```
https://your-server.com:8000/twilio/incoming
```

---

## 🎯 Testing the System

### Test 1: Check Services are Running

```bash
# Check if all containers are up
docker compose ps

# Expected output:
# api      running
# whisper  running
# tts      running
# ollama   running
# redis    running
```

### Test 2: Health Check Endpoints

```bash
# Test API
curl http://localhost:8000/

# Test Whisper
curl http://localhost:5001/

# Test TTS
curl http://localhost:5002/
```

### Test 3: Make a Phone Call

1. Call your Twilio phone number
2. Wait for the greeting message
3. Speak your query after the beep
4. The AI will respond with a natural voice

**Example Conversation:**

```
Caller: Hello
AI: Hello! How can I assist you today?

Caller: I want to file a complaint about water supply
AI: I'm sorry to hear that. Could you please describe the issue?

Caller: My water supply has been off for 2 days
AI: Thank you for reporting this. I have registered your complaint.
    Our team will look into it shortly. Your complaint reference number
    will be sent to you via SMS.
```

---

## 📊 Dashboard

Access the real-time dashboard at:

```
http://localhost:8000/dashboard/
```

### Dashboard Features:

- **Active Calls Counter**: Shows current ongoing calls
- **Total Sessions**: Number of unique call sessions
- **Total Messages**: Aggregate message count
- **System Status**: Green dot indicates all services are running
- **Auto-Refresh**: Toggle to enable real-time updates every 3 seconds
- **Call Transcripts**: View full conversation history for each call

---

## 📁 Project Structure

```
ai-calling-agent/
├── docker-compose.yml          # Orchestrates all services
├── ollama_setup.sh             # Script to pull LLM model
├── .env                        # Environment variables
├── .env.example                # Example environment file
│
├── api/                        # FastAPI backend
│   ├── Dockerfile
│   ├── main.py                 # Main API with Twilio webhooks
│   └── requirements.txt
│
├── whisper/                    # Speech-to-Text service
│   ├── Dockerfile
│   ├── stt.py                  # Whisper transcription service
│   └── requirements.txt
│
├── tts/                        # Text-to-Speech service
│   ├── Dockerfile
│   ├── tts.py                  # Coqui TTS service
│   └── requirements.txt
│
└── frontend/                   # Dashboard UI
    ├── index.html              # Main dashboard page
    ├── style.css               # Styling
    └── dashboard.js            # API integration & logic
```

---

## 🔌 API Endpoints

### Main Endpoints

| Method | Endpoint                   | Description                  |
| ------ | -------------------------- | ---------------------------- |
| GET    | `/`                        | Health check                 |
| POST   | `/twilio/incoming`         | Twilio incoming call webhook |
| POST   | `/twilio/handle-recording` | Process caller audio         |
| POST   | `/twilio/call-status`      | Track call status changes    |
| GET    | `/calls`                   | List all call sessions       |
| GET    | `/calls/{call_sid}`        | Get detailed conversation    |

### Service Endpoints

| Service | Endpoint               | Port  |
| ------- | ---------------------- | ----- |
| API     | http://localhost:8000  | 8000  |
| Whisper | http://localhost:5001  | 5001  |
| TTS     | http://localhost:5002  | 5002  |
| Ollama  | http://localhost:11434 | 11434 |
| Redis   | localhost:6379         | 6379  |

---

## ⚡ Performance Metrics

**Target Latency (Per Response):**

- Speech Recognition: 1-2 seconds
- LLM Response Generation: 1 second
- TTS Generation: <1 second
- **Total Response Time: 2-4 seconds**

**Concurrent Call Support:**

- 1-5 simultaneous calls (prototype scale)
- Scales based on available CPU/RAM

**Hardware Requirements:**

- **Minimum**: 4 cores, 8GB RAM
- **Recommended**: 8 cores, 16GB RAM

---

## 🐛 Troubleshooting

### Issue: Ollama model not found

**Solution:**

```bash
bash ollama_setup.sh
```

### Issue: Whisper transcription fails

**Solution:** Check if ffmpeg is installed in the container:

```bash
docker exec -it <whisper-container-id> ffmpeg -version
```

### Issue: TTS generates garbled audio

**Solution:** Restart the TTS service:

```bash
docker compose restart tts
```

### Issue: Twilio webhook not receiving calls

**Solution:**

1. Verify ngrok is running: `curl http://localhost:4040`
2. Check Twilio webhook URL is correct
3. Ensure your Twilio number has voice capabilities

### Issue: Redis connection refused

**Solution:**

```bash
docker compose restart redis
docker compose logs redis
```

---

## 🔧 Configuration Options

### Change LLM Model

Edit `api/main.py` and update the model name:

```python
"model": "llama3",  # or "mistral", "codellama", etc.
```

Then pull the new model:

```bash
docker exec -it <ollama-container-id> ollama pull llama3
```

### Use ElevenLabs for Better TTS

Update `tts/tts.py` to use ElevenLabs API:

```python
# Add elevenlabs package to requirements.txt
# Use their SDK for more realistic voices
```

### Adjust Whisper Model Size

Edit `whisper/stt.py`:

```python
model = whisper.load_model("medium")  # Options: tiny, base, small, medium, large
```

**Note:** Larger models provide better accuracy but are slower.

---

## 🎨 Customization

### Modify AI Personality

Edit the system prompt in `api/main.py`:

```python
system_prompt = (
    "You are a helpful AI assistant for [Your Organization]. "
    "Answer queries about [your services]. "
    "Keep responses concise and friendly."
)
```

### Add New Endpoints

Add custom endpoints to `api/main.py` for your use case:

```python
@app.post("/custom-endpoint")
async def custom_handler():
    # Your logic here
    pass
```

---

## 📈 Future Enhancements

Potential improvements for production deployment:

- [ ] Real-time audio streaming (WebSocket)
- [ ] Call sentiment analysis
- [ ] Automatic call summary generation
- [ ] Human escalation for complex queries
- [ ] Multi-language support
- [ ] Analytics dashboard with charts
- [ ] Call recording storage
- [ ] Scheduled outbound calls
- [ ] Integration with CRM systems

---

## 📝 License

This project is for prototype/educational purposes.

---

## 🤝 Contributing

Contributions welcome! Please submit issues and pull requests.

---

## 📞 Support

For questions or issues:

- Check the **Troubleshooting** section
- Review Docker logs: `docker compose logs`
- Open an issue on GitHub

---

## 🎉 Demo Flow

**Expected Conversation:**

```
📞 Caller dials Twilio number

🤖 AI: "Hello. Welcome to Delhi Municipal Corporation helpline.
       Please speak your query after the beep."

👤 Caller: "Hello"

🤖 AI: "Hello! How can I assist you today?"

👤 Caller: "I want to file a complaint"

🤖 AI: "I'm sorry to hear that. Could you please describe the issue?"

👤 Caller: "My water supply is not working"

🤖 AI: "Thank you. I have registered your complaint.
       Our team will look into it shortly."
```

---

**Built with ❤️ for the Delhi Municipal Corporation**

_This is a prototype system designed for hackathons and demonstrations._
