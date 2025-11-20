# Impor library yang diperlukan
import psycopg2
import sys
import os

# Menambahkan direktori backend ke path agar kita dapat mengimpor config dan models
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

from config import DATABASE_URL # Impor URL koneksi dari config.py
from models.database import CREATE_TABLES_SQL, INSERT_PRODUCTS_SQL # Impor SQL dari models/database.py

def create_and_populate_db():
    """
    Menghubungkan ke PostgreSQL dan menjalankan skrip SQL untuk membuat
    skema tabel dan mengisi data produk awal.
    """
    conn = None
    try:
        print("Mencoba menghubungkan ke database...")
        
        # 1. Hubungkan ke database menggunakan URL dari config.py
        conn = psycopg2.connect(DATABASE_URL)
        conn.autocommit = True # Mode autocommit: setiap perintah dieksekusi langsung
        cursor = conn.cursor()
        
        print("Koneksi berhasil. Memulai eksekusi skema tabel...")
        
        # 2. Jalankan Perintah CREATE TABLE
        # Kita menggunakan skrip SQL mentah yang diimpor
        cursor.execute(CREATE_TABLES_SQL)
        print("✅ Sukses membuat tabel (users, products, purchase_history, user_features).")
        
        # 3. Jalankan Perintah INSERT PRODUCTS
        cursor.execute(INSERT_PRODUCTS_SQL)
        print("✅ Sukses mengisi katalog 32 Produk ke tabel 'products'.")
        
        cursor.close()

    except psycopg2.OperationalError as e:
        print("\nFATAL ERROR: Gagal terhubung atau melakukan operasi database.")
        print("--------------------------------------------------------------------")
        print("PASTIKAN:")
        print("1. Server PostgreSQL Anda sedang berjalan.")
        print("2. Detail koneksi di backend/config.py sudah benar.")
        print(f"Detail Error: {e}")
        print("--------------------------------------------------------------------")
    except Exception as e:
        print(f"Terjadi error tak terduga: {e}")
    finally:
        if conn:
            conn.close()
            print("\nKoneksi database ditutup.")

if __name__ == "__main__":
    create_and_populate_db()