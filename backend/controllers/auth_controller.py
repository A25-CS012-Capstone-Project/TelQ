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
        return jsonify(result), 409 # 409 Conflict (jika duplikat)

@auth_bp.route('/login', methods=['POST'])
def login():
    """
    Endpoint: POST /api/v1/auth/login
    Body: {email, password}
    """
    data = request.get_json()

    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Email dan password wajib diisi"}), 400

    # Panggil Service
    result = auth_service.login_user(
        email=data.get('email'),
        password=data.get('password')
    )

    if result['success']:
        return jsonify(result), 200
    else:
        return jsonify(result), 401 # 401 Unauthorized