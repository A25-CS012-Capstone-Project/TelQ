"""
File ini berisi skema SQL untuk inisiasi database PostgreSQL,
ditambah helper koneksi Python.
"""
import psycopg2
import os
import sys

# Tambahkan direktori root backend ke sys.path untuk impor config
# Karena file ini dipanggil dari luar backend/
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
from backend.config import DATABASE_URL

# =================================================================
# FUNGSI HELPER PYTHON UNTUK KONEKSI
# =================================================================
def get_db_connection():
    """Mengembalikan objek koneksi psycopg2 baru menggunakan DATABASE_URL."""
    try:
        conn = psycopg2.connect(DATABASE_URL)
        return conn
    except Exception as e:
        print(f"❌ Error Connection: {e}")
        sys.exit(1)

# =================================================================
# DEFINISI SKEMA DAN DATA INSERSI (SQL MENTAH)
# =================================================================

CREATE_TABLES_SQL = """
-- Hapus tabel jika sudah ada (untuk reset/testing)
DROP TABLE IF EXISTS user_features CASCADE;
DROP TABLE IF EXISTS purchase_history CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. TABEL USERS
CREATE TABLE users (
    customer_id VARCHAR(50) PRIMARY KEY,
    firstname VARCHAR(100) NOT NULL,
    lastname VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(128) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABEL PRODUCTS (Katalog Induk Final)
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price INTEGER NOT NULL,
    duration_days INTEGER NOT NULL,
    data_gb INTEGER NOT NULL,
    streaming_gb_bonus INTEGER NOT NULL DEFAULT 0,
    gaming_gb_bonus INTEGER NOT NULL DEFAULT 0,
    social_gb_bonus INTEGER NOT NULL DEFAULT 0,
    call_minutes_bonus INTEGER NOT NULL DEFAULT 0,
    sms_bonus INTEGER NOT NULL DEFAULT 0,
    roaming_days_bonus INTEGER NOT NULL DEFAULT 0,
    target_offer VARCHAR(50) NOT NULL
);

-- 3. TABEL PURCHASE_HISTORY
CREATE TABLE purchase_history (
    history_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL REFERENCES users(customer_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    purchase_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. TABEL USER_FEATURES (Profil Warm Start)
CREATE TABLE user_features (
    customer_id VARCHAR(50) PRIMARY KEY REFERENCES users(customer_id) ON DELETE CASCADE,
    
    plan_type VARCHAR(50) NOT NULL,
    device_brand VARCHAR(50) NOT NULL,
    
    avg_data_usage_gb FLOAT NOT NULL,
    pct_video_usage FLOAT NOT NULL,
    avg_call_duration FLOAT NOT NULL,
    sms_freq INTEGER NOT NULL,
    monthly_spend FLOAT NOT NULL,
    topup_freq INTEGER NOT NULL,
    travel_score FLOAT NOT NULL,
    complain_count INTEGER NOT NULL,
    spending_tier VARCHAR(10) NOT NULL
);
"""

INSERT_PRODUCTS_SQL = """
INSERT INTO products (
    product_id,
    product_name,
    price,
    duration_days,
    data_gb,
    streaming_gb_bonus,
    gaming_gb_bonus,
    social_gb_bonus,
    call_minutes_bonus,
    sms_bonus,
    roaming_days_bonus,
    target_offer
) VALUES
(1, 'Data Pure Harian 1GB', 6000, 1, 1, 0, 0, 0, 0, 0, 0, 'General Offer'),
(2, 'Data Pure 3GB', 15000, 30, 3, 0, 0, 0, 0, 0, 0, 'General Offer'),
(3, 'Data Pure 5GB', 25000, 30, 5, 0, 0, 0, 0, 0, 0, 'General Offer'),
(4, 'Data Pure 10GB', 45000, 30, 10, 0, 0, 0, 0, 0, 0, 'General Offer'),
(5, 'Data Maxi 20GB', 80000, 30, 20, 0, 0, 0, 0, 0, 0, 'General Offer'),
(6, 'StreamMax Harian 3GB (1+2)', 10000, 1, 1, 2, 0, 0, 0, 0, 0, 'Streaming Offer'),
(7, 'StreamMax 20GB (10+10)', 65000, 30, 10, 10, 0, 0, 0, 0, 0, 'Streaming Offer'),
(8, 'StreamMax 40GB (15+25)', 100000, 30, 15, 25, 0, 0, 0, 0, 0, 'Streaming Offer'),
(9, 'VideoPass 15GB (5+10)', 55000, 30, 5, 10, 0, 0, 0, 0, 0, 'Streaming Offer'),
(10, 'VideoPass 60GB (20+40)', 150000, 30, 20, 40, 0, 0, 0, 0, 0, 'Streaming Offer'),
(11, 'Ngobrol Irit 2GB (200mnt)', 25000, 7, 2, 0, 0, 0, 200, 50, 0, 'Voice Offer'),
(12, 'Ngobrol Juara 5GB (500mnt)', 45000, 30, 5, 0, 0, 0, 500, 100, 0, 'Voice Offer'),
(13, 'Ngobrol Puas 8GB (1000mnt)', 70000, 30, 8, 0, 0, 0, 1000, 200, 0, 'Voice Offer'),
(14, 'TalkMax Bulanan 12GB (1500mnt)', 95000, 30, 12, 0, 0, 0, 1500, 300, 0, 'Voice Offer'),
(15, 'Roaming Asia 3 Hari 3GB', 130000, 3, 3, 0, 0, 0, 0, 0, 3, 'Roaming Offer'),
(16, 'Roaming Asia 7 Hari 7GB', 200000, 7, 7, 0, 0, 0, 0, 0, 7, 'Roaming Offer'),
(17, 'Roaming Dunia 5 Hari 10GB', 280000, 5, 10, 0, 0, 0, 0, 0, 5, 'Roaming Offer'),
(18, 'Roaming Dunia 10 Hari 20GB', 400000, 10, 20, 0, 0, 0, 0, 0, 10, 'Roaming Offer'),
(19, 'SocmedFun Harian 3GB (1+2)', 9000, 1, 1, 0, 0, 2, 0, 0, 0, 'Social Offer'),
(20, 'SocmedFun 10GB (5+5)', 40000, 30, 5, 0, 0, 5, 0, 0, 0, 'Social Offer'),
(21, 'SocmedFun 25GB (10+15)', 75000, 30, 10, 0, 0, 15, 0, 0, 0, 'Social Offer'),
(22, 'SocmedMax 40GB (15+25)', 110000, 30, 15, 0, 0, 25, 0, 0, 0, 'Social Offer'),
(23, 'Super Plan 50GB All-in-One', 160000, 30, 50, 10, 10, 10, 500, 200, 3, 'Premium Offer');
"""

# =================================================================
# BAGIAN EKSEKUSI (Jalankan ini agar tabel terbuat)
# =================================================================
def init_db():
    """Fungsi untuk menjalankan Query SQL ke Database."""
    conn = None
    try:
        print(f"🔄 Menghubungkan ke database via: {DATABASE_URL}")
        conn = get_db_connection()
        cur = conn.cursor()

        print("🔨 (1/2) Membuat tabel (DROP & CREATE)...")
        cur.execute(CREATE_TABLES_SQL)
        
        print("📦 (2/2) Mengisi data produk awal...")
        cur.execute(INSERT_PRODUCTS_SQL)

        # COMMIT adalah langkah terpenting! Tanpa ini data tidak tersimpan.
        conn.commit()
        
        print("\n✅ SUKSES: Database berhasil diinisialisasi!")
        print("   - Tabel created: users, products, purchase_history, user_features")
        print("   - Data: 23 Produk berhasil dimasukkan.")
        
        cur.close()
    except Exception as e:
        print(f"\n❌ GAGAL: Terjadi kesalahan saat inisialisasi database.")
        print(f"Pesan Error: {e}")
        if conn:
            conn.rollback()
    finally:
        if conn:
            conn.close()
            print("🔌 Koneksi database ditutup.")

if __name__ == "__main__":
    # Kode di bawah ini hanya jalan jika file dipanggil langsung: python database.py
    init_db()