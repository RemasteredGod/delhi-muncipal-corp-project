from fastapi import FastAPI, Form, Request, HTTPException, File, UploadFile
from fastapi.responses import Response, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from twilio.twiml.voice_response import VoiceResponse, Record
from twilio.rest import Client
import requests
import redis
import os
import tempfile
import shutil
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI()

# Add CORS middleware to allow frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount the frontend static files
import os
frontend_path = os.path.join(os.path.dirname(__file__), "..", "frontend")
frontend_path = os.path.abspath(frontend_path)
if os.path.exists(frontend_path):
    app.mount("/dashboard", StaticFiles(directory=frontend_path, html=True), name="dashboard")
    app.mount("/frontend", StaticFiles(directory=frontend_path, html=True), name="frontend")
    print(f"✅ Frontend mounted from: {frontend_path}")
else:
    print(f"❌ WARNING: Frontend path not found at {frontend_path}")

# Redis connection - try Docker name first, fallback to localhost
try:
    redis_client = redis.Redis(host="redis", port=6379, decode_responses=True, socket_connect_timeout=1)
    redis_client.ping()
    print("✅ Connected to Redis (Docker)")
except:
    redis_client = redis.Redis(host="localhost", port=6379, decode_responses=True)
    try:
        redis_client.ping()
        print("✅ Connected to Redis (localhost)")
    except:
        print("❌ WARNING: Redis connection failed!")

# Initialize Twilio client for outbound calls
TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN")
TWILIO_PHONE_NUMBER = os.getenv("TWILIO_PHONE_NUMBER")

if TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN:
    twilio_client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
    print(f"✅ Twilio client initialized with number: {TWILIO_PHONE_NUMBER}")
else:
    twilio_client = None
    print("❌ WARNING: Twilio credentials not found!")


@app.get("/")
async def health():
    return {"status": "AI Calling Agent is running"}


@app.post("/upload-audio")
async def upload_audio(audio: UploadFile = File(...)):
    """
    Upload audio from browser for transcription
    """
    try:
        # Save uploaded audio to temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
            shutil.copyfileobj(audio.file, temp_audio)
            temp_path = temp_audio.name
        
        # Send to Whisper STT service
        with open(temp_path, 'rb') as f:
            files = {'audio_file': ('audio.wav', f, 'audio/wav')}
            stt_response = requests.post(
                "http://localhost:5001/transcribe-file",
                files=files,
                timeout=30
            )
        
        # Clean up temp file
        os.unlink(temp_path)
        
        if stt_response.status_code == 200:
            transcription = stt_response.json().get('text', '')
            return {"success": True, "transcription": transcription}
        else:
            return {"success": False, "error": "Transcription failed"}
            
    except Exception as e:
        return {"success": False, "error": str(e)}


@app.post("/process")
async def process(audio_url: str):
    """
    Main processing endpoint.
    Accepts an audio URL, transcribes it, generates an LLM response,
    and converts the response back to speech.
    """
    # Step 1 – Speech to Text
    stt = requests.post(
        "http://localhost:5001/transcribe",
        json={"audio_url": audio_url}
    )
    text = stt.json()["text"]

    # Step 2 – LLM Conversation Generation
    llm = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "gemma2:2b",
            "prompt": text,
            "stream": False
        }
    )
    response_text = llm.json()["response"]

    # Step 3 – Text to Speech
    tts = requests.post(
        "http://localhost:5002/speak",
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
    twiml = VoiceResponse()
    
    try:
        # Append .mp3 so Whisper can download it correctly
        audio_url = RecordingUrl + ".mp3"

        # Step 1 – Speech to Text
        try:
            stt = requests.post(
                "http://localhost:5001/transcribe",
                json={"audio_url": audio_url},
                timeout=10
            )
            text = stt.json().get("text", "")
            
            if not text or text.strip() == "":
                redis_client.rpush(f"call:{CallSid}", "User: [No speech detected]")
                twiml.say("I did not hear anything. Please speak your query after the beep.", voice="alice")
                twiml.record(
                    max_length=30,
                    action="/twilio/handle-recording",
                    method="POST",
                    play_beep=True
                )
                return Response(content=str(twiml), media_type="application/xml")
                
        except Exception as stt_error:
            error_msg = f"STT Service Error: {str(stt_error)}"
            redis_client.rpush(f"call:{CallSid}", f"System Error: {error_msg}")
            twiml.say(
                "I am experiencing technical difficulties with speech recognition. "
                "Please try again later or contact support.",
                voice="alice"
            )
            twiml.hangup()
            return Response(content=str(twiml), media_type="application/xml")

        # Store user speech in Redis
        redis_client.rpush(f"call:{CallSid}", f"User: {text}")

        # Step 2 – LLM Conversation Generation
        try:
            system_prompt = (
                "You are a helpful AI assistant for Delhi Municipal Corporation. "
                "Answer citizen queries about property tax, water supply, "
                "garbage collection, complaints, and permits. "
                "Be concise and speak in simple English. Keep responses under 50 words."
            )

            llm = requests.post(
                "http://localhost:11434/api/generate",
                json={
                    "model": "gemma2:2b",
                    "prompt": f"{system_prompt}\n\nCitizen: {text}\nAssistant:",
                    "stream": False
                },
                timeout=30
            )
            response_text = llm.json().get("response", "I am sorry, I could not process your query. Please try again.")
            
        except Exception as llm_error:
            error_msg = f"LLM Service Error: {str(llm_error)}"
            redis_client.rpush(f"call:{CallSid}", f"System Error: {error_msg}")
            response_text = "I am experiencing technical difficulties. Please call back later."

        # Store AI reply in Redis
        redis_client.rpush(f"call:{CallSid}", f"AI: {response_text}")

        # Step 3 – Build TwiML response
        twiml.say(response_text, voice="alice")
        twiml.record(
            max_length=30,
            action="/twilio/handle-recording",
            method="POST",
            play_beep=True
        )

        return Response(content=str(twiml), media_type="application/xml")
        
    except Exception as e:
        # Catch-all for any unexpected errors
        redis_client.rpush(f"call:{CallSid}", f"Critical Error: {str(e)}")
        twiml.say("An unexpected error occurred. Please try again later.", voice="alice")
        twiml.hangup()
        return Response(content=str(twiml), media_type="application/xml")


@app.get("/call-history/{call_sid}")
async def call_history(call_sid: str):
    """Retrieve conversation history for a given call."""
    history = redis_client.lrange(f"call:{call_sid}", 0, -1)
    return {"call_sid": call_sid, "history": history}


@app.get("/calls")
async def get_all_calls():
    """Get all call sessions stored in Redis."""
    keys = redis_client.keys("call:*")
    calls = []
    for key in keys:
        call_sid = key.replace("call:", "")
        history = redis_client.lrange(key, 0, -1)
        calls.append({
            "call_sid": call_sid,
            "message_count": len(history),
            "last_message": history[-1] if history else None
        })
    return {"active_calls": len(calls), "calls": calls}


@app.get("/calls/{call_sid}")
async def get_call_detail(call_sid: str):
    """Get detailed conversation history for a specific call."""
    history = redis_client.lrange(f"call:{call_sid}", 0, -1)
    if not history:
        return {"error": "Call not found"}
    return {
        "call_sid": call_sid,
        "conversation": history
    }


@app.post("/twilio/call-status")
async def call_status(request: Request):
    """Track call status changes."""
    form = await request.form()
    call_sid = form.get("CallSid")
    call_status = form.get("CallStatus")
    
    # Store call status in Redis
    if call_status == "completed":
        redis_client.setex(f"status:{call_sid}", 3600, "completed")
    
    return {"status": "ok"}


@app.post("/initiate-call")
async def initiate_call(request: Request):
    """Initiate an outbound call to a phone number."""
    if not twilio_client:
        raise HTTPException(status_code=500, detail="Twilio client not initialized. Check your .env file.")
    
    data = await request.json()
    to_number = data.get("to_number")
    
    if not to_number:
        raise HTTPException(status_code=400, detail="Phone number is required")
    
    try:
        # Get the ngrok URL from environment or use localhost
        base_url = os.getenv("BASE_URL", "http://localhost:8000")
        
        # Check if using localhost and warn user
        if "localhost" in base_url or "127.0.0.1" in base_url:
            raise HTTPException(
                status_code=400, 
                detail="BASE_URL must be a public URL (not localhost). Please set up ngrok: 'ngrok http 8000' then set BASE_URL environment variable to your ngrok URL."
            )
        
        call = twilio_client.calls.create(
            to=to_number,
            from_=TWILIO_PHONE_NUMBER,
            url=f"{base_url}/twilio/incoming",
            status_callback=f"{base_url}/twilio/call-status",
            status_callback_event=["initiated", "ringing", "answered", "completed"]
        )
        
        # Store call initiation in Redis
        redis_client.rpush(f"call:{call.sid}", f"System: Outbound call initiated to {to_number}")
        redis_client.setex(f"status:{call.sid}:initiated", 3600, "true")
        
        return {
            "success": True,
            "call_sid": call.sid,
            "to": to_number,
            "status": call.status,
            "message": "Call initiated successfully"
        }
    except HTTPException:
        raise
    except Exception as e:
        error_msg = str(e)
        # Extract cleaner error message from Twilio errors
        if "Unable to create record" in error_msg:
            error_msg = "Twilio error: You need a public URL. Set up ngrok: 'ngrok http 8000' and set BASE_URL environment variable."
        raise HTTPException(status_code=500, detail=error_msg)
