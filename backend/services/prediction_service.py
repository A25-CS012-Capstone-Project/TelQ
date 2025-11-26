import pandas as pd
import joblib
import os
import traceback
from sqlalchemy import create_engine

from backend.models.database import get_db_connection
from backend.config import DATABASE_URL, ML_MODEL_PATH, ML_COLUMNS_PATH

# ====================== LOAD MODEL SEKALI DI AWAL ==========================
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

    # --------------------- DATA AKSES ---------------------
    def _get_user_features(self, customer_id: str) -> pd.DataFrame:
        """
        Ambil 1 baris user_features untuk customer_id tertentu.
        Pakai TRIM untuk jaga-jaga ada spasi.
        """
        sql = "SELECT * FROM user_features WHERE TRIM(customer_id) = %s"
        return pd.read_sql(sql, db_engine, params=(customer_id,))

    def _get_candidate_products(self) -> pd.DataFrame:
        """
        Ambil katalog produk. Kalau nanti model butuh kolom lain,
        tinggal ditambah di SELECT ini.
        """
        sql = """
            SELECT product_id,
                   product_name,
                   price,
                   data_gb,
                   streaming_gb_bonus,
                   call_minutes_bonus,
                   roaming_days_bonus
            FROM products;
        """
        return pd.read_sql(sql, db_engine)
    
    # --------------------- EXPLAINABLE AI LOGIC ---------------------
    def _generate_explanation(self, user_features, product_row):
        """
        Menerjemahkan kecocokan antara User Features dan Product Features
        menjadi kalimat alasan yang manusiawi.
        """
        reasons = []

        # 1. Ambil data user (handle null dengan 0)
        travel_score = float(user_features.get("travel_score", 0) or 0)
        pct_video = float(user_features.get("pct_video_usage", 0) or 0)
        avg_call = float(user_features.get("avg_call_duration", 0) or 0)
        monthly_spend = float(user_features.get("monthly_spend", 0) or 0)

        # 2. Ambil data produk (dari row dataframe/tuple)
        p_roaming = getattr(product_row, "roaming_days_bonus", 0)
        p_streaming = getattr(product_row, "streaming_gb_bonus", 0)
        p_call = getattr(product_row, "call_minutes_bonus", 0)
        p_data = getattr(product_row, "data_gb", 0)
        p_price = getattr(product_row, "price", 0)

        # 3. Logika Pencocokan (Rules)
        
        # A. Traveler
        if travel_score > 0.6 and p_roaming > 0:
            reasons.append("bonus roaming buat traveling")
        
        # B. Streamer
        if pct_video > 0.6 and p_streaming > 0:
            reasons.append("kuota ekstra khusus streaming")
        
        # C. Heavy Caller
        if avg_call > 300 and p_call > 0:
            reasons.append("bonus nelpon gratis")

        # D. Big Data User (User boros data, dikasih paket besar)
        avg_data = float(user_features.get("avg_data_usage_gb", 0) or 0)
        if avg_data > 20 and p_data >= 20:
             reasons.append(f"kuota internet besar ({p_data}GB)")

        # E. Budget Logic
        if monthly_spend > 0:
            if p_price < monthly_spend * 0.8:
                reasons.append("harganya lebih hemat dari biasanya")
            elif p_price > monthly_spend * 1.5:
                # Upselling explanation
                reasons.append("upgrade fitur yang lebih maksimal")

        # 4. Susun Kalimat
        if not reasons:
            # Fallback jika tidak ada kondisi spesifik yang "klik"
            if p_streaming > 0: return "Paket populer dengan bonus hiburan."
            if p_data > 50: return "Pilihan terbaik untuk internetan puas."
            if p_price < 25000: return "Paket hemat paling ramah di kantong."
            return "Rekomendasi terbaik berdasarkan polamu."

        # Gabungkan semua alasan
        return "Cocok untukmu karena ada " + " dan ".join(reasons) + "."

    # --------------------- REKOMENDASI ---------------------
    def get_recommendations(self, customer_id: str, top_k: int = 8):
        # 0. Cek user_features
        user_df = self._get_user_features(customer_id)
        if user_df.empty:
            return {"status": "COLD", "recommendations": []}

        # 1. Ambil kandidat produk
        candidate_products_df = self._get_candidate_products()
        if candidate_products_df.empty:
            return {"status": "NO_PRODUCTS", "recommendations": []}

        test_df = candidate_products_df.copy()

        # 1.1. Ambil fitur user (sekali saja)
        user_row = user_df.iloc[0]
        user_features_dict = user_row.to_dict()

        user_travel_score = float(user_features_dict.get("travel_score", 0) or 0)
        user_pct_video = float(user_features_dict.get("pct_video_usage", 0) or 0)
        user_avg_call = float(user_features_dict.get("avg_call_duration", 0) or 0)
        user_spend = float(user_features_dict.get("monthly_spend", 0) or 0)

        # 1.2. Filter kandidat berdasarkan budget (supaya tidak aneh)
        if user_spend > 0:
            max_price = max(user_spend * 1.5, 20000)  # minimal 20k
            test_df = test_df[test_df["price"] <= max_price].copy()

        # Kalau setelah filter kosong, fallback ke semua produk (daripada kosong total)
        if test_df.empty:
            test_df = candidate_products_df.copy()

        # 1.3. Broadcast fitur user ke semua baris produk
        for col, value in user_features_dict.items():
            if col != "customer_id":
                test_df[col] = value

        # 2. PREPROCESSING UNTUK MODEL
        # Tambahkan 'data_gb' disini agar bisa dipakai oleh fungsi explanation nanti
        result_metadata = test_df[
            [
                "product_name",
                "product_id",
                "price",
                "data_gb",  
                "roaming_days_bonus",
                "streaming_gb_bonus",
                "call_minutes_bonus",
            ]
        ].copy()

        drop_cols_ml = ["customer_id", "product_name", "target_offer", "product_id"]
        test_df_ml = test_df.drop(columns=drop_cols_ml, errors="ignore")
        test_df_enc = pd.get_dummies(test_df_ml)
        if MODEL_COLS is not None:
            test_df_final = test_df_enc.reindex(columns=MODEL_COLS, fill_value=0)
        else:
            # Kalau kolom model tidak ada, tidak usah prediksi ML
            test_df_final = None

        # 3. PREDIKSI (ML SCORE) + HYBRID RERANKING
        if MODEL is not None and test_df_final is not None:
            ml_scores = MODEL.predict_proba(test_df_final)[:, 1]
            result_metadata["ml_score"] = ml_scores

            # 3.1. Hitung rule_score (range kira-kira -1 .. +1)
            def rule_score(row):
                score = 0.0

                # A. Traveler
                if user_travel_score > 0.6:
                    if row["roaming_days_bonus"] > 0:
                        score += 1.0
                    else:
                        score -= 0.5

                # B. Streaming
                elif user_pct_video > 0.6:
                    if row["streaming_gb_bonus"] > 0:
                        score += 0.7
                    else:
                        score -= 0.1

                # C. Heavy caller
                elif user_avg_call > 300:
                    if row["call_minutes_bonus"] > 0:
                        score += 0.5

                # D. Low budget, paket terlalu mahal → penalti
                if user_spend < 50000 and row["price"] > 100000:
                    score -= 0.8

                return score

            result_metadata["rule_score"] = result_metadata.apply(
                rule_score, axis=1
            )

            # 3.2. Kombinasi ML + rules
            alpha = 0.85  # bobot ML
            result_metadata["final_score"] = (
                alpha * result_metadata["ml_score"]
                + (1 - alpha) * result_metadata["rule_score"]
            )

            # 4. Urutkan & format output
            all_recs_df = result_metadata.sort_values(
                by="final_score", ascending=False
            )

            top = all_recs_df.head(top_k)

            # String legacy (dipakai FE sekarang)
            recommendations = [
                f"({max(min(row.final_score, 0.999), 0.01) * 100:.1f}%) {row.product_name}"
                for row in top.itertuples()
            ]

            # Versi structured dengan REASON (Explainable AI)
            items = []
            for row in top.itertuples():
                # Panggil fungsi generator penjelasan
                reason_text = self._generate_explanation(user_features_dict, row)
                
                items.append({
                    "product_id": int(row.product_id),
                    "product_name": row.product_name,
                    "price": int(row.price),
                    "final_score": float(row.final_score),
                    "ml_score": float(row.ml_score),
                    "reason": reason_text # <--- INI HASILNYA
                })

            return {
                "status": "WARM",
                "recommendations": recommendations,
                "items": items,
            }

        # 4. Fallback kalau MODEL tidak siap
        else:
            print("⚠️ MODEL tidak siap, fallback ke produk termurah.")
            fallback = (
                candidate_products_df.sort_values("price")
                .head(top_k)
                .copy()
            )

            recommendations = [
                f"(fallback) {name}"
                for name in fallback["product_name"].tolist()
            ]

            items = [
                {
                    "product_id": int(row.product_id),
                    "product_name": row.product_name,
                    "price": int(row.price),
                    "reason": "Paket hemat rekomendasi kami." # Reason sederhana untuk fallback
                }
                for row in fallback.itertuples()
            ]

            return {
                "status": "FALLBACK",
                "recommendations": recommendations,
                "items": items,
            }

    # --------------------- PIPELINE & COLD START ---------------------
    def trigger_pipeline(self, customer_id):
        conn = None
        try:
            conn = get_db_connection()
            cursor = conn.cursor()

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
                        AVG(p.streaming_gb_bonus)
                        / NULLIF(AVG(p.data_gb) + AVG(p.streaming_gb_bonus), 0),
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
                    monthly_spend      = EXCLUDED.monthly_spend,
                    topup_freq         = EXCLUDED.topup_freq,
                    pct_video_usage    = EXCLUDED.pct_video_usage,
                    avg_call_duration  = EXCLUDED.avg_call_duration,
                    sms_freq           = EXCLUDED.sms_freq,
                    travel_score       = EXCLUDED.travel_score,
                    spending_tier      = EXCLUDED.spending_tier;
            """

            cursor.execute(sql, (customer_id,))
            conn.commit()

            if cursor.rowcount > 0:
                return {"message": f"Pipeline sukses. Profil {customer_id} diperbarui."}
            else:
                return {
                    "message": "Pipeline berjalan, tapi belum ada history."
                }, 200

        except Exception:
            traceback.print_exc()
            if conn:
                conn.rollback()
            return {"error": "Terjadi kesalahan pada Data Pipeline."}, 500
        finally:
            if conn:
                conn.close()

    def submit_cold_start_preference(self, customer_id, preference):
        conn = None
        try:
            conn = get_db_connection()
            cursor = conn.cursor()

            pct_video = 0.1
            avg_call = 10.0
            travel_score = 0.0
            spending_tier = "mid"

            if preference == "Streaming":
                pct_video = 0.9
            elif preference == "Voice":
                avg_call = 500.0
            elif preference == "Travel":
                travel_score = 0.9
            elif preference == "Hemat":
                spending_tier = "low"

            sql = """
                INSERT INTO user_features (
                    customer_id, plan_type, device_brand,
                    avg_data_usage_gb, monthly_spend, topup_freq, 
                    pct_video_usage, avg_call_duration, sms_freq,
                    travel_score, complain_count, spending_tier
                )
                VALUES (%s, 'Prepaid', 'Unknown',
                        10.0, 100000, 1,
                        %s, %s, 0,
                        %s, 0, %s)
                ON CONFLICT (customer_id) DO UPDATE SET
                    pct_video_usage   = EXCLUDED.pct_video_usage,
                    avg_call_duration = EXCLUDED.avg_call_duration,
                    travel_score      = EXCLUDED.travel_score,
                    spending_tier     = EXCLUDED.spending_tier;
            """
            cursor.execute(
                sql, (customer_id, pct_video, avg_call, travel_score, spending_tier)
            )
            conn.commit()
            return {"message": f"Preferensi '{preference}' disimpan!"}
        except Exception:
            if conn:
                conn.rollback()
            raise
        finally:
            if conn:
                conn.close()


prediction_service = PredictionService()