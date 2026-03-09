from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import whisper
import requests
from requests.auth import HTTPBasicAuth
import tempfile
import os
from dotenv import load_dotenv

# Load environment variables from parent directory
env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(env_path)

app = FastAPI()

# Add CORS middleware to allow frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load Whisper base model on startup (downloads on first run)
model = whisper.load_model("base")

# Get Twilio credentials from environment
TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN")


@app.get("/")
async def health():
    return {"status": "Whisper STT service running"}


@app.post("/transcribe")
async def transcribe(data: dict):
    """
    Accepts an audio_url, downloads the audio file from Twilio (with auth),
    transcribes it using Whisper, and returns the text.
    """
    audio_url = data["audio_url"]

    try:
        # Download audio from Twilio with authentication
        # Twilio recordings require HTTP Basic Auth
        if "api.twilio.com" in audio_url:
            response = requests.get(
                audio_url,
                auth=HTTPBasicAuth(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN),
                timeout=30
            )
        else:
            # For non-Twilio URLs, try without auth
            response = requests.get(audio_url, timeout=30)
        
        if response.status_code != 200:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to download audio: HTTP {response.status_code}"
            )
        
        # Check if we got valid audio data
        if len(response.content) < 100:
            raise HTTPException(
                status_code=500,
                detail="Downloaded audio file is too small or empty"
            )
        
        suffix = ".mp3" if audio_url.endswith(".mp3") else ".wav"

        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp_file:
            tmp_file.write(response.content)
            tmp_path = tmp_file.name

        try:
            # Transcribe with fp16=False for CPU compatibility
            result = model.transcribe(tmp_path, fp16=False)
            text = result["text"].strip()
            
            if not text:
                return {"text": "[silence]"}
                
        finally:
            # Clean up temp file
            if os.path.exists(tmp_path):
                os.remove(tmp_path)

        return {"text": text}
        
    except Exception as e:
        print(f"Transcription error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Transcription failed: {str(e)}"
        )


@app.post("/transcribe-file")
async def transcribe_file(audio_file: UploadFile = File(...)):
    """
    Accepts an uploaded audio file directly from browser,
    transcribes it using Whisper, and returns the text.
    """
    try:
        # Save uploaded file to temporary location
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp_file:
            content = await audio_file.read()
            tmp_file.write(content)
            tmp_path = tmp_file.name
        
        try:
            # Transcribe with fp16=False for CPU compatibility
            result = model.transcribe(tmp_path, fp16=False)
            text = result["text"].strip()
            
            if not text:
                return {"text": "[silence]"}
                
            return {"text": text}
                
        finally:
            # Clean up temp file
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
        
    except Exception as e:
        print(f"File transcription error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"File transcription failed: {str(e)}"
        )
