import os
from dotenv import load_dotenv

# ======================================================================
# 0. Lokasi Project & .env
# ======================================================================

# Folder backend/
BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))

# Root project (sejajar dengan backend/, frontend/, data/)
BASE_DIR = os.path.dirname(BACKEND_DIR)

# Load .env di root project (TELQ-CAPSTONE/.env)
ENV_PATH = os.path.join(BASE_DIR, ".env")
load_dotenv(ENV_PATH)

# (Opsional) kalau kamu juga punya .env di backend/, ini akan meload juga
ENV_PATH_BACKEND = os.path.join(BACKEND_DIR, ".env")
if os.path.exists(ENV_PATH_BACKEND):
    load_dotenv(ENV_PATH_BACKEND)

# ======================================================================
# 1. Konfigurasi Koneksi Database PostgreSQL
#    -> SELALU bangun dari DB_USER/DB_PASSWORD, abaikan DATABASE_URL env
# ======================================================================

DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "telq_recommender_db")

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Debug sementara: cek string yang dipakai (boleh dihapus nanti)
print(f"[CONFIG] DATABASE_URL in use: {DATABASE_URL}")

# ======================================================================
# 2. Konfigurasi Aplikasi (Flask)
# ======================================================================

SECRET_KEY = os.getenv("SECRET_KEY", "calon_best_capstone")

# ======================================================================
# 3. Konfigurasi ML (Lokasi File Model & Feature Columns)
# ======================================================================

# ML_MODEL_PATH = os.getenv(
#     "ML_MODEL_PATH",
#     os.path.join(BACKEND_DIR, "ml", "output", "randomforestv1", "rf_telco_model.pkl"),
# )

# ML_COLUMNS_PATH = os.getenv(
#     "ML_COLUMNS_PATH",
#     os.path.join(BACKEND_DIR, "ml", "output", "randomforestv1", "rf_feature_columns.pkl"),
# )

# ML_MODEL_PATH = os.getenv(
#     "ML_MODEL_PATH",
#     os.path.join(BACKEND_DIR, "ml", "output", "randomforest_v2", "rf_telco_model_v2.pkl"),
# )

# ML_COLUMNS_PATH = os.getenv(
#     "ML_COLUMNS_PATH",
#     os.path.join(BACKEND_DIR, "ml", "output", "randomforest_v2", "rf_feature_columns_v2.pkl"),
# )

# ML_MODEL_PATH = os.getenv(
#     "ML_MODEL_PATH",
#     os.path.join(BACKEND_DIR, "ml", "output", "dataset_70_20_10", "xgb_recsys_model.pkl"),
# )

# ML_COLUMNS_PATH = os.getenv(
#     "ML_COLUMNS_PATH",
#     os.path.join(BACKEND_DIR, "ml", "output", "dataset_70_20_10", "xgb_model_columns.pkl"),
# )

ML_MODEL_PATH = os.getenv(
    "ML_MODEL_PATH",
    os.path.join(BACKEND_DIR, "ml", "output", "XGBoost_v3_25Nov2025", "xgb_telco_optimal_v1.pkl"),
)

ML_COLUMNS_PATH = os.getenv(    
    "ML_COLUMNS_PATH",
    os.path.join(BACKEND_DIR, "ml", "output", "XGBoost_v3_25Nov2025", "xgb_feature_columns_v1.pkl"),
)

# ML_MODEL_PATH = os.getenv(
#     "ML_MODEL_PATH",
#     os.path.join(BACKEND_DIR, "ml", "output", "logistic_regression_recommendation", "logistic_regression_recommendation.pkl"),
# )

# ML_COLUMNS_PATH = os.getenv(    
#     "ML_COLUMNS_PATH",
#     os.path.join(BACKEND_DIR, "ml", "output", "logistic_regression_recommendation", "lr_feature_columns.pkl"),
# )

# ======================================================================
# 4. Konfigurasi Data (Untuk populate_db.py, dsb.)
# ======================================================================

CLEANED_DATA_PATH = os.getenv(
    "CLEANED_DATA_PATH",
    os.path.join(BASE_DIR, "data", "datasets", "processed", "final_dataset_clean.csv"),
)

# ======================================================================
# 5. Konfigurasi Gemini / Chatbot
# ======================================================================

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
