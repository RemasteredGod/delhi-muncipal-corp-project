from fastapi import FastAPI
import whisper
import requests
import tempfile
import os

app = FastAPI()

# Load Whisper base model on startup (downloads on first run)
model = whisper.load_model("base")


@app.get("/")
async def health():
    return {"status": "Whisper STT service running"}


@app.post("/transcribe")
async def transcribe(data: dict):
    """
    Accepts an audio_url, downloads the audio file,
    transcribes it using Whisper, and returns the text.
    """
    audio_url = data["audio_url"]

    # Download audio to a temp file
    response = requests.get(audio_url, timeout=15)
    suffix = ".mp3" if audio_url.endswith(".mp3") else ".wav"

    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp_file:
        tmp_file.write(response.content)
        tmp_path = tmp_file.name

    try:
        result = model.transcribe(tmp_path)
        text = result["text"].strip()
    finally:
        os.remove(tmp_path)

    return {"text": text}
