# 🏗️ System Architecture & Flow

Visual guide to understanding how the AI Calling Agent works.

---

## 📊 High-Level Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                     USER (Caller)                              │
│                   📞 Makes Phone Call                          │
└───────────────────────────┬────────────────────────────────────┘
                            │
                            ↓
┌────────────────────────────────────────────────────────────────┐
│                    TWILIO VOICE API                            │
│              ☁️  Cloud Phone System                            │
│   • Receives call                                              │
│   • Routes to webhook                                          │
│   • Streams audio                                              │
└───────────────────────────┬────────────────────────────────────┘
                            │
                            ↓
┌────────────────────────────────────────────────────────────────┐
│              FASTAPI BACKEND (Port 8000)                       │
│                   🖥️  Main Server                              │
│   ┌──────────────────────────────────────────────────────┐   │
│   │  Twilio Webhooks                                     │   │
│   │  • /twilio/incoming       (receive call)             │   │
│   │  • /twilio/handle-recording (process speech)         │   │
│   │  • /twilio/call-status    (track status)             │   │
│   └──────────────────────────────────────────────────────┘   │
│   ┌──────────────────────────────────────────────────────┐   │
│   │  API Endpoints                                       │   │
│   │  • GET  /calls            (list all calls)           │   │
│   │  • GET  /calls/{id}       (call details)             │   │
│   │  • GET  /dashboard/       (web interface)            │   │
│   └──────────────────────────────────────────────────────┘   │
└───────┬────────────┬────────────┬────────────┬────────────────┘
        │            │            │            │
        ↓            ↓            ↓            ↓
┌─────────────┐ ┌─────────────┐ ┌─────────┐ ┌──────────────┐
│  WHISPER    │ │   OLLAMA    │ │   TTS   │ │    REDIS     │
│  (STT)      │ │   (LLM)     │ │ (Speech)│ │  (Storage)   │
│             │ │             │ │         │ │              │
│  🎤→📝      │ │  🤖💭      │ │  📝→🔊  │ │  💾 Sessions │
│  Port 5001  │ │ Port 11434  │ │Port 5002│ │  Port 6379   │
└─────────────┘ └─────────────┘ └─────────┘ └──────────────┘
```

---

## 🔄 Call Flow Diagram

### Step-by-Step Process

```
1️⃣ INCOMING CALL
   User calls → Twilio Phone Number

2️⃣ INITIAL GREETING
   Twilio → POST /twilio/incoming
   Backend returns TwiML with greeting
   "Hello, welcome to Delhi Municipal Corporation..."

3️⃣ USER SPEAKS
   Twilio records audio → Uploads to cloud

4️⃣ AUDIO PROCESSING
   Twilio → POST /twilio/handle-recording
   Backend receives recording URL

5️⃣ SPEECH TO TEXT
   Backend → Whisper Service (Port 5001)
   Audio URL → Downloads → Transcribes
   Returns: "I have a water supply problem"

6️⃣ AI PROCESSING
   Backend → Ollama Service (Port 11434)
   Sends transcribed text + system prompt
   Mistral LLM generates response
   Returns: "I'm sorry to hear that. Could you describe..."

7️⃣ TEXT TO SPEECH
   Backend → TTS Service (Port 5002)
   AI response text → Converts to audio WAV
   Returns: audio file path

8️⃣ STORE CONVERSATION
   Backend → Redis (Port 6379)
   Stores: User message + AI response
   Key: call:{CallSID}

9️⃣ RESPOND TO USER
   Backend → Returns TwiML to Twilio
   Twilio plays audio response to caller
   + Records next input (loop back to step 3)

🔟 DASHBOARD UPDATE
   Frontend polls /calls endpoint
   Fetches latest conversations
   Updates UI in real-time
```

---

## 🌐 Service Communication

### Internal Network Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network                           │
│                                                             │
│  ┌──────────┐                                              │
│  │   API    │───────────────┐                              │
│  │  :8000   │               │                              │
│  └────┬─────┘               │                              │
│       │                     │                              │
│       │ http://whisper:5001/transcribe                     │
│       │                     │                              │
│       ↓                     │                              │
│  ┌──────────┐               │                              │
│  │ Whisper  │               │                              │
│  │  :5001   │               │                              │
│  └──────────┘               │                              │
│                             │                              │
│       │ http://ollama:11434/api/generate                   │
│       │                     │                              │
│       ↓                     │                              │
│  ┌──────────┐               │                              │
│  │  Ollama  │               │                              │
│  │  :11434  │               │                              │
│  └──────────┘               │                              │
│                             │                              │
│       │ http://tts:5002/speak                              │
│       │                     │                              │
│       ↓                     │                              │
│  ┌──────────┐               │                              │
│  │   TTS    │               │                              │
│  │  :5002   │               │                              │
│  └──────────┘               │                              │
│                             │                              │
│       │ redis://redis:6379                                 │
│       │                     │                              │
│       ↓                     │                              │
│  ┌──────────┐               │                              │
│  │  Redis   │               │                              │
│  │  :6379   │               │                              │
│  └──────────┘               │                              │
│                             │                              │
└─────────────────────────────┴───────────────────────────────┘
```

---

## 📱 Frontend Architecture

### Dashboard Components

```
┌────────────────────────────────────────────────────────────┐
│                   index.html                               │
│              📄 Main HTML Structure                        │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │  <header>                                          │   │
│  │    🤖 AI Calling Agent Dashboard                   │   │
│  │    Delhi Municipal Corporation                     │   │
│  │  </header>                                         │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │  <div class="stats-bar">                           │   │
│  │    [Active: 2] [Total: 15] [Messages: 47]         │   │
│  │  </div>                                            │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │  <div class="controls">                            │   │
│  │    [🔄 Refresh] [▶️ Auto-Refresh: OFF]            │   │
│  │  </div>                                            │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │  <div id="calls-container">                        │   │
│  │    [Call #1] [Call #2] [Call #3] ...              │   │
│  │  </div>                                            │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  <script src="dashboard.js"></script>                     │
│  <link rel="stylesheet" href="style.css">                 │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                   dashboard.js                             │
│                 ⚡ JavaScript Logic                        │
│                                                            │
│  • API_BASE_URL = 'http://localhost:8000'                 │
│                                                            │
│  • loadCalls()                                            │
│    └─→ fetch('/calls')                                    │
│       └─→ renderCalls(data)                               │
│                                                            │
│  • loadCallDetails(callSid)                               │
│    └─→ fetch('/calls/{callSid}')                          │
│       └─→ display conversation                            │
│                                                            │
│  • toggleAutoRefresh()                                    │
│    └─→ setInterval(loadCalls, 3000)                       │
│                                                            │
│  • checkSystemStatus()                                    │
│    └─→ fetch('/')                                         │
│       └─→ update status indicator                         │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                     style.css                              │
│                  🎨 Styling & Layout                       │
│                                                            │
│  • Gradient background (purple to blue)                   │
│  • Card-based layout                                      │
│  • Responsive grid system                                 │
│  • Animated status indicators                             │
│  • Color-coded messages:                                  │
│    - User messages: Blue background                       │
│    - AI messages: Gray background                         │
└────────────────────────────────────────────────────────────┘
```

---

## 🔌 API Request/Response Flow

### Example: Listing All Calls

```
Frontend                    Backend                    Redis
   │                           │                         │
   │  GET /calls              │                         │
   ├──────────────────────────>│                         │
   │                           │  KEYS call:*            │
   │                           ├────────────────────────>│
   │                           │  [call:CA123, call:CA456]
   │                           │<────────────────────────┤
   │                           │                         │
   │                           │  LRANGE call:CA123 0 -1 │
   │                           ├────────────────────────>│
   │                           │  ["User: hello", ...]   │
   │                           │<────────────────────────┤
   │                           │                         │
   │  {active_calls: 2,        │                         │
   │   calls: [...]}           │                         │
   │<──────────────────────────┤                         │
   │                           │                         │
   [Update UI]                 │                         │
```

### Example: Processing a Call

```
Twilio                 Backend                Whisper              Ollama               TTS
  │                      │                      │                    │                   │
  │ POST /incoming      │                      │                    │                   │
  ├────────────────────>│                      │                    │                   │
  │ <TwiML: Greeting>   │                      │                    │                   │
  │<────────────────────┤                      │                    │                   │
  │                      │                      │                    │                   │
  [User speaks]          │                      │                    │                   │
  │                      │                      │                    │                   │
  │ POST /handle-recording                     │                    │                   │
  │ RecordingUrl         │                      │                    │                   │
  ├────────────────────>│                      │                    │                   │
  │                      │ POST /transcribe     │                    │                   │
  │                      │ {audio_url}          │                    │                   │
  │                      ├─────────────────────>│                    │                   │
  │                      │ {text: "..."}        │                    │                   │
  │                      │<─────────────────────┤                    │                   │
  │                      │                      │                    │                   │
  │                      │ POST /api/generate   │                    │                   │
  │                      │ {prompt: "..."}      │                    │                   │
  │                      ├──────────────────────┼───────────────────>│                   │
  │                      │ {response: "..."}    │                    │                   │
  │                      │<─────────────────────┼────────────────────┤                   │
  │                      │                      │                    │                   │
  │                      │ POST /speak          │                    │                   │
  │                      │ {text: "..."}        │                    │                   │
  │                      ├──────────────────────┼────────────────────┼──────────────────>│
  │                      │ {audio_file: "..."}  │                    │                   │
  │                      │<─────────────────────┼────────────────────┼───────────────────┤
  │                      │                      │                    │                   │
  │ <TwiML: Play audio>  │                      │                    │                   │
  │<────────────────────┤                      │                    │                   │
  │                      │                      │                    │                   │
  [Plays to user]        │                      │                    │                   │
```

---

## 📦 Docker Container Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                         Docker Host                             │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  ai-calling-agent_default (Docker Network)             │    │
│  │                                                         │    │
│  │  ┌──────────────────────┐                              │    │
│  │  │  api                 │                              │    │
│  │  │  Image: api:latest   │                              │    │
│  │  │  Build: ./api        │                              │    │
│  │  │  Ports: 8000:8000    │                              │    │
│  │  │  Env: .env           │                              │    │
│  │  └──────────────────────┘                              │    │
│  │                                                         │    │
│  │  ┌──────────────────────┐                              │    │
│  │  │  whisper             │                              │    │
│  │  │  Image: whisper:latest│                             │    │
│  │  │  Build: ./whisper    │                              │    │
│  │  │  Ports: 5001:5001    │                              │    │
│  │  └──────────────────────┘                              │    │
│  │                                                         │    │
│  │  ┌──────────────────────┐                              │    │
│  │  │  tts                 │                              │    │
│  │  │  Image: tts:latest   │                              │    │
│  │  │  Build: ./tts        │                              │    │
│  │  │  Ports: 5002:5002    │                              │    │
│  │  └──────────────────────┘                              │    │
│  │                                                         │    │
│  │  ┌──────────────────────┐                              │    │
│  │  │  ollama              │                              │    │
│  │  │  Image: ollama/ollama│                              │    │
│  │  │  Ports: 11434:11434  │                              │    │
│  │  │  Volume: ollama_data │                              │    │
│  │  └──────────────────────┘                              │    │
│  │                                                         │    │
│  │  ┌──────────────────────┐                              │    │
│  │  │  redis               │                              │    │
│  │  │  Image: redis:latest │                              │    │
│  │  │  Ports: 6379:6379    │                              │    │
│  │  └──────────────────────┘                              │    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 💾 Data Flow & Storage

### Redis Storage Structure

```
Redis Database
│
├── call:CA1234567890abcdef        (List)
│   ├── [0] "User: Hello"
│   ├── [1] "AI: Hello! How can I help?"
│   ├── [2] "User: Water supply issue"
│   └── [3] "AI: Thank you for reporting..."
│
├── call:CA9876543210fedcba        (List)
│   ├── [0] "User: Property tax query"
│   └── [1] "AI: I can help with that..."
│
└── status:CA1234567890abcdef      (String, TTL: 1 hour)
    └── "completed"
```

### File System Structure

```
/app                              (Container root)
│
├── /tmp/tts_output/              (TTS generated files)
│   ├── response_abc123.wav
│   ├── response_def456.wav
│   └── ...
│
└── /root/.cache/whisper/         (Whisper models)
    └── base.pt  (~142MB)
```

---

## 🔐 Security Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    EXTERNAL ACCESS                         │
│                                                            │
│  Internet → ngrok → localhost:8000 → Docker API           │
│                                                            │
│  Twilio Cloud ──┐                                         │
│  (Webhook)      │                                         │
│                 ↓                                          │
│  https://abc.ngrok.io/twilio/incoming                     │
│                                                            │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                   INTERNAL NETWORK                         │
│                 (Docker Bridge Network)                    │
│                                                            │
│  Service-to-Service Communication:                        │
│  • http://whisper:5001   (internal only)                  │
│  • http://tts:5002       (internal only)                  │
│  • http://ollama:11434   (internal only)                  │
│  • redis://redis:6379    (internal only)                  │
│                                                            │
│  Not exposed to internet ✅                                │
│                                                            │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                   ENVIRONMENT SECRETS                      │
│                                                            │
│  .env file (not in version control)                       │
│  ├── TWILIO_ACCOUNT_SID        (private)                  │
│  ├── TWILIO_AUTH_TOKEN         (private)                  │
│  └── TWILIO_PHONE_NUMBER       (private)                  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 🚦 State Machine

### Call State Transitions

```
┌──────────┐
│  IDLE    │  No active call
└────┬─────┘
     │ Incoming call
     ↓
┌──────────┐
│RECEIVING │  Call connected, playing greeting
└────┬─────┘
     │ Greeting complete
     ↓
┌──────────┐
│RECORDING │  Recording user speech
└────┬─────┘
     │ Recording complete
     ↓
┌──────────┐
│PROCESSING│  Transcribing + Generating response
└────┬─────┘
     │ Response ready
     ↓
┌──────────┐
│RESPONDING│  Playing AI response
└────┬─────┘
     │ Response complete
     ↓
┌──────────┐
│RECORDING │  ← Loop back (multi-turn conversation)
└────┬─────┘
     │ User hangs up
     ↓
┌──────────┐
│COMPLETED │  Call ended, history stored
└──────────┘
```

---

## 📈 Performance Metrics

### Latency Breakdown

```
Total Response Time: 2-4 seconds
│
├─ Audio Download:        0.1-0.5s   ▓░░░░░░░░░░░  2%
├─ Whisper Transcription: 1.0-2.0s   ▓▓▓▓▓▓░░░░░░ 40%
├─ LLM Generation:        0.5-1.0s   ▓▓▓░░░░░░░░░ 25%
├─ TTS Synthesis:         0.5-1.0s   ▓▓▓░░░░░░░░░ 25%
└─ Network + Overhead:    0.1-0.2s   ▓░░░░░░░░░░░  8%
```

### Resource Usage (per service)

```
Service    │ CPU  │ Memory │ Disk
───────────┼──────┼────────┼─────────
API        │  10% │  200MB │  10MB
Whisper    │  30% │  2GB   │  500MB
Ollama     │  40% │  5GB   │  4GB
TTS        │  15% │  1GB   │  500MB
Redis      │   5% │  50MB  │  10MB
───────────┼──────┼────────┼─────────
Total      │ 100% │  8.2GB │  5GB
```

---

**This architecture is designed for:**

- ✅ Prototype/Demo scale (1-5 concurrent calls)
- ✅ Easy local development
- ✅ Simple deployment
- ✅ Clear service boundaries
- ✅ Horizontal scalability potential

**For production scaling**, see [DEPLOYMENT.md](ai-calling-agent/DEPLOYMENT.md)
