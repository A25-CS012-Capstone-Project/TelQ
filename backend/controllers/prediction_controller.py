from flask import Blueprint, request, jsonify
from backend.services.prediction_service import prediction_service

# 1. Definisi Blueprint (Ini yang dicari oleh app.py)
prediction_bp = Blueprint('prediction_bp', __name__)

# 2. Route: Mendapatkan Rekomendasi
@prediction_bp.route('/recommend', methods=['GET', 'POST'])
def recommend():
    """
    Mendapatkan Rekomendasi Personal (AI)
    ---
    tags:
      - Recommendation AI
    parameters:
      - in: body
        name: body
        required: true
        description: ID pelanggan untuk mendapatkan rekomendasi
        schema:
          type: object
          required:
            - customer_id
          properties:
            customer_id:
              type: string
              example: CUST-001
    responses:
      200:
        description: Rekomendasi berhasil dibuat
        schema:
          type: object
          properties:
            status:
              type: string
              example: WARM
            items:
              type: array
              items:
                type: object
                properties:
                  product_name:
                    type: string
                  final_score:
                    type: number
                  reason:
                    type: string
      400:
        description: Parameter customer_id hilang
      500:
        description: Internal Server Error
    """
    if request.method == 'GET':
        customer_id = request.args.get('customer_id')
    else:
        data = request.get_json(silent=True) or {}
        customer_id = data.get('customer_id')

    if not customer_id:
        return jsonify({"error": "Parameter customer_id wajib diisi"}), 400

    try:
        # Panggil logika dari file prediction_service.py
        result = prediction_service.get_recommendations(customer_id)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# 3. Route: Trigger Pipeline Data (Update Profil User)
@prediction_bp.route('/trigger-pipeline', methods=['POST'])
def pipeline():
    """
    Update Profil User (Trigger Pipeline)
    ---
    tags:
      - Recommendation AI
    parameters:
      - in: body
        name: body
        required: true
        description: ID pelanggan untuk memperbarui profil setelah transaksi
        schema:
          type: object
          required:
            - customer_id
          properties:
            customer_id:
              type: string
              example: CUST-001
    responses:
      200:
        description: Profil berhasil diperbarui
        schema:
          type: object
          properties:
            message:
              type: string
              example: Pipeline sukses. Profil CUST-001 diperbarui.
      500:
        description: Gagal menjalankan pipeline
    """
    data = request.get_json()
    customer_id = data.get('customer_id')
    
    if not customer_id:
        return jsonify({"error": "customer_id wajib ada di body JSON"}), 400
        
    try:
        result = prediction_service.trigger_pipeline(customer_id)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# 4. Route: Cold Start (Simpan Preferensi User Baru)
@prediction_bp.route('/cold-start', methods=['POST'])
def cold_start():
    """
    Simpan Preferensi User Baru (Cold Start)
    ---
    tags:
      - Recommendation AI
    parameters:
      - in: body
        name: body
        required: true
        description: Data preferensi awal dari kuesioner
        schema:
          type: object
          required:
            - customer_id
            - preference
          properties:
            customer_id:
              type: string
              example: CUST-999
            preference:
              type: string
              enum: [Streaming, Voice, Travel, Hemat, Social, Gaming]
              example: Hemat
    responses:
      200:
        description: Preferensi berhasil disimpan
        schema:
          type: object
          properties:
            message:
              type: string
              example: Preferensi 'Hemat' disimpan!
      400:
        description: Data input tidak lengkap
      500:
        description: Internal Server Error
    """
    data = request.get_json()
    customer_id = data.get('customer_id')
    preference = data.get('preference') # Streaming, Voice, Travel, Hemat
    
    if not customer_id or not preference:
        return jsonify({"error": "customer_id dan preference wajib diisi"}), 400
        
    try:
        result = prediction_service.submit_cold_start_preference(customer_id, preference)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500