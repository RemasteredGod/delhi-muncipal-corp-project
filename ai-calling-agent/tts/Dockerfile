FROM python:3.10

WORKDIR /app

RUN apt-get update && apt-get install -y espeak-ng libsndfile1

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["uvicorn", "tts:app", "--host", "0.0.0.0", "--port", "5002"]
