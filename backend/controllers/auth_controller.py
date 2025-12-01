from flask import Blueprint, request, jsonify
from backend.services.auth_service import auth_service

# Buat Blueprint untuk Auth
auth_bp = Blueprint('auth_bp', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Endpoint: POST /api/v1/auth/register
    Body: {firstname, lastname, email, password, customer_id}
    """
    data = request.get_json()
    
    # Validasi Input Sederhana
    if not data or not data.get('email') or not data.get('password') or not data.get('customer_id'):
        return jsonify({"error": "Data tidak lengkap (Email, Password, Customer ID wajib)"}), 400

    # Panggil Service
    result = auth_service.register_user(
        firstname=data.get('firstname'),
        lastname=data.get('lastname', ''),
        email=data.get('email'),
        password=data.get('password'),
        customer_id=data.get('customer_id')
    )

    if result['success']:
        return jsonify(result), 201
    else:
        return jsonify(result), 409 

@auth_bp.route('/login', methods=['POST'])
def login():
    """
    Endpoint: POST /api/v1/auth/login
    Body: {email, password}
    """
    data = request.get_json()

    # Validasi Input
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Email dan password wajib diisi"}), 400
    
    email_input = data.get('email')
    password_input = data.get('password')

    # =========================================================
    # 1. CEK KHUSUS ADMIN (Hardcoded Credentials)
    # =========================================================
    if email_input == 'admin@super.com' and password_input == 'admin123':
        return jsonify({
            "success": True,
            "message": "Login Admin Berhasil",
            "user": {
                "firstname": "Super Admin",
                "lastname": "(Administrator)",
                "email": email_input,
                "customer_id": "ADMIN-001",
                "role": "admin" 
            }
        }), 200

    # =========================================================
    # 2. LOGIN USER BIASA (Via Database Service)
    # =========================================================
    result = auth_service.login_user(
        email=email_input,
        password=password_input
    )

    if result['success']:
        if 'user' in result:
            result['user']['role'] = 'user'
            
        return jsonify(result), 200
    else:
        return jsonify(result), 401 