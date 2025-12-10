import os
import sys
from flask import Flask, jsonify, render_template, send_from_directory
from flask_cors import CORS
from flasgger import Swagger

sys.path.append(os.path.abspath(os.path.dirname(__file__)))

from config import SECRET_KEY

# Impor Controllers
from backend.controllers.prediction_controller import prediction_bp
from backend.controllers.auth_controller import auth_bp
from backend.controllers.product_controller import product_bp
from backend.controllers.user_controller import user_bp 
from backend.controllers.chatbot_controller import chatbot_bp 
from backend.controllers.admin_controller import admin_bp

def create_app():
    # --- 1. SETUP PATH ---
    base_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(base_dir)
    frontend_dir = os.path.join(project_root, 'frontend')

    template_dir = os.path.join(frontend_dir, 'pages')
    static_dir = os.path.join(frontend_dir, 'assets')

    # --- 2. INISIASI APP ---
    app = Flask(__name__,
                template_folder=template_dir,
                static_folder=static_dir)
    
    app.config['SECRET_KEY'] = SECRET_KEY
    
    # Setup CORS
    CORS(app, resources={r"/api/*": {"origins": "*"}}, supports_credentials=True)
    
    print(f"Aplikasi berjalan. Template folder: {template_dir}")

    # --- 3. KONFIGURASI & INISIASI SWAGGER ---
    swagger_config = {
        "headers": [],
        "specs": [
            {
                "endpoint": 'apispec_1',
                "route": '/apispec_1.json',
                "rule_filter": lambda rule: True,  
                "model_filter": lambda tag: True,  
            }
        ],
        "static_url_path": "/flasgger_static",
        "swagger_ui": True,
        "specs_route": "/apidocs/" 
    }
    
    template = {
        "swagger": "2.0",
        "info": {
            "title": "TelQ API Documentation",
            "description": "Dokumentasi API Lengkap untuk Project TelQ",
            "contact": {
                "responsibleOrganization": "A25-CS012",
                "email": "a25-cs012@student.devacademy.id",
            },
            "version": "1.0.0"
        },
        "basePath": "/api/v1",  
        "schemes": [
            "http",
            "https"
        ],
    }

    # Jalankan Swagger
    swagger = Swagger(app, config=swagger_config, template=template)
    # -------------------------------------------------------------

    # --- 4. REGISTRASI BLUEPRINT ---
    app.register_blueprint(prediction_bp, url_prefix='/api/v1')
    app.register_blueprint(auth_bp, url_prefix='/api/v1/auth')
    app.register_blueprint(product_bp, url_prefix='/api/v1')
    app.register_blueprint(user_bp, url_prefix='/api/v1/users')
    app.register_blueprint(chatbot_bp, url_prefix='/api/v1') 
    app.register_blueprint(admin_bp, url_prefix='/api/v1/admin')
    
    # --- 5. ROUTE FRONTEND ---
    @app.route('/')
    def index():
        return render_template('index.html')
    
    @app.route('/admin')
    def admin_dashboard():
        return render_template('admin.html')
    
    @app.route('/login')
    def login():
        return render_template('login.html')
    
    @app.route('/register')
    def register():
        return render_template('register.html')
    
    @app.route('/products')
    def products():
        return render_template('products.html')
    
    @app.route('/profile')
    def profile():
        return render_template('profile.html')
    
    @app.route('/assets/<path:filename>')
    def custom_static(filename):
        return send_from_directory(static_dir, filename)

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host='0.0.0.0', port=7860)