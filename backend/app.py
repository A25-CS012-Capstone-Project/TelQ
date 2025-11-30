import os
import sys
from flask import Flask, jsonify, render_template, send_from_directory
from flask_cors import CORS

sys.path.append(os.path.abspath(os.path.dirname(__file__)))

from config import SECRET_KEY

# Impor Controllers
from backend.controllers.prediction_controller import prediction_bp
from backend.controllers.auth_controller import auth_bp
from backend.controllers.product_controller import product_bp
from backend.controllers.user_controller import user_bp 
from backend.controllers.chatbot_controller import chatbot_bp # <--- IMPOR BARU
# from backend.controllers.admin_controller import admin_bp

def create_app():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(base_dir)
    frontend_dir = os.path.join(project_root, 'frontend')

    template_dir = os.path.join(frontend_dir, 'pages')
    static_dir = os.path.join(frontend_dir, 'assets')

    app = Flask(__name__,
                template_folder=template_dir,
                static_folder=static_dir)
    
    app.config['SECRET_KEY'] = SECRET_KEY
    CORS(app, resources={r"/api/*": {"origins": "*"}}, supports_credentials=True)
    
    print(f"Aplikasi berjalan. Template folder: {template_dir}")

    # --- REGISTRASI BLUEPRINT ---
    app.register_blueprint(prediction_bp, url_prefix='/api/v1')
    app.register_blueprint(auth_bp, url_prefix='/api/v1/auth')
    app.register_blueprint(product_bp, url_prefix='/api/v1')
    app.register_blueprint(user_bp, url_prefix='/api/v1/users')
    app.register_blueprint(chatbot_bp, url_prefix='/api/v1') # <--- DAFTAR BARU
    # app.register_blueprint(admin_bp, url_prefix='/api/v1/admin')
    
    # --- ROUTE ---
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
    app.run(debug=True, host='0.0.0.0', port=5000)