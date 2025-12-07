from flask import Blueprint, request, jsonify
from backend.services.auth_service import auth_service

# Buat Blueprint untuk Auth
auth_bp = Blueprint('auth_bp', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Mendaftarkan Pengguna Baru
    ---
    tags:
      - Authentication
    parameters:
      - in: body
        name: body
        required: true
        description: Data pendaftaran pengguna baru
        schema:
          type: object
          required:
            - firstname
            - email
            - password
            - customer_id
          properties:
            firstname:
              type: string
              example: Budi
            lastname:
              type: string
              example: Santoso
            email:
              type: string
              example: budi@example.com
            password:
              type: string
              example: rahasia123
            customer_id:
              type: string
              example: CUST-001
    responses:
      201:
        description: Registrasi Berhasil
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            message:
              type: string
              example: User registered successfully
      400:
        description: Data Tidak Lengkap
      409:
        description: Email/ID Sudah Terdaftar
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
    Login Pengguna (User/Admin)
    ---
    tags:
      - Authentication
    parameters:
      - in: body
        name: body
        required: true
        description: Kredensial login
        schema:
          type: object
          required:
            - email
            - password
          properties:
            email:
              type: string
              example: admin@super.com
            password:
              type: string
              example: admin123
    responses:
      200:
        description: Login Berhasil
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            message:
              type: string
            user:
              type: object
              properties:
                firstname:
                  type: string
                role:
                  type: string
                  example: admin
      401:
        description: Password/Email Salah
    """
    data = request.get_json()

    # Validasi Input
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Email dan password wajib diisi"}), 400
    
    email_input = data.get('email')
    password_input = data.get('password')

    # 1. CEK KHUSUS ADMIN 
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

    # 2. LOGIN USER BIASA 
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