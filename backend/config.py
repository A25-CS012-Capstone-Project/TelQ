import os
from dotenv import load_dotenv

# Memuat variabel lingkungan dari file .env (opsional, tapi disarankan)
load_dotenv()

# --- 1. Konfigurasi Koneksi Database PostgreSQL ---
# Gunakan variabel lingkungan untuk konfigurasi yang aman di produksi
# Default disetel untuk pengembangan lokal
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "telq_recommender_db")

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# --- 2. Konfigurasi Aplikasi (Flask) ---
SECRET_KEY = os.getenv("SECRET_KEY", "calon_best_capstone")

# --- 3. Konfigurasi ML (Lokasi File) ---
# Lokasi aset ML relatif terhadap folder backend/
ML_MODEL_PATH = "backend/ml/output/xgb_recsys_model.pkl"
ML_COLUMNS_PATH = "backend/ml/output/xgb_model_columns.pkl"

# --- 4. Konfigurasi Data (Untuk populate_db.py) ---
# Lokasi file CSV yang sudah dibersihkan
CLEANED_DATA_PATH = "data/processed/final_dataset_clean.csv"