import os
import sys
from flask import Flask, jsonify
from flask_cors import CORS

# Tambahkan direktori root backend ke sys.path untuk impor modul lokal
# Ini memungkinkan kita mengimpor folder 'controllers', 'services', dll.
sys.path.append(os.path.abspath(os.path.dirname(__file__)))

# Impor Config
from config import SECRET_KEY

# Impor Controllers (Blueprints)
# Menggunakan absolute import 'backend.controllers...' untuk menghindari konflik namespace
from backend.controllers.prediction_controller import prediction_bp
from backend.controllers.auth_controller import auth_bp
from backend.controllers.product_controller import product_bp

# --- 1. INISIALISASI APLIKASI ---
def create_app():
    app = Flask(__name__)
    
    # Konfigurasi aplikasi
    app.config['SECRET_KEY'] = SECRET_KEY
    
    # Atur CORS untuk mengizinkan akses dari frontend
    # supports_credentials=True penting jika nanti ada cookie/session
    CORS(app, resources={r"/api/*": {"origins": "*"}}, supports_credentials=True)
    
    print("Aplikasi Flask diinisialisasi...")

    # --- 2. REGISTRASI BLUEPRINT (CONTROLLER) ---
    
    # Endpoint Prediksi & Pipeline (/api/v1/recommend, /api/v1/trigger-pipeline)
    app.register_blueprint(prediction_bp, url_prefix='/api/v1')
    
    # Endpoint Autentikasi (/api/v1/auth/login, /api/v1/auth/register)
    app.register_blueprint(auth_bp, url_prefix='/api/v1/auth')
    
    # Endpoint Produk (/api/v1/products, /api/v1/simulate-purchase)
    app.register_blueprint(product_bp, url_prefix='/api/v1')
    
    # --- 3. ENDPOINT STATUS DASAR ---
    @app.route('/')
    def index():
        return jsonify({
            "status": "ok", 
            "message": "TelQ Recommendation API is running!",
            "version": "1.0"
        })

    return app

# --- 4. RUN APLIKASI ---
if __name__ == '__main__':
    # Gunakan host 0.0.0.0 agar dapat diakses dari luar container/lingkungan
    app = create_app()
    app.run(debug=True, host='0.0.0.0', port=5000)