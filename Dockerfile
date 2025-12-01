# --- [PERBAIKAN DISINI] ---
# Ganti dari python:3.9-slim ke python:3.10-slim
# Agar support syntax modern "str | None"
FROM python:3.10-slim

# Set folder kerja di dalam container
WORKDIR /app

# Install dependencies sistem
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements dari folder backend
COPY backend/requirements.txt .

# Install library Python
RUN pip install --no-cache-dir -r requirements.txt

# Copy seluruh kode project
COPY . .

# Set PYTHONPATH ke root folder (/app) agar modul 'backend' terbaca
ENV PYTHONPATH=/app

# Expose port
EXPOSE 5000

# Gunakan '-m' untuk menjalankan sebagai modul
CMD ["python", "-m", "backend.app"]