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

# Install PaddleOCR (CPU version) at /app/venv-paddle311 (matches code search path)
RUN python3 -m venv /app/venv-paddle311 && \
    /app/venv-paddle311/bin/pip install --no-cache-dir \
    paddlepaddle \
    paddleocr \
    ocrmypdf \
    ocrmypdf_paddleocr

# Clone and setup local-llm-pdf-ocr (git is still installed here)
RUN git clone --depth 1 https://github.com/Callioper/local-llm-pdf-ocr.git /app/local-llm-pdf-ocr && \
    cd /app/local-llm-pdf-ocr && \
    uv venv && \
    uv pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision && \
    uv pip install surya-ocr transformers pymupdf opencv-python-headless && \
    uv pip install -e .

# Remove git after clone to reduce image size
RUN apt-get purge -y git && apt-get autoremove -y

COPY backend/ ./backend/
COPY config.default.json ./config.default.json

COPY --from=frontend-builder /src/dist ./frontend/dist/

RUN mkdir -p /downloads /finished /tmp/bdw /app/data /db

# Create non-root user
RUN useradd -m -u 1000 app && chown -R app:app /app /downloads /finished /tmp/bdw
USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health || exit 1

ENTRYPOINT ["python", "backend/main.py"]
CMD ["--no-browser"]
