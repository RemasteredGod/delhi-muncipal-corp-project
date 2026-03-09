# AI Calling Agent Prototype -- Master Prompt

Use this prompt to guide an AI coding assistant to generate the full
project.

------------------------------------------------------------------------

## Goal

Build a **prototype AI inbound and outbound calling agent** capable of
handling **1--5 simultaneous calls**.

The system should:

• Receive phone calls using **Twilio** • Convert speech to text •
Generate conversational responses using an **LLM** • Convert text back
to speech • Respond naturally to the caller

This system is for **prototype / hackathon use**, not production scale.

------------------------------------------------------------------------

# Core Architecture

Caller\
↓\
Twilio Voice\
↓\
FastAPI Backend (Webhook Server)\
↓\
Speech‑to‑Text (Whisper)\
↓\
LLM Conversation Engine (Ollama -- Mistral or Llama3)\
↓\
Text‑to‑Speech (Coqui TTS or ElevenLabs)\
↓\
Audio Response → Twilio → Caller

------------------------------------------------------------------------

# Technical Requirements

## Backend

Use:

Python\
FastAPI\
Uvicorn

Endpoints required:

POST /incoming-call\
POST /process-speech\
POST /call-status

The backend should:

• Handle Twilio voice webhooks\
• Maintain call sessions\
• Pass user speech to the AI engine\
• Return generated responses to Twilio

------------------------------------------------------------------------

## Speech‑to‑Text

Use **OpenAI Whisper (local)**.

Recommended model:

base

The STT module should:

1.  Accept audio from Twilio recording or stream\
2.  Convert audio → text\
3.  Return transcript to backend

------------------------------------------------------------------------

## LLM Conversation Engine

Use **Ollama** locally.

Recommended models:

mistral\
or\
llama3

The LLM should:

• Receive the user text\
• Maintain short conversation context\
• Generate a natural conversational reply

Example prompt template:

You are a polite AI assistant helping users through a phone call.\
Keep answers short, conversational, and natural.

User: {input}

Assistant:

------------------------------------------------------------------------

## Text‑to‑Speech

Use **Coqui TTS** locally.

Requirements:

• Convert response text → WAV audio\
• Return audio file path or stream\
• Fast enough for real-time conversation

Alternative:

ElevenLabs API for more realistic voice.

------------------------------------------------------------------------

## Memory (Optional but Recommended)

Use **Redis** to store:

call_id\
conversation_history\
timestamps

Example stored structure:

{ "call_id": "abc123", "history": \[ {"user": "hello"}, {"ai": "hi how
can I help you?"} \] }

------------------------------------------------------------------------

# Frontend Dashboard

Create a simple dashboard using:

HTML\
CSS\
Vanilla JavaScript

Do NOT use React or frameworks.

The dashboard should show:

Active calls\
Conversation transcripts\
AI responses\
Call logs

Example layout:

------------------------------------------------------------------------

AI CALLING AGENT DASHBOARD

Active Calls: 2

Call #1 User: Hello AI: Hi, how can I help you today?

Call #2 User: I want to book an appointment AI: Sure, what date would
you prefer?

------------------------------------------------------------------------

The dashboard should fetch data from:

GET /calls\
GET /calls/{id}

------------------------------------------------------------------------

# Project Structure

ai-calling-agent/

backend/ main.py twilio_handler.py stt.py tts.py conversation.py
memory.py

frontend/ index.html style.css dashboard.js

audio/

requirements.txt

------------------------------------------------------------------------

# Requirements File

fastapi uvicorn requests twilio openai-whisper TTS redis
python-multipart

------------------------------------------------------------------------

# Twilio Setup

1.  Create Twilio account
2.  Buy trial phone number
3.  Configure webhook:

Voice webhook →

POST https://yourserver.com/incoming-call

For local development use:

ngrok http 8000

------------------------------------------------------------------------

# Expected Demo Flow

Caller: Hello

AI: Hello! How can I assist you today?

Caller: I want to file a complaint

AI: I'm sorry to hear that. Could you please describe the issue?

Caller: My water supply is not working

AI: Thank you. I have registered your complaint. Our team will look into
it shortly.

------------------------------------------------------------------------

# Performance Target

Prototype hardware:

4--8 CPU cores\
16GB RAM

Supports:

1--5 concurrent calls

Average latency target:

Speech recognition: 1--2 seconds\
LLM response: 1 second\
TTS generation: \<1 second

Total response time:

2--4 seconds

------------------------------------------------------------------------

# Optional Improvements

Add:

Real‑time audio streaming\
Call sentiment analysis\
Call summary generation\
Human escalation\
Analytics dashboard

------------------------------------------------------------------------

# Final Goal

Produce a working prototype that can:

1.  Receive phone calls
2.  Understand speech
3.  Generate conversational AI responses
4.  Speak back naturally
5.  Display call logs in a dashboard

This system should be simple, modular, and easy to run locally.
