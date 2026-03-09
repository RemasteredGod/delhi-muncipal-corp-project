# 🚀 Quick ngrok Setup for Outbound Calls

## Why You Need This

Twilio requires a **public URL** to send webhooks. Your `localhost:8000` won't work because Twilio can't reach it from the internet.

**ngrok** creates a secure tunnel from a public URL to your local server.

## Step-by-Step Setup (2 minutes)

### 1. Download ngrok

**Windows:**

```powershell
# Download from:
https://ngrok.com/download

# Or use winget:
winget install --id=ngrok.ngrok -e
```

**Alternative - Use Chocolatey:**

```powershell
choco install ngrok
```

### 2. Start ngrok

Open a **new terminal** and run:

```bash
ngrok http 8000
```

You'll see output like this:

```
ngrok

Session Status                online
Account                       your-account
Version                       3.x.x
Region                        United States (us)
Latency                       -
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123xyz.ngrok.io -> http://localhost:8000

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

### 3. Copy Your ngrok URL

Look for the line that says:

```
Forwarding    https://abc123xyz.ngrok.io -> http://localhost:8000
```

Copy the HTTPS URL: `https://abc123xyz.ngrok.io`

⚠️ **Important:** Your URL will be different each time you start ngrok (unless you have a paid account)

### 4. Set Environment Variable

**Option A - Temporary (Current Terminal Only):**

```powershell
# PowerShell - Replace with YOUR ngrok URL
$env:BASE_URL='https://abc123xyz.ngrok.io'
```

```bash
# Linux/Mac - Replace with YOUR ngrok URL
export BASE_URL='https://abc123xyz.ngrok.io'
```

**Option B - Permanent (.env file):**

Add this line to `ai-calling-agent/.env`:

```
BASE_URL=https://abc123xyz.ngrok.io
```

### 5. Restart API Server

The API server should auto-reload if you used `--reload` flag.

If not, restart it:

```powershell
cd "e:\delhi muncipal corp project\ai-calling-agent\api"
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 6. Refresh Dashboard

In your browser:

- Press **Ctrl + Shift + R** (hard refresh)
- Or open: http://localhost:8000/dashboard/

### 7. Make a Call!

1. Your dashboard should now be open
2. The phone number `+919155428277` is already filled in
3. Click **"📞 Call Now"**
4. Watch the status update in real-time!

## Verification Steps

### ✅ Check ngrok is working:

```powershell
# Test your ngrok URL (replace with yours)
Invoke-WebRequest https://abc123xyz.ngrok.io
```

Should return: `{"status":"AI Calling Agent is running"}`

### ✅ Check BASE_URL is set:

```powershell
# PowerShell
echo $env:BASE_URL

# Should output: https://abc123xyz.ngrok.io
```

### ✅ Check API recognizes it:

```powershell
# This should now work without errors
Invoke-WebRequest -Uri "http://localhost:8000/initiate-call" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"to_number":"+919155428277"}'
```

## Troubleshooting

### "BASE_URL must be a public URL" error

- Make sure you set `$env:BASE_URL` with your ngrok URL
- Verify with: `echo $env:BASE_URL`
- Restart API server if needed

### ngrok session expired

- Free ngrok sessions expire after 2 hours
- Just restart ngrok and update BASE_URL
- Consider signing up for a free account for longer sessions

### "Connection refused" in ngrok

- Make sure your API server is running on port 8000
- Check: `netstat -ano | findstr :8000`

### Call initiated but no conversation data

- Ngrok URL must be HTTPS (not HTTP)
- API server must be accessible via ngrok
- Whisper and TTS services must be running

## Architecture with ngrok

```
Phone Call              ngrok Tunnel          Your Computer
   ↓                         ↓                      ↓
Twilio                https://abc.ngrok.io    localhost:8000
   ↓                         ↓                      ↓
Webhook ──────────────→  ngrok forwards  ──→  API Server
                                                     ↓
                                              Whisper, LLM, TTS
                                                     ↓
                                                   Redis
```

## What Happens When You Call

1. **Dashboard**: You click "Call Now"
2. **API**: POST request to `/initiate-call`
3. **Twilio**: Calls +919155428277 from +18708003674
4. **Greeting**: "Welcome to Delhi Municipal Corporation..."
5. **Recording**: User speaks their query
6. **Webhook**: Twilio sends recording → ngrok URL → localhost
7. **Processing**:
   - Whisper transcribes speech
   - Ollama generates response
   - TTS converts to speech
8. **Response**: User hears AI response
9. **Storage**: Conversation saved in Redis
10. **Dashboard**: Auto-refreshes to show conversation

## Free ngrok Limits

- ✅ 1 online ngrok process
- ✅ 40 connections/minute
- ✅ HTTPS support
- ⚠️ URL changes each restart
- ⚠️ 2-hour session timeout

**Sign up (free)** to get:

- Longer sessions
- Custom subdomain (URL doesn't change)
- More connections

Visit: https://dashboard.ngrok.com/signup

## Alternative Solutions

If you can't use ngrok:

1. **Twilio Studio** - Visual call flow designer (no code)
2. **Cloud Deployment** - Deploy to Azure/AWS/Heroku
3. **Other Tunnels** - LocalTunnel, Serveo, Pagekite
4. **VPS** - Rent a cheap server with public IP

## Next Steps

Once ngrok is working:

1. ✅ Make test call to verify end-to-end flow
2. ✅ Check Redis for conversation data
3. ✅ Monitor ngrok dashboard: http://localhost:4040
4. ✅ View Twilio logs: https://console.twilio.com/logs

---

**Need Help?** Check the main [README.md](README.md) or [OUTBOUND_CALLING_GUIDE.md](OUTBOUND_CALLING_GUIDE.md)
