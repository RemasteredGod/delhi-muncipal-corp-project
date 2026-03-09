# 📞 Outbound Calling Feature Guide

## What's New

Your AI Calling Agent dashboard now includes **outbound calling** with **real-time data collection**!

## Features Added

### 1. **Outbound Call Initiation**

- New call form at the top of the dashboard
- Pre-filled with the target number: `+919155428277`
- One-click calling with the "📞 Call Now" button

### 2. **Real-Time Updates**

- Automatic status messages during call initiation
- Auto-refresh feature automatically enables when you start a call
- Live tracking of call progress every 3 seconds
- Real-time conversation data displayed as it happens

### 3. **API Endpoint**

- New `/initiate-call` endpoint
- Handles outbound Twilio calls
- Stores call metadata in Redis
- Status callbacks for call tracking

## How to Use

### Step 1: Start Required Services

Make sure all services are running:

```bash
# Check Docker containers (Redis & Ollama)
docker ps

# Start API server (if not already running)
cd ai-calling-agent/api
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# Optional: Start Whisper & TTS for full functionality
cd ../whisper
python stt.py

cd ../tts
python tts.py
```

### Step 2: Access Dashboard

Open your browser to:

```
http://localhost:8000/dashboard/
```

### Step 3: Initiate a Call

1. **Enter Phone Number**: The form is pre-filled with `+919155428277`
2. **Click "📞 Call Now"**: Initiates the outbound call via Twilio
3. **Watch Status**: You'll see real-time status messages:
   - ⏳ Initiating call...
   - ✅ Call initiated successfully!
   - Call SID displayed for tracking

### Step 4: Monitor in Real-Time

- **Auto-Refresh**: Automatically turns on after initiating a call
- **Live Updates**: Call appears in the dashboard within 2-3 seconds
- **Conversation Tracking**: See user and AI messages as they happen
- **Statistics**: Active calls, total sessions, and message counts update live

## Important Notes

### ⚠️ ngrok Required for Full Functionality

For Twilio to send webhooks to your local server, you need ngrok:

```bash
# Install ngrok (if not already installed)
# Download from https://ngrok.com/download

# Start ngrok tunnel
ngrok http 8000
```

Then update your environment variable:

```bash
# In .env file, add:
BASE_URL=https://your-ngrok-url.ngrok.io
```

**Or** set it temporarily:

```bash
# Windows PowerShell
$env:BASE_URL="https://your-ngrok-url.ngrok.io"

# Linux/Mac
export BASE_URL="https://your-ngrok-url.ngrok.io"
```

### 📋 What Happens During a Call

1. **Call Initiated**: Your dashboard sends request to `/initiate-call`
2. **Twilio Connects**: Twilio calls the number from `+18708003674`
3. **Greeting Plays**: AI greets the caller (defined in `/twilio/incoming`)
4. **Recording Starts**: Caller's speech is recorded
5. **Whisper Transcribes**: Speech-to-text conversion
6. **Ollama Responds**: LLM generates AI response
7. **TTS Speaks**: Text-to-speech plays response
8. **Conversation Continues**: Loop repeats for multiple turns
9. **Redis Storage**: All messages saved with Call SID as key
10. **Dashboard Updates**: Real-time display of conversation

## API Reference

### POST /initiate-call

Initiates an outbound call.

**Request:**

```json
{
  "to_number": "+919155428277"
}
```

**Success Response:**

```json
{
  "success": true,
  "call_sid": "CA1234567890abcdef...",
  "to": "+919155428277",
  "status": "queued",
  "message": "Call initiated successfully"
}
```

**Error Response:**

```json
{
  "error": "Twilio client not initialized"
}
```

## Testing Without ngrok

If you don't have ngrok setup yet, you can still:

1. ✅ **Initiate calls** from the dashboard
2. ✅ **See call status** in the dashboard
3. ✅ **Track Call SID**
4. ❌ **Cannot receive** Twilio webhook responses
5. ❌ **No conversation data** (requires webhooks)

**Solution**: Follow the ngrok setup above for full functionality.

## Troubleshooting

### Call button does nothing

- Check browser console for errors (F12)
- Verify API is running: `http://localhost:8000/`
- Check Twilio credentials in `.env` file

### "Twilio client not initialized" error

- Verify `.env` file exists in `ai-calling-agent/` directory
- Check credentials:
  ```
  TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  TWILIO_AUTH_TOKEN=your_auth_token_here
  TWILIO_PHONE_NUMBER=+1XXXXXXXXXX
  ```
- Restart API server after updating `.env`

### Call initiated but no conversation data

- Requires ngrok webhook setup (see above)
- Check Twilio console for webhook errors
- Verify Whisper & TTS services are running

### Dashboard not updating

- Click "▶️ Auto-Refresh: OFF" to enable auto-refresh
- Or click "🔄 Refresh" manually
- Check browser console for fetch errors

## Architecture Flow

```
Dashboard (Browser)
    ↓
    | Click "Call Now"
    ↓
API Server (:8000)
    ↓
    | POST /initiate-call
    ↓
Twilio Voice API
    ↓
    | Calls +919155428277
    ↓
Caller Answers
    ↓
    | Webhook: /twilio/incoming
    ↓
Recording → Whisper STT (:5001)
    ↓
Text → Ollama LLM (:11434)
    ↓
Response → Coqui TTS (:5002)
    ↓
    | TwiML Response
    ↓
Caller Hears AI Response
    ↓
Conversation Stored in Redis (:6379)
    ↓
Dashboard Auto-Refreshes (3s)
    ↓
Real-Time Display Updated
```

## Files Modified

1. **api/main.py**
   - Added `from twilio.rest import Client`
   - Added `from dotenv import load_dotenv`
   - Initialized Twilio client with env credentials
   - Added `/initiate-call` endpoint

2. **frontend/index.html**
   - Added call initiation section
   - Phone number input field
   - Call Now button
   - Status message container

3. **frontend/dashboard.js**
   - Added `initiateCall()` function
   - API call to `/initiate-call`
   - Status message handling
   - Auto-enable auto-refresh on call

4. **frontend/style.css**
   - Call initiation section styling
   - Phone input styling
   - Call button with gradient
   - Status message styling (success/error/info)
   - Responsive mobile design

## Next Steps

1. **Setup ngrok** for webhook functionality (essential!)
2. **Configure Twilio webhooks** in Twilio console
3. **Start Whisper & TTS services** for full AI conversation
4. **Test a real call** to verify end-to-end flow
5. **Monitor Redis** to see conversation data: `redis-cli -h localhost`

## Support

For issues or questions:

- Check the main [README.md](README.md)
- Review [START.md](START.md) for basic setup
- Check Twilio console for call logs
- Monitor API server logs in PowerShell window

---

**Status**: ✅ Feature Ready - ngrok setup required for full functionality!
