from fastapi import FastAPI
from fastapi.responses import FileResponse
from TTS.api import TTS
import os
import uuid

app = FastAPI()

# Load TTS model on startup (downloads on first run)
tts = TTS(model_name="tts_models/en/ljspeech/tacotron2-DDC")

OUTPUT_DIR = "/tmp/tts_output"
os.makedirs(OUTPUT_DIR, exist_ok=True)


@app.get("/")
async def health():
    return {"status": "TTS service running"}


@app.post("/speak")
async def speak(data: dict):
    """
    Accepts text, converts it to speech using Coqui TTS,
    saves to a WAV file, and returns the file path.
    """
    text = data["text"]

    # Use a unique filename to avoid collisions on concurrent calls
    file_name = f"response_{uuid.uuid4().hex}.wav"
    file_path = os.path.join(OUTPUT_DIR, file_name)

    tts.tts_to_file(text=text, file_path=file_path)

    return {"audio_file": file_path}


@app.get("/audio/{file_name}")
async def get_audio(file_name: str):
    """Serve a generated audio file."""
    file_path = os.path.join(OUTPUT_DIR, file_name)
    if os.path.exists(file_path):
        return FileResponse(file_path, media_type="audio/wav")
    return {"error": "File not found"}
