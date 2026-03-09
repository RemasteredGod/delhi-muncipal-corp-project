# 🚀 Quick Start Guide

Get the AI Calling Agent running in under 10 minutes!

---

## For Windows Users

### Step 1: Install Prerequisites

1. **Install Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop
   - Install and restart your computer
   - Make sure Docker is running (check system tray)

2. **Install ngrok** (for local testing)
   - Download from: https://ngrok.com/download
   - Extract and add to PATH, or run from download folder

3. **Get Twilio Account** (Free Trial)
   - Sign up at: https://www.twilio.com/try-twilio
   - Get a free phone number
   - Note your Account SID and Auth Token

### Step 2: Quick Setup

1. **Clone or download this repository**

2. **Create .env file**

   ```
   Copy .env.example to .env and fill in your Twilio credentials
   ```

3. **Run the setup script**

   ```powershell
   .\setup.ps1
   ```

   This will:
   - Start all Docker containers
   - Download the Mistral AI model
   - Set up ngrok tunnel
   - Display your webhook URL

### Step 3: Configure Twilio

1. Go to https://console.twilio.com/
2. Navigate to **Phone Numbers** → **Manage** → **Active Numbers**
3. Click your phone number
4. Scroll to **Voice Configuration**
5. Set "A Call Comes In" to:
   - **Webhook**
   - **URL**: `https://YOUR_NGROK_URL/twilio/incoming`
   - **HTTP Method**: POST
6. Click **Save**

### Step 4: Make a Test Call!

Call your Twilio number and start talking to your AI agent! 🎉

### Step 5: View Dashboard

Open your browser to: http://localhost:8000/dashboard/

---

## For Linux/Mac Users

### Step 1: Install Prerequisites

```bash
# Install Docker and Docker Compose
# (varies by distribution - see Docker docs)

# Install ngrok
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
sudo mv ngrok /usr/local/bin/
```

### Step 2: Quick Setup

```bash
# 1. Clone the repository
git clone <repository-url>
cd ai-calling-agent

# 2. Create .env file
cp .env.example .env
# Edit .env with your Twilio credentials

# 3. Start services
docker compose up --build -d

# 4. Pull Mistral model
bash ollama_setup.sh

# 5. Start ngrok
ngrok http 8000
```

### Step 3: Configure Twilio

Same as Windows steps above - use your ngrok URL

### Step 4: Test

Call your Twilio number and access dashboard at http://localhost:8000/dashboard/

---

## Commands Cheat Sheet

### Start Services

```bash
docker compose up -d
```

### Stop Services

```bash
docker compose down
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f whisper
```

### Restart a Service

```bash
docker compose restart api
```

### Check Status

```bash
docker compose ps
```

### Pull New LLM Model

```bash
# Get container ID
docker ps | grep ollama

# Pull model
docker exec -it <container-id> ollama pull llama3
```

---

## Troubleshooting Quick Fixes

### Services won't start

```bash
docker compose down
docker compose up --build -d
```

### Model not found

```bash
bash ollama_setup.sh
```

### Dashboard not loading

- Check http://localhost:8000/ works first
- Clear browser cache
- Try incognito mode

### Twilio not receiving calls

- Verify ngrok is running: http://localhost:4040
- Check webhook URL is correct in Twilio console
- Ensure URL ends with `/twilio/incoming`

---

## Next Steps

After successful setup:

1. ✅ Test with a phone call
2. ✅ View the dashboard
3. ✅ Customize the AI prompt in `api/main.py`
4. ✅ Adjust voice settings in `tts/tts.py`
5. ✅ Add your own business logic

---

## Production Deployment

For production use:

1. Deploy to a cloud server (AWS, Azure, GCP)
2. Use a proper domain name instead of ngrok
3. Add SSL/TLS certificates
4. Set up monitoring and logging
5. Implement rate limiting
6. Add authentication
7. Scale services based on load

---

## Support

Need help? Check:

- Main README.md for detailed documentation
- Docker logs for error messages
- Twilio console for webhook errors

Happy calling! 🎉
