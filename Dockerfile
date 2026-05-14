# Stage 1: Build frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /src
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Stage 2: Runtime
FROM python:3.11-slim-bookworm

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-chi-sim \
    tesseract-ocr-eng \
    ghostscript \
    fonts-noto-cjk \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV DOCKER=true

RUN pip install --no-cache-dir uv

WORKDIR /app

COPY backend/requirements.txt ./backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt

# Install PaddleOCR (CPU version) in a venv for the pipeline to discover
RUN python3 -m venv /app/backend/venv-paddle311 && \
    /app/backend/venv-paddle311/bin/pip install --no-cache-dir \
    paddlepaddle \
    paddleocr \
    ocrmypdf \
    ocrmypdf_paddleocr

# Clone and setup local-llm-pdf-ocr
RUN git clone --depth 1 https://github.com/Callioper/local-llm-pdf-ocr.git /app/local-llm-pdf-ocr && \
    cd /app/local-llm-pdf-ocr && \
    uv sync || echo "uv sync warning: continuing"

COPY backend/ ./backend/
COPY config.default.json ./config.default.json

COPY --from=frontend-builder /src/dist ./frontend/dist/

RUN mkdir -p /downloads /finished /tmp/bdw

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api/v1/health')" || exit 1

ENTRYPOINT ["python", "backend/main.py", "--no-browser"]
