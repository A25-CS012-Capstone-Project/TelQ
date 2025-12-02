from flask import Blueprint, request, jsonify
from backend.services.prediction_service import prediction_service

# 1. Definisi Blueprint (Ini yang dicari oleh app.py)
prediction_bp = Blueprint('prediction_bp', __name__)

# 2. Route: Mendapatkan Rekomendasi
# Contoh: GET /api/v1/recommend?customer_id=CUST-001
@prediction_bp.route('/recommend', methods=['GET', 'POST'])
def recommend():
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
# Contoh: POST /api/v1/cold-start body: {"customer_id": "CUST-999", "preference": "Hemat"}
@prediction_bp.route('/cold-start', methods=['POST'])
def cold_start():
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