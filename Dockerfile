# Gunakan Python 3.10 (Support syntax modern)
FROM python:3.10-slim

# Set folder kerja
WORKDIR /app

# Install dependencies sistem (sebagai root)
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# --- [KHUSUS HUGGING FACE] ---
# Buat user baru dengan ID 1000 karena HF tidak mengizinkan root
RUN useradd -m -u 1000 user

# Pindah ke user tersebut
USER user

# Set Path agar command python/pip terbaca
ENV PATH="/home/user/.local/bin:$PATH"

# Copy requirements dengan kepemilikan user
COPY --chown=user backend/requirements.txt requirements.txt

# Install library Python (sebagai user)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy seluruh kode project dengan kepemilikan user
COPY --chown=user . .

# Set PYTHONPATH ke root folder (/app)
ENV PYTHONPATH=/app

# --- [KHUSUS HUGGING FACE] ---
# Wajib expose port 7860 (Bukan 5000)
EXPOSE 7860

# Jalankan aplikasi sebagai modul
CMD ["python", "-m", "backend.app"]