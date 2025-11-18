import psycopg2
from werkzeug.security import generate_password_hash, check_password_hash
from backend.models.database import get_db_connection

class AuthService:
    def register_user(self, firstname, lastname, email, password, customer_id):
        """
        Mendaftarkan pengguna baru dengan password yang di-hash.
        """
        conn = None
        try:
            # 1. Hash Password
            # pbkdf2:sha256 adalah standar industri yang aman
            hashed_password = generate_password_hash(password, method='pbkdf2:sha256')

            conn = get_db_connection()
            cursor = conn.cursor()

            # 2. Query Insert
            sql = """
                INSERT INTO users (customer_id, firstname, lastname, email, password_hash)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (customer_id, firstname, lastname, email, hashed_password))
            conn.commit()
            cursor.close()

            return {"success": True, "message": "Registrasi berhasil!"}

        except psycopg2.IntegrityError:
            # Error ini muncul jika Email atau Customer ID sudah ada (Duplikat)
            if conn: conn.rollback()
            return {"success": False, "error": "Customer ID atau Email sudah terdaftar."}
        except Exception as e:
            if conn: conn.rollback()
            print(f"Register Error: {e}")
            return {"success": False, "error": "Terjadi kesalahan server internal."}
        finally:
            if conn: conn.close()

    def login_user(self, email, password):
        """
        Memverifikasi email dan password pengguna.
        """
        conn = None
        try:
            conn = get_db_connection()
            
            # Gunakan RealDictCursor agar hasil query berupa Dictionary (bukan Tuple)
            # Ini memudahkan kita mengakses user['password_hash']
            cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

            # 1. Cari User berdasarkan Email
            sql = "SELECT * FROM users WHERE email = %s"
            cursor.execute(sql, (email,))
            user = cursor.fetchone()
            cursor.close()

            # 2. Verifikasi Password
            if user and check_password_hash(user['password_hash'], password):
                # Login Sukses
                return {
                    "success": True,
                    "message": "Login berhasil!",
                    "user": {
                        "customer_id": user['customer_id'],
                        "firstname": user['firstname'],
                        "email": user['email']
                    }
                }
            else:
                # Login Gagal
                return {"success": False, "error": "Email atau password salah."}

        except Exception as e:
            print(f"Login Error: {e}")
            return {"success": False, "error": "Terjadi kesalahan server internal."}
        finally:
            if conn: conn.close()

# Import extras untuk RealDictCursor di atas
import psycopg2.extras

# Buat instance agar bisa diimpor controller
auth_service = AuthService()