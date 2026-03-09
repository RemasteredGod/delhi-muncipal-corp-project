# 🔐 ngrok Authentication Quick Guide

## The Issue

ngrok now requires a **free account** to use. This takes 2 minutes.

## Quick Setup

### Step 1: Sign Up (30 seconds)

Visit: **https://dashboard.ngrok.com/signup**

Choose one:

- ✅ Sign up with **Google** (instant)
- ✅ Sign up with **GitHub** (instant)
- ✅ Sign up with **Email** (requires verification)

**No credit card needed!**

### Step 2: Get Your Authtoken (10 seconds)

After signup, you'll immediately see your authtoken on the screen.

Or visit: **https://dashboard.ngrok.com/get-started/your-authtoken**

It looks like:

```
2abc123def456ghi789jkl012mno345_6pqr789stu012vwx345yz
```

**Copy it!**

### Step 3: Configure ngrok

**Option A - Use the helper script:**

```bash
setup-ngrok.bat
```

Then paste your token when prompted.

**Option B - Manual command:**

```bash
ngrok config add-authtoken YOUR_TOKEN_HERE
```

Replace `YOUR_TOKEN_HERE` with your actual token.

### Step 4: Start ngrok

```bash
ngrok http 8000
```

You'll see:

```
ngrok

Session Status                online
Account                       your-email@example.com
Version                       3.x.x
Region                        United States (us)
Latency                       -
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123xyz.ngrok.io -> http://localhost:8000
```

### Step 5: Copy Your URL

Copy the URL from the **Forwarding** line:

```
https://abc123xyz.ngrok.io
```

### Step 6: Set Environment Variable

```powershell
# PowerShell - Use YOUR ngrok URL
$env:BASE_URL='https://abc123xyz.ngrok.io'
```

### Step 7: Test the Call Button!

1. Go to: http://localhost:8000/dashboard/
2. Click **"📞 Call Now"**
3. Watch it work! 🎉

## Visual Guide

```
┌─────────────────────────────────────────────┐
│  1. ngrok.com/signup                        │
│     ↓ Sign up (Google/GitHub)               │
│                                             │
│  2. Copy authtoken (shown after signup)     │
│     ↓                                       │
│                                             │
│  3. ngrok config add-authtoken TOKEN        │
│     ↓                                       │
│                                             │
│  4. ngrok http 8000                         │
│     ↓ Copy the HTTPS URL                    │
│                                             │
│  5. $env:BASE_URL='https://...'             │
│     ↓                                       │
│                                             │
│  6. Click "Call Now" in dashboard           │
│     ↓                                       │
│                                             │
│  ✅ CALL WORKS!                             │
└─────────────────────────────────────────────┘
```

## Troubleshooting

### "ngrok: command not found"

ngrok isn't installed or not in PATH.

**Fix:**

```powershell
# Restart PowerShell after installing ngrok
# Or add to PATH manually
```

### "Invalid authtoken"

You didn't copy it correctly or it has spaces.

**Fix:**

- Copy ONLY the token (no spaces before/after)
- Make sure you copied the entire token

### "Account not verified"

Some accounts need email verification.

**Fix:**

- Check your email for verification link
- Click the link
- Try again

### Token already used

That's fine! It means it's configured.

**Just run:**

```bash
ngrok http 8000
```

## What You Get (Free Plan)

✅ 1 ngrok process  
✅ 40 connections/minute  
✅ HTTPS tunnel  
✅ Works perfectly for this project!

⚠️ URL changes each time you restart ngrok  
💡 Upgrade for static URL (optional, not needed)

## Need Help?

1. **ngrok not starting?**
   - Check if another ngrok is already running
   - Try: `taskkill /F /IM ngrok.exe` then restart

2. **Still having issues?**
   - Check ngrok docs: https://ngrok.com/docs
   - Or use alternative: https://localtunnel.me

3. **Don't want to use ngrok?**
   - Deploy to cloud (Azure/AWS/Heroku)
   - Use Twilio Studio instead
   - Set up a VPS with public IP

---

**You're almost there!** Just 2 more minutes to get ngrok working! 🚀
