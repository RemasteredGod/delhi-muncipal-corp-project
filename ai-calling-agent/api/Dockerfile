FROM python:3.10

WORKDIR /app

# Copy API requirements and install
COPY api/requirements.txt .
RUN pip install -r requirements.txt

# Copy API code
COPY api/ .

# Copy frontend files
COPY frontend/ /app/frontend/

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
