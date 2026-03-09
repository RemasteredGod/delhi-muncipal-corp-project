# ✅ Getting Started Checklist

Use this checklist to set up and deploy your AI Calling Agent.

---

## 📋 Pre-Deployment Checklist

### System Requirements

- [ ] Windows 10/11, Linux, or macOS
- [ ] 8+ CPU cores (4 minimum)
- [ ] 16GB+ RAM (8GB minimum)
- [ ] 50GB+ free disk space
- [ ] Stable internet connection (for model downloads)

### Software Requirements

- [ ] Docker Desktop installed and running
- [ ] Docker Compose available (`docker compose version`)
- [ ] Git installed (for cloning)
- [ ] Text editor (VS Code, Notepad++, etc.)

### Account Setup

- [ ] Twilio account created (https://www.twilio.com/try-twilio)
- [ ] Twilio phone number purchased (free with trial)
- [ ] Twilio Account SID noted
- [ ] Twilio Auth Token noted
- [ ] ngrok account (optional, free tier works)

---

## 🚀 Installation Checklist

### Step 1: Get the Code

- [ ] Repository cloned or downloaded
- [ ] Navigate to `ai-calling-agent` directory
- [ ] Verify all files present (`README.md`, `docker-compose.yml`, etc.)

### Step 2: Configuration

- [ ] Copy `.env.example` to `.env`
- [ ] Edit `.env` file
- [ ] Add Twilio Account SID
- [ ] Add Twilio Auth Token
- [ ] Add Twilio Phone Number
- [ ] Save `.env` file

### Step 3: Start Services

- [ ] Open terminal in project directory
- [ ] Run: `docker compose up -d --build`
- [ ] Wait for services to start (2-5 minutes)
- [ ] Check status: `docker compose ps`
- [ ] All 5 services should show "Up"

### Step 4: Download AI Model

- [ ] Run: `bash ollama_setup.sh` (Linux/Mac)
- [ ] Or manually: `docker exec -it <ollama-container> ollama pull mistral`
- [ ] Wait for download to complete (~4GB, 5-10 minutes)
- [ ] Verify: Model should say "success"

### Step 5: Test Services

- [ ] Open browser to http://localhost:8000/
- [ ] Should see: `{"status": "AI Calling Agent is running"}`
- [ ] Test Whisper: http://localhost:5001/
- [ ] Test TTS: http://localhost:5002/
- [ ] Test Dashboard: http://localhost:8000/dashboard/
- [ ] All should respond successfully

### Step 6: Expose with ngrok

- [ ] Install ngrok (https://ngrok.com/download)
- [ ] Run: `ngrok http 8000`
- [ ] Note the HTTPS URL (e.g., https://abc123.ngrok.io)
- [ ] Keep ngrok running

### Step 7: Configure Twilio Webhook

- [ ] Log in to Twilio Console (https://console.twilio.com)
- [ ] Go to **Phone Numbers** → **Manage** → **Active Numbers**
- [ ] Click your phone number
- [ ] Scroll to **Voice Configuration**
- [ ] Under "A Call Comes In":
  - [ ] Select "Webhook"
  - [ ] Enter: `https://YOUR_NGROK_URL/twilio/incoming`
  - [ ] Select "HTTP POST"
- [ ] Click **Save**

### Step 8: Make Test Call

- [ ] Call your Twilio phone number
- [ ] Wait for greeting message
- [ ] Speak after the beep
- [ ] Wait for AI response (2-5 seconds)
- [ ] Verify natural conversation works
- [ ] Hang up

### Step 9: Verify Dashboard

- [ ] Open http://localhost:8000/dashboard/
- [ ] Click "Refresh" button
- [ ] Should see your call in the list
- [ ] Click to expand and view conversation
- [ ] Verify transcript is accurate

---

## 🧪 Testing Checklist

### Basic Tests

- [ ] Health check: `curl http://localhost:8000/`
- [ ] Whisper test: `curl http://localhost:5001/`
- [ ] TTS test: `curl http://localhost:5002/`
- [ ] Redis test: `docker exec -it <redis-container> redis-cli ping`

### Integration Tests

- [ ] Make a test call
- [ ] Have a 2-3 turn conversation
- [ ] Verify responses are appropriate
- [ ] Check conversation appears in dashboard
- [ ] Test auto-refresh feature

### Performance Tests

- [ ] Measure response time (should be 2-4 seconds)
- [ ] Check resource usage: `docker stats`
- [ ] Test with 2 concurrent calls (if possible)
- [ ] Verify system remains stable

---

## 📊 Production Deployment Checklist

### Pre-Production

- [ ] Review DEPLOYMENT.md
- [ ] Choose deployment platform (AWS, Azure, GCP)
- [ ] Set up cloud account
- [ ] Budget approved (~$150-200/month)
- [ ] Domain name registered (if using custom domain)

### Security

- [ ] Review security best practices
- [ ] Set up SSL/TLS certificates
- [ ] Configure firewall rules
- [ ] Enable authentication for dashboard
- [ ] Use secrets management (not .env file)
- [ ] Set up rate limiting
- [ ] Configure CORS properly
- [ ] Remove debug mode

### Infrastructure

- [ ] Provision server/container platform
- [ ] Install Docker on server
- [ ] Configure reverse proxy (Nginx)
- [ ] Set up SSL with Let's Encrypt
- [ ] Open required ports (80, 443)
- [ ] Configure load balancer (if needed)

### Deployment

- [ ] Clone repository on server
- [ ] Configure production .env
- [ ] Build and start services
- [ ] Download AI model
- [ ] Update Twilio webhook to production URL
- [ ] Test production deployment

### Monitoring

- [ ] Set up logging (ELK, CloudWatch, etc.)
- [ ] Configure monitoring (Prometheus, Grafana)
- [ ] Set up alerts (email, Slack, PagerDuty)
- [ ] Create health check monitoring
- [ ] Set up uptime monitoring
- [ ] Configure resource alerts

### Backup & Recovery

- [ ] Set up Redis backups
- [ ] Test backup restoration
- [ ] Document recovery procedures
- [ ] Create disaster recovery plan

---

## 🔧 Troubleshooting Checklist

### If Services Won't Start

- [ ] Check Docker is running
- [ ] Check ports are not in use
- [ ] Review logs: `docker compose logs`
- [ ] Try rebuild: `docker compose up --build -d`
- [ ] Check disk space: `df -h`

### If Calls Don't Work

- [ ] Verify ngrok is running
- [ ] Check Twilio webhook URL
- [ ] Review API logs: `docker compose logs api`
- [ ] Test webhook manually with curl
- [ ] Verify Twilio credentials in .env

### If AI Doesn't Respond

- [ ] Check Ollama model is downloaded
- [ ] Verify Ollama service is running
- [ ] Check Ollama logs: `docker compose logs ollama`
- [ ] Test Ollama directly: `curl http://localhost:11434/api/tags`
- [ ] Re-download model if needed

### If Dashboard Doesn't Load

- [ ] Check frontend files exist
- [ ] Clear browser cache
- [ ] Check browser console for errors
- [ ] Verify API CORS is enabled
- [ ] Try different browser

---

## 📈 Optimization Checklist

### Performance Optimization

- [ ] Use faster Whisper model (if accuracy is good)
- [ ] Implement response caching
- [ ] Optimize Docker images
- [ ] Enable Redis persistence
- [ ] Use SSD storage
- [ ] Add CDN for dashboard

### Cost Optimization

- [ ] Use spot instances (if applicable)
- [ ] Optimize container resource limits
- [ ] Monitor and reduce idle resources
- [ ] Use reserved instances for savings
- [ ] Implement auto-scaling

### User Experience

- [ ] Customize AI prompt for your use case
- [ ] Improve TTS voice quality
- [ ] Reduce response latency
- [ ] Add call recording feature
- [ ] Implement SMS notifications

---

## 📚 Documentation Review Checklist

- [ ] Read README.md (main documentation)
- [ ] Review QUICKSTART.md (fast setup)
- [ ] Study TESTING.md (test procedures)
- [ ] Review DEPLOYMENT.md (production guide)
- [ ] Read TROUBLESHOOTING.md (common issues)
- [ ] Check PROJECT_SUMMARY.md (overview)

---

## 🎯 Success Criteria

Your system is ready when:

✅ All 5 Docker containers are running
✅ Health checks pass for all services
✅ Dashboard loads and shows data
✅ Test call works end-to-end
✅ AI responds naturally within 2-5 seconds
✅ Conversation history is stored
✅ Multiple concurrent calls work (if testing)
✅ Documentation is understood
✅ Troubleshooting resources are available

---

## 📞 Support Contacts

### Documentation

- Main docs: README.md
- Quick help: QUICKSTART.md
- Issues: TROUBLESHOOTING.md

### External Resources

- Twilio Docs: https://www.twilio.com/docs
- Docker Docs: https://docs.docker.com
- FastAPI Docs: https://fastapi.tiangolo.com

### Community

- GitHub Issues: (repository issues page)
- Twilio Support: https://support.twilio.com
- Stack Overflow: (tag: ai-calling-agent)

---

## 🎉 Final Checklist

Before going live:

- [ ] ✅ All services tested
- [ ] ✅ Production deployment verified
- [ ] ✅ Security measures implemented
- [ ] ✅ Monitoring configured
- [ ] ✅ Backup strategy in place
- [ ] ✅ Team trained on system
- [ ] ✅ Documentation distributed
- [ ] ✅ Support contacts established
- [ ] ✅ Emergency procedures documented
- [ ] ✅ Budget approved and allocated

---

**You're ready to deploy your AI Calling Agent! 🚀**

_Keep this checklist handy for future deployments and troubleshooting._
