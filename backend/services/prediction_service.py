import pandas as pd
import joblib
import os
import traceback
from sqlalchemy import create_engine
import psycopg2.extras

# Import dari layer models dan config
from backend.models.database import get_db_connection
from backend.config import DATABASE_URL, ML_MODEL_PATH, ML_COLUMNS_PATH

# Load model dan columns
try:
    MODEL = joblib.load(ML_MODEL_PATH)
    MODEL_COLS = joblib.load(ML_COLUMNS_PATH)
    print("✅ ML: Model dan Cetakan Biru berhasil dimuat.")
except Exception as e:
    print(f"❌ ML ERROR: Gagal memuat model dari {ML_MODEL_PATH}")
    print(f"Error: {e}")
    MODEL = None
    MODEL_COLS = None

db_engine = create_engine(DATABASE_URL)

class PredictionService:
    def __init__(self):
        pass 

    def _get_user_features(self, customer_id):
        sql = "SELECT * FROM user_features WHERE customer_id = %s"
        user_df = pd.read_sql(sql, db_engine, params=(customer_id,))
        return user_df

    def _get_candidate_products(self):
        # Ambil data lengkap produk untuk keperluan filtering
        sql = """
            SELECT product_id, product_name, price, data_gb, 
                   streaming_gb_bonus, call_minutes_bonus, roaming_days_bonus
            FROM products;
        """
        products_df = pd.read_sql(sql, db_engine)
        return products_df

    def get_recommendations(self, customer_id):
        user_df = self._get_user_features(customer_id)

        if user_df.empty:
            return {"status": "COLD", "recommendations": []}

        # 1. GENERASI KANDIDAT
        candidate_products_df = self._get_candidate_products()
        test_df = candidate_products_df.copy()
        
        user_features_dict = user_df.iloc[0].to_dict()
        # Ambil nilai fitur user untuk logika bisnis nanti
        user_travel_score = user_features_dict.get('travel_score', 0)
        user_pct_video = user_features_dict.get('pct_video_usage', 0)
        user_avg_call = user_features_dict.get('avg_call_duration', 0)
        user_spend = user_features_dict.get('monthly_spend', 0)

        for col, value in user_features_dict.items():
            if col not in ['customer_id']:
                test_df[col] = value

        # 2. PREPROCESSING
        # Simpan info produk untuk hasil akhir
        result_metadata = test_df[['product_name', 'product_id', 'price', 'roaming_days_bonus', 'streaming_gb_bonus', 'call_minutes_bonus']].copy()
        
        drop_cols_ml = ["customer_id", "product_name", "target_offer", "product_id"]
        test_df_ml = test_df.drop(columns=drop_cols_ml, errors='ignore')
        test_df_enc = pd.get_dummies(test_df_ml)
        test_df_final = test_df_enc.reindex(columns=MODEL_COLS, fill_value=0)
        
        # 3. PREDIKSI (ML SCORE)
        if MODEL:
            raw_scores = MODEL.predict_proba(test_df_final)[:, 1]
            
            # Gabungkan skor mentah ke metadata
            result_metadata['score'] = raw_scores
            
            # ============================================================
            # 4. HYBRID RE-RANKING (LOGIKA "GALAK" - FIXED)
            # ============================================================
            
            def apply_boost(row):
                final_score = row['score']
                
                # --- A. Logika TRAVELER (PRIORITAS UTAMA) ---
                if user_travel_score > 0.6:
                    if row['roaming_days_bonus'] > 0:
                        final_score += 2.0  # BOOST RAKSASA
                    else:
                        final_score -= 0.5  # PENALTI BESAR
                        
                # --- B. Logika STREAMER ---
                elif user_pct_video > 0.6:
                    if row['streaming_gb_bonus'] > 0:
                        final_score += 0.5
                    else:
                        final_score -= 0.1

                # --- C. Logika PENELEPON ---
                elif user_avg_call > 300:
                    if row['call_minutes_bonus'] > 0:
                        final_score += 0.5
                        
                # --- D. Logika LOW BUDGET (Si Hemat) ---
                if user_spend < 50000:
                    if row['price'] > 100000:
                        final_score -= 0.8 
                
                return final_score

            # Terapkan fungsi boost
            result_metadata['final_score'] = result_metadata.apply(apply_boost, axis=1)
            
            # Urutkan berdasarkan FINAL SCORE
            all_recs_df = result_metadata.sort_values(by='final_score', ascending=False)
            
            # Format Output
            recommendations = [
                f"({min(max(row['final_score'], 0.01) * 100, 99.9):.1f}%) {row['product_name']}"
                for _, row in all_recs_df.head(8).iterrows()
            ]
            
            # PENTING: Kembalikan hasil dictionary ini! (Ini yang tadi hilang)
            return {"status": "WARM_DEBUG", "recommendations": recommendations}
            
        else:
             return {"error": "Model ML tidak siap"}

    def trigger_pipeline(self, customer_id):
        conn = None
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            # SQL PIPELINE
            sql = """
                INSERT INTO user_features (
                    customer_id, plan_type, device_brand, 
                    avg_data_usage_gb, monthly_spend, topup_freq, 
                    pct_video_usage, avg_call_duration, sms_freq, 
                    travel_score, complain_count, spending_tier
                )
                SELECT
                    ph.customer_id,
                    'Prepaid' AS plan_type,
                    'Android' AS device_brand,
                    COALESCE(AVG(p.data_gb), 0) AS avg_data_usage_gb,
                    COALESCE(AVG(p.price), 0) AS monthly_spend,
                    COUNT(ph.product_id) AS topup_freq,
                    COALESCE(
                        AVG(p.streaming_gb_bonus) / NULLIF( (AVG(p.data_gb) + AVG(p.streaming_gb_bonus)), 0),
                        0.0
                    ) AS pct_video_usage,
                    COALESCE(AVG(p.call_minutes_bonus), 0) AS avg_call_duration,
                    COALESCE(AVG(p.sms_bonus), 0) AS sms_freq,
                    LEAST(COALESCE(AVG(p.roaming_days_bonus), 0) / 4.0, 1.0) AS travel_score, 
                    0 AS complain_count,
                    CASE
                        WHEN COALESCE(AVG(p.price), 0) > 100000 THEN 'high'
                        WHEN COALESCE(AVG(p.price), 0) >= 50000 THEN 'mid'
                        ELSE 'low'
                    END AS spending_tier
                FROM purchase_history ph
                JOIN products p ON ph.product_id = p.product_id
                WHERE ph.customer_id = %s
                GROUP BY ph.customer_id
                ON CONFLICT (customer_id) DO UPDATE SET
                    avg_data_usage_gb = EXCLUDED.avg_data_usage_gb,
                    monthly_spend = EXCLUDED.monthly_spend,
                    topup_freq = EXCLUDED.topup_freq,
                    pct_video_usage = EXCLUDED.pct_video_usage,
                    avg_call_duration = EXCLUDED.avg_call_duration,
                    sms_freq = EXCLUDED.sms_freq,
                    travel_score = EXCLUDED.travel_score,
                    spending_tier = EXCLUDED.spending_tier;
            """
            
            cursor.execute(sql, (customer_id,))
            conn.commit()
            
            if cursor.rowcount > 0:
                return {"message": f"Pipeline sukses. Profil {customer_id} diperbarui."}
            else:
                return {"message": "Pipeline berjalan, tapi belum ada history."}, 200

        except Exception as e:
            traceback.print_exc()
            if conn: conn.rollback()
            return {"error": "Terjadi kesalahan pada Data Pipeline."}, 500
        finally:
            if conn: conn.close()

    def submit_cold_start_preference(self, customer_id, preference):
        conn = None
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            pct_video = 0.1; avg_call = 10.0; travel_score = 0.0; spending_tier = 'mid'
            if preference == "Streaming": pct_video = 0.9
            elif preference == "Voice": avg_call = 500.0
            elif preference == "Travel": travel_score = 0.9
            elif preference == "Hemat": spending_tier = 'low'

            sql = """
                INSERT INTO user_features (
                    customer_id, plan_type, device_brand, avg_data_usage_gb, monthly_spend, topup_freq, 
                    pct_video_usage, avg_call_duration, sms_freq, travel_score, complain_count, spending_tier
                ) VALUES (%s, 'Prepaid', 'Unknown', 10.0, 100000, 1, %s, %s, 0, %s, 0, %s)
                ON CONFLICT (customer_id) DO UPDATE SET
                    pct_video_usage = EXCLUDED.pct_video_usage,
                    avg_call_duration = EXCLUDED.avg_call_duration,
                    travel_score = EXCLUDED.travel_score,
                    spending_tier = EXCLUDED.spending_tier;
            """
            cursor.execute(sql, (customer_id, pct_video, avg_call, travel_score, spending_tier))
            conn.commit()
            return {"message": f"Preferensi '{preference}' disimpan!"}
        except Exception as e:
            if conn: conn.rollback()
            raise e
        finally:
            if conn: conn.close()

prediction_service = PredictionService()