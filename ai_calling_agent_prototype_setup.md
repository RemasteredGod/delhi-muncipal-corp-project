# AI Inbound & Outbound Calling Agent (Prototype) -- Implementation Guide

This guide explains how to build a **Docker‑ready AI calling agent
prototype** capable of handling **1--5 simultaneous calls** using only
CPU resources.

The system will support:

-   Inbound phone calls
-   Speech → Text conversion
-   AI conversation generation
-   Text → Speech response
-   Basic contextual memory

This version is designed for **demonstration / hackathon / prototype
usage**, not large-scale production.

------------------------------------------------------------------------

# 1. System Architecture

    Caller
       ↓
    Telephony Provider (Twilio)
       ↓
    FastAPI Backend
       ↓
    Speech‑to‑Text (Whisper)
       ↓
    Conversation Engine (LLM via Ollama)
       ↓
    Text‑to‑Speech (Coqui TTS)
       ↓
    Audio Response
       ↓
    Caller

Containers used:

-   API Server (FastAPI)
-   Whisper STT
-   Ollama LLM
-   TTS Service
-   Redis

All services run through **Docker Compose**.

------------------------------------------------------------------------

# 2. Prerequisites

Install the following:

### Docker

https://docs.docker.com/get-docker/

Verify:

``` bash
docker --version
```

### Docker Compose

``` bash
docker compose version
```

### Git

``` bash
git --version
```

### Twilio Account

Create a free account:

https://www.twilio.com/

You will receive:

-   Account SID
-   Auth Token
-   Trial phone number

------------------------------------------------------------------------

# 3. Project Structure

Create the following structure.

    ai-calling-agent/

    docker-compose.yml

    api/
      main.py
      requirements.txt
      Dockerfile

    whisper/
      stt.py
      requirements.txt
      Dockerfile

    tts/
      tts.py
      requirements.txt
      Dockerfile

------------------------------------------------------------------------

# 4. Docker Compose Configuration

Create `docker-compose.yml`

``` yaml
version: "3.9"

services:

  api:
    build: ./api
    ports:
      - "8000:8000"
    depends_on:
      - whisper
      - ollama
      - tts
      - redis

  whisper:
    build: ./whisper
    ports:
      - "5001:5001"

  tts:
    build: ./tts
    ports:
      - "5002:5002"

  ollama:
    image: ollama/ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama:/root/.ollama

  redis:
    image: redis:latest
    ports:
      - "6379:6379"

volumes:
  ollama:
```

------------------------------------------------------------------------

# 5. API Service

### requirements.txt

    fastapi
    uvicorn
    requests
    redis

### Dockerfile

    FROM python:3.10

    WORKDIR /app

    COPY requirements.txt .
    RUN pip install -r requirements.txt

    COPY . .

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

### main.py

``` python
from fastapi import FastAPI
import requests

app = FastAPI()

@app.post("/process")
async def process(audio_url: str):

    stt = requests.post(
        "http://whisper:5001/transcribe",
        json={"audio_url": audio_url}
    )

    text = stt.json()["text"]

    llm = requests.post(
        "http://ollama:11434/api/generate",
        json={
            "model": "mistral",
            "prompt": text
        }
    )

    response_text = llm.json()["response"]

    tts = requests.post(
        "http://tts:5002/speak",
        json={"text": response_text}
    )

    return tts.json()
```

------------------------------------------------------------------------

# 6. Whisper Speech‑to‑Text Service

### requirements.txt

    fastapi
    uvicorn
    openai-whisper

### Dockerfile

    FROM python:3.10

    WORKDIR /app

    RUN apt-get update && apt-get install -y ffmpeg

    COPY requirements.txt .
    RUN pip install -r requirements.txt

    COPY . .

    CMD ["uvicorn", "stt:app", "--host", "0.0.0.0", "--port", "5001"]

### stt.py

``` python
from fastapi import FastAPI
import whisper

app = FastAPI()

model = whisper.load_model("base")

@app.post("/transcribe")
async def transcribe(data: dict):

    audio = data["audio_url"]

    result = model.transcribe(audio)

    return {"text": result["text"]}
```

------------------------------------------------------------------------

# 7. Text‑to‑Speech Service

### requirements.txt

    fastapi
    uvicorn
    TTS

### Dockerfile

    FROM python:3.10

    WORKDIR /app

    COPY requirements.txt .
    RUN pip install -r requirements.txt

    COPY . .

    CMD ["uvicorn", "tts:app", "--host", "0.0.0.0", "--port", "5002"]

### tts.py

``` python
from fastapi import FastAPI
from TTS.api import TTS

app = FastAPI()

tts = TTS(model_name="tts_models/en/ljspeech/tacotron2-DDC")

@app.post("/speak")
async def speak(data: dict):

    text = data["text"]
    file_path = "response.wav"

    tts.tts_to_file(text=text, file_path=file_path)

    return {"audio_file": file_path}
```

------------------------------------------------------------------------

# 8. Start the System

Run:

    docker compose up --build

Containers started:

-   api
-   whisper
-   tts
-   ollama
-   redis

------------------------------------------------------------------------

# 9. Install LLM Model

Enter Ollama container:

    docker exec -it <ollama_container_id> bash

Pull model:

    ollama pull mistral

------------------------------------------------------------------------

# 10. Twilio Integration

Configure webhook.

Twilio console → phone number → voice settings.

Set webhook:

    POST https://your-server/api/process

Twilio will send recorded audio URL.

Your API processes it and returns speech.

------------------------------------------------------------------------

# 11. Example Call Flow

User calls number.

Conversation example:

    User: Hello

    AI: Hello. How can I assist you today?

    User: I want to register a complaint

    AI: Please describe your issue

------------------------------------------------------------------------

# 12. Expected Performance

For prototype hardware:

-   8--16 GB RAM
-   CPU only

Supports:

-   1--5 concurrent calls

Latency:

-   Whisper: 1--3 seconds
-   LLM response: 1--2 seconds
-   TTS: \<1 second

------------------------------------------------------------------------

# 13. Optional Improvements

Add:

-   Streaming speech pipeline
-   Vector database for knowledge retrieval
-   Campaign dialer
-   Human escalation system
-   Call analytics dashboard

------------------------------------------------------------------------

# 14. Deployment Options

You can deploy this system on:

-   AWS EC2
-   DigitalOcean
-   Azure VM
-   Local workstation

Minimum recommended server:

-   4 CPU cores
-   16GB RAM

------------------------------------------------------------------------

# 15. Demo Tips

For presentations:

Prepare demo scenarios:

-   Customer support bot
-   Government grievance helpline
-   Survey agent
-   Appointment reminder bot

This shows the versatility of the system.

------------------------------------------------------------------------

# End of Guide
