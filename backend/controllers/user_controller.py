from flask import Blueprint, request, jsonify
from backend.models.database import get_db_connection
import pandas as pd
# Import service prediksi untuk bagian rekomendasi di bawah profil
from backend.services.prediction_service import prediction_service
import traceback

user_bp = Blueprint('user_bp', __name__)

@user_bp.route('/profile', methods=['GET'])
def get_user_profile():
    """
    Mengambil Profil Pengguna Lengkap
    ---
    tags:
      - User Profile
    parameters:
      - in: query
        name: customer_id
        type: string
        required: true
        description: ID pelanggan yang ingin dilihat profilnya
        example: CUST-001
    responses:
      200:
        description: Data profil berhasil diambil
        schema:
          type: object
          properties:
            header:
              type: object
              properties:
                customer_id:
                  type: string
                device:
                  type: string
                plan:
                  type: string
                spending_tier:
                  type: string
            persona_list:
              type: array
              items:
                type: object
                properties:
                  desc:
                    type: string
                  icon:
                    type: string
                  title:
                    type: string
            behavior_stats:
              type: object
              properties:
                avg_data_gb:
                  type: number
                monthly_spend:
                  type: number
                pct_video:
                  type: number
                topup_freq:
                  type: integer
                travel_score:
                  type: number
            history_list:
              type: array
              items:
                type: object
                properties:
                  category:
                    type: string
                    description: Kategori untuk warna badge (Social Offer, Gaming Offer, dll)
                  data_gb:
                    type: integer
                  duration_days:
                    type: integer
                  price:
                    type: integer
                  product_name:
                    type: string
                  purchase_date:
                    type: string
            history_summary:
              type: object
              properties:
                favorite_product:
                  type: string
                total_spend:
                  type: integer
                total_trx:
                  type: integer
            recommendations:
              type: array
              items:
                type: string
                description: String rekomendasi singkat
      400:
        description: Parameter customer_id tidak ada
      404:
        description: User tidak ditemukan
      500:
        description: Internal Server Error
    """
    customer_id = request.args.get('customer_id')
    
    if not customer_id:
        return jsonify({"error": "Parameter customer_id wajib diisi"}), 400
    
    conn = get_db_connection()
    try:
        # 1. AMBIL DATA FITUR USER
        sql_profile = "SELECT * FROM user_features WHERE customer_id = %s"
        profile_df = pd.read_sql(sql_profile, conn, params=(customer_id,))
        
        if profile_df.empty:
            return jsonify({"error": "User tidak ditemukan"}), 404

        # 2. AMBIL HISTORY PEMBELIAN (Lengkap dengan kategori untuk filter)
        # [PENTING] Pastikan 'target_offer' di-alias menjadi 'category' agar frontend JS bisa membacanya
        sql_history = """
            SELECT 
                p.product_name,
                p.price,
                p.data_gb,
                p.duration_days,
                ph.purchase_date,
                p.target_offer AS category 
                
            FROM purchase_history ph
            JOIN products p ON ph.product_id = p.product_id
            WHERE ph.customer_id = %s
            ORDER BY ph.purchase_date DESC
            LIMIT 10
        """
        history_df = pd.read_sql(sql_history, conn, params=(customer_id,))
        
        # --- LOGIKA PERSONA (Backend Side) ---
        # Kita hitung di sini biar Frontend tinggal render
        row = profile_df.iloc[0]
        personas = []
        
        # Rule 1: Streaming Lover
        if row['pct_video_usage'] > 0.6:
            personas.append({
                "icon": "🎬", "title": "Streaming Lover", 
                "desc": "Hampir seluruh kuotamu habis untuk nonton film!"
            })
        
        # Rule 2: Traveler
        if row['travel_score'] > 0.6:
            personas.append({
                "icon": "🌍", "title": "Globe Trotter", 
                "desc": "Sering bepergian dan butuh koneksi roaming."
            })
            
        # Rule 3: Heavy Caller
        if row['avg_call_duration'] > 300: # menit
            personas.append({
                "icon": "📞", "title": "Voice Friendly", 
                "desc": "Lebih suka nelpon berjam-jam daripada chat."
            })

        # Rule 4: Si Hemat (Budget Conscious)
        if row['spending_tier'] == 'low':
            personas.append({
                "icon": "🛡️", "title": "Si Hemat", 
                "desc": "Jago cari promo dan paket paling worth it."
            })

        # Default Persona jika kosong
        if not personas:
            personas.append({"icon": "📱", "title": "Digital Native", "desc": "Pengguna internet aktif sehari-hari."})

        # --- LOGIKA RINGKASAN HISTORY ---
        total_trx = len(history_df)
        total_spend = int(history_df['price'].sum()) if not history_df.empty else 0
        # mode() returns Series, take first
        fav_product = history_df['product_name'].mode()[0] if not history_df.empty else "-"

        # --- AMBIL REKOMENDASI (Untuk section bawah) ---
        # Kita panggil service ML yang sudah Anda buat
        recs_data = prediction_service.get_recommendations(customer_id)
        recommendations = []
        if recs_data.get("status") != "COLD":
             # Ambil 3 rekomendasi teratas (parse string output model Anda)
             recommendations = recs_data.get("recommendations", [])[:3]

        # 3. SUSUN RESPONSE FINAL
        response = {
            "header": {
                "customer_id": row['customer_id'],
                "device": row['device_brand'],
                "plan": row['plan_type'],
                "spending_tier": row['spending_tier']
            },
            "persona_list": personas,
            "behavior_stats": {
                "avg_data_gb": float(row['avg_data_usage_gb']),
                "monthly_spend": float(row['monthly_spend']),
                "topup_freq": int(row['topup_freq']),
                "travel_score": float(row['travel_score']),
                "pct_video": float(row['pct_video_usage'])
            },
            "history_summary": {
                "total_trx": total_trx,
                "total_spend": total_spend,
                "favorite_product": fav_product
            },
            "history_list": history_df.to_dict(orient='records'),
            "recommendations": recommendations
        }

        return jsonify(response), 200

    except Exception as e:
        print(f"Error Profile: {e}")
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()