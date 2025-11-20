import os
import sys
from flask import Flask, jsonify, render_template, send_from_directory
from flask_cors import CORS

# Ini memungkinkan kita mengimpor folder 'controllers', 'services', dll.
sys.path.append(os.path.abspath(os.path.dirname(__file__)))

# Impor Config
from config import SECRET_KEY

# Impor Controllers (Blueprints)
from backend.controllers.prediction_controller import prediction_bp
from backend.controllers.auth_controller import auth_bp
from backend.controllers.product_controller import product_bp

# --- 1. INISIALISASI APLIKASI ---
def create_app():
    # Konfigurasi Lokasi FE
    base_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(base_dir)
    frontend_dir = os.path.join(project_root, 'frontend')

    template_dir = os.path.join(frontend_dir, 'pages')   # HTML
    static_dir = os.path.join(frontend_dir, 'assets')

    app = Flask(__name__,
                template_folder=template_dir,
                static_folder=static_dir)
    
    # Konfigurasi aplikasi
    app.config['SECRET_KEY'] = SECRET_KEY
    
    # Atur CORS untuk mengizinkan akses dari frontend
    CORS(app, resources={r"/api/*": {"origins": "*"}}, supports_credentials=True)
    
    print(f"Aplikasi berjalan. Template folder: {template_dir}")

    # --- 2. REGISTRASI BLUEPRINT (CONTROLLER) ---
    # Endpoint Prediksi & Pipeline (/api/v1/recommend, /api/v1/trigger-pipeline)
    app.register_blueprint(prediction_bp, url_prefix='/api/v1')
    # Endpoint Autentikasi (/api/v1/auth/login, /api/v1/auth/register)
    app.register_blueprint(auth_bp, url_prefix='/api/v1/auth')
    # Endpoint Produk (/api/v1/products, /api/v1/simulate-purchase)
    app.register_blueprint(product_bp, url_prefix='/api/v1')
    
    # --- 3. ROUTE ---
    @app.route('/')
    def index():
        return render_template('index.html')
    
    @app.route('/login')
    def login():
        return render_template('login.html')
    
    @app.route('/register')
    def register():
        return render_template('register.html')
    
    @app.route('/products')
    def products():
        return render_template('products.html')
    
    # route asset
    @app.route('/assets/<path:filename>')
    def custom_static(filename):
        return send_from_directory(static_dir, filename)

    return app

# --- 4. RUN APLIKASI ---
if __name__ == '__main__':
    # Gunakan host 0.0.0.0 agar dapat diakses dari luar container/lingkungan
    app = create_app()
    app.run(debug=True, host='0.0.0.0', port=5000)