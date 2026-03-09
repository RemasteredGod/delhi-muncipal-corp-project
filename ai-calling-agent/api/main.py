from fastapi import FastAPI, Form, Request
from fastapi.responses import Response
from twilio.twiml.voice_response import VoiceResponse, Record
import requests
import redis
import os

app = FastAPI()

redis_client = redis.Redis(host="redis", port=6379, decode_responses=True)


@app.get("/")
async def health():
    return {"status": "AI Calling Agent is running"}


@app.post("/process")
async def process(audio_url: str):
    """
    Main processing endpoint.
    Accepts an audio URL, transcribes it, generates an LLM response,
    and converts the response back to speech.
    """
    # Step 1 – Speech to Text
    stt = requests.post(
        "http://whisper:5001/transcribe",
        json={"audio_url": audio_url}
    )
    text = stt.json()["text"]

    # Step 2 – LLM Conversation Generation
    llm = requests.post(
        "http://ollama:11434/api/generate",
        json={
            "model": "mistral",
            "prompt": text,
            "stream": False
        }
    )
    response_text = llm.json()["response"]

    # Step 3 – Text to Speech
    tts = requests.post(
        "http://tts:5002/speak",
        json={"text": response_text}
    )

    return tts.json()


@app.post("/twilio/incoming")
async def twilio_incoming(request: Request):
    """
    Twilio webhook for inbound calls.
    Greets caller and starts recording.
    """
    response = VoiceResponse()
    response.say(
        "Hello. Welcome to Delhi Municipal Corporation helpline. "
        "Please speak your query after the beep.",
        voice="alice"
    )
    response.record(
        max_length=30,
        action="/twilio/handle-recording",
        method="POST",
        play_beep=True
    )
    return Response(content=str(response), media_type="application/xml")


@app.post("/twilio/handle-recording")
async def handle_recording(
    RecordingUrl: str = Form(...),
    CallSid: str = Form(...)
):
    """
    Twilio sends the recording URL here after the caller speaks.
    Processes the audio and responds via TwiML.
    """
    # Append .mp3 so Whisper can download it correctly
    audio_url = RecordingUrl + ".mp3"

    # Step 1 – Speech to Text
    stt = requests.post(
        "http://whisper:5001/transcribe",
        json={"audio_url": audio_url}
    )
    text = stt.json().get("text", "")

    # Store conversation in Redis
    redis_client.rpush(f"call:{CallSid}", f"User: {text}")

    # Step 2 – LLM Conversation Generation
    system_prompt = (
        "You are a helpful AI assistant for Delhi Municipal Corporation. "
        "Answer citizen queries about property tax, water supply, "
        "garbage collection, complaints, and permits. "
        "Be concise and speak in simple English."
    )

    llm = requests.post(
        "http://ollama:11434/api/generate",
        json={
            "model": "mistral",
            "prompt": f"{system_prompt}\n\nCitizen: {text}\nAssistant:",
            "stream": False
        }
    )
    response_text = llm.json().get("response", "I am sorry, I could not understand. Please try again.")

    # Store AI reply in Redis
    redis_client.rpush(f"call:{CallSid}", f"AI: {response_text}")

    # Step 3 – Build TwiML response
    twiml = VoiceResponse()
    twiml.say(response_text, voice="alice")
    twiml.record(
        max_length=30,
        action="/twilio/handle-recording",
        method="POST",
        play_beep=True
    )

    return Response(content=str(twiml), media_type="application/xml")


@app.get("/call-history/{call_sid}")
async def call_history(call_sid: str):
    """Retrieve conversation history for a given call."""
    history = redis_client.lrange(f"call:{call_sid}", 0, -1)
    return {"call_sid": call_sid, "history": history}
