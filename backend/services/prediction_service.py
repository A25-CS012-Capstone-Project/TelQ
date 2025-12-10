import os
import traceback
import joblib
import pandas as pd
from sqlalchemy import create_engine

from backend.models.database import get_db_connection
from backend.config import DATABASE_URL, ML_MODEL_PATH, ML_COLUMNS_PATH

# ====================== LOAD MODEL SEKALI DI AWAL ==========================
try:
    MODEL = joblib.load(ML_MODEL_PATH)
    MODEL_COLS = joblib.load(ML_COLUMNS_PATH)
    print("✅ ML: Model dan daftar kolom fitur berhasil dimuat.")
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
        Pakai TRIM untuk menghindari spasi.
        """
        sql = "SELECT * FROM user_features WHERE TRIM(customer_id) = %s"
        return pd.read_sql(sql, db_engine, params=(customer_id,))

    def _get_candidate_products(self) -> pd.DataFrame:
        """
        Ambil katalog produk lengkap.
        """
        sql = """
            SELECT
                product_id,
                product_name,
                price,
                duration_days,
                data_gb,
                streaming_gb_bonus,
                gaming_gb_bonus,
                social_gb_bonus,
                call_minutes_bonus,
                sms_bonus,
                roaming_days_bonus,
                target_offer
            FROM products;
        """
        return pd.read_sql(sql, db_engine)

    # --------------------- EXPLAINABLE AI LOGIC ---------------------
    def _generate_explanation(self, user_features: dict, product_row) -> str:
        """
        Buat explanation singkat yang content-based aware:
        - Menghubungkan behaviour user dengan bonus di produk.
        """
        reasons = []

        # --- Ambil data user ---
        travel_score = float(user_features.get("travel_score", 0) or 0)
        pct_video = float(user_features.get("pct_video_usage", 0) or 0)
        avg_call = float(user_features.get("avg_call_duration", 0) or 0)
        monthly_spend = float(user_features.get("monthly_spend", 0) or 0)
        avg_data = float(user_features.get("avg_data_usage_gb", 0) or 0)

        # --- Ambil data produk (safe) ---
        p_roaming = float(getattr(product_row, "roaming_days_bonus", 0) or 0)
        p_streaming = float(getattr(product_row, "streaming_gb_bonus", 0) or 0)
        p_social = float(getattr(product_row, "social_gb_bonus", 0) or 0)
        p_gaming = float(getattr(product_row, "gaming_gb_bonus", 0) or 0)
        p_call = float(getattr(product_row, "call_minutes_bonus", 0) or 0)
        p_data = float(getattr(product_row, "data_gb", 0) or 0)
        p_price = float(getattr(product_row, "price", 0) or 0)

        # --- 1. Hiburan (Streaming / Sosmed / Gaming) ---
        if pct_video > 0.6 and (p_streaming > 0 or p_social > 0 or p_gaming > 0):
            ent_parts = []
            if p_streaming > 0:
                ent_parts.append("kuota streaming")
            if p_social > 0:
                ent_parts.append("kuota sosmed")
            if p_gaming > 0:
                ent_parts.append("kuota game")

            reasons.append(
                ", ".join(ent_parts)
                + " yang cocok buat kamu yang hobi hiburan online"
            )

        # --- 2. Roaming (Traveler) ---
        if travel_score > 0.6 and p_roaming > 0:
            reasons.append("bonus roaming buat kebutuhan traveling")

        # --- 3. Telepon (Heavy Caller) ---
        if avg_call > 300 and p_call > 0:
            reasons.append("bonus nelpon yang besar")

        # --- 4. Big data user ---
        if avg_data > 20 and p_data >= 20:
            reasons.append(f"kuota internet besar ({int(p_data)}GB)")

        # --- 5. Budget / Harga ---
        if monthly_spend > 0:
            if p_price < monthly_spend * 0.8:
                reasons.append("harganya lebih hemat dari pola belanjamu")
            elif p_price > monthly_spend * 1.5:
                reasons.append("fitur lebih lengkap untuk upgrade pengalamanmu")

        # --- Fallback explanation ---
        if not reasons:
            if p_streaming > 0 or p_social > 0 or p_gaming > 0:
                return "Paket hiburan dengan bonus streaming/sosmed/game."
            if p_data > 50:
                return "Pilihan terbaik untuk kamu yang butuh internetan puas."
            if p_price < 25000:
                return "Paket hemat yang ramah di kantong."
            return "Rekomendasi terbaik berdasarkan pola penggunaanmu."

        return "Cocok untukmu karena " + " dan ".join(reasons) + "."

    # --------------------- CONTENT-BASED HELPERS ---------------------
    def _compute_content_score(self, user_features: dict, product_row) -> float:
        """
        Hitung skor content-based sederhana:
        - Menghubungkan pct_video_usage dengan streaming / social / gaming bonus.
        - Memperhitungkan kecocokan kuota data.
        - Memperhitungkan roaming & harga.
        Output: sekitar -1.0 s/d +1.5 (nanti dinormalkan).
        """
        score = 0.0

        pct_video = float(user_features.get("pct_video_usage", 0) or 0)
        travel_score = float(user_features.get("travel_score", 0) or 0)
        avg_data = float(user_features.get("avg_data_usage_gb", 0) or 0)
        user_spend = float(user_features.get("monthly_spend", 0) or 0)

        p_streaming = float(getattr(product_row, "streaming_gb_bonus", 0) or 0)
        p_social = float(getattr(product_row, "social_gb_bonus", 0) or 0)
        p_gaming = float(getattr(product_row, "gaming_gb_bonus", 0) or 0)
        p_data = float(getattr(product_row, "data_gb", 0) or 0)
        p_roaming = float(getattr(product_row, "roaming_days_bonus", 0) or 0)
        p_price = float(getattr(product_row, "price", 0) or 0)

        # === 1. User video / entertainment heavy ===
        if pct_video > 0.55:
            if p_streaming > 0:
                score += 0.35
            if p_social > 0:
                score += 0.25
            if p_gaming > 0:
                score += 0.25

        # === 2. User non-entertainment: penalti utk paket hiburan murni ===
        if pct_video < 0.25 and (p_streaming > 0 or p_social > 0 or p_gaming > 0):
            score -= 0.20

        # === 3. Data match ===
        if avg_data > 0:
            diff = (p_data - avg_data) / max(avg_data, 1)
            # skala kecil supaya tidak terlalu agresif
            score += max(min(diff * 0.25, 0.25), -0.2)

        # Heavy data tapi bukan video-heavy → Pure data besar tetap aman
        if pct_video <= 0.55 and avg_data > 15 and p_data >= avg_data:
            score += 0.2

        # === 4. Travel ===
        if travel_score > 0.6 and p_roaming > 0:
            score += 0.4

        # === 5. Price sensitivity ===
        if user_spend > 0:
            if user_spend < 50000 and p_price > 100000:
                score -= 0.6
            else:
                price_ratio = p_price / max(user_spend, 1)
                if 0.6 <= price_ratio <= 1.2:
                    score += 0.15

        return score

    # --------------------- REKOMENDASI ---------------------
    def get_recommendations(self, customer_id: str, top_k: int = 8):
        # 0. Ambil user features
        user_df = self._get_user_features(customer_id)
        if user_df.empty:
            return {"status": "COLD", "recommendations": []}

        candidate_products_df = self._get_candidate_products()
        if candidate_products_df.empty:
            return {"status": "NO_PRODUCTS", "recommendations": []}

        test_df = candidate_products_df.copy()

        # 1. Ambil fitur user (baris pertama)
        user_row = user_df.iloc[0]
        user_features_dict = user_row.to_dict()

        user_travel_score = float(user_features_dict.get("travel_score", 0) or 0)
        user_pct_video = float(user_features_dict.get("pct_video_usage", 0) or 0)
        user_avg_call = float(user_features_dict.get("avg_call_duration", 0) or 0)
        user_spend = float(user_features_dict.get("monthly_spend", 0) or 0)

        # Untuk non-video user, kita agresif menurunkan paket hiburan
        is_non_video_user = user_pct_video < 0.30

        # 2. Filter budget awal
        if user_spend > 0:
            max_price = max(user_spend * 1.5, 20000)
            test_df = test_df[test_df["price"] <= max_price].copy()

        if test_df.empty:
            test_df = candidate_products_df.copy()

        # 3. Broadcast fitur user ke semua kandidat
        for col, value in user_features_dict.items():
            if col != "customer_id":
                test_df[col] = value

        # 4. Metadata untuk output
        metadata_cols = [
            "product_id",
            "product_name",
            "price",
            "data_gb",
            "duration_days",
            "roaming_days_bonus",
            "streaming_gb_bonus",
            "gaming_gb_bonus",
            "social_gb_bonus",
            "call_minutes_bonus",
            "sms_bonus",
        ]

        for c in metadata_cols:
            if c not in test_df.columns:
                test_df[c] = 0

        result_metadata = test_df[metadata_cols].copy()

        # 5. Siapkan fitur untuk model ML
        drop_cols_ml = [
            "customer_id",
            "product_name",
            "plan_type",
            "target_offer",
            "duration_days", 
        ]
        test_df_ml = test_df.drop(columns=drop_cols_ml, errors="ignore")
        test_df_enc = pd.get_dummies(test_df_ml)

        if MODEL_COLS is not None:
            test_df_final = test_df_enc.reindex(columns=MODEL_COLS, fill_value=0)
        else:
            test_df_final = None

        # 6. PREDIKSI ML + Hybrid reranking
        if MODEL is not None and test_df_final is not None:
            # 6.0 ML score
            try:
                ml_scores = MODEL.predict_proba(test_df_final)[:, 1]
                result_metadata["ml_score"] = ml_scores
            except Exception:
                traceback.print_exc()
                result_metadata["ml_score"] = 0.5  # fallback rata-rata

            # 6.1 Rule-based score (termasuk gaming)
            def rule_score(row):
                score = 0.0

                p_socmed = row.get("social_gb_bonus", 0)
                p_stream = row.get("streaming_gb_bonus", 0)
                p_gaming = row.get("gaming_gb_bonus", 0)
                p_roam = row.get("roaming_days_bonus", 0)
                p_call = row.get("call_minutes_bonus", 0)
                price = row.get("price", 0)

                entertainment_flags = sum(
                    x > 0 for x in [p_stream, p_socmed, p_gaming]
                )

                # Baseline kecil untuk produk yang punya bonus hiburan/roaming
                if entertainment_flags > 0 or p_roam > 0:
                    score += 0.05

                # Non-video user: penalti untuk paket hiburan murni
                if is_non_video_user and entertainment_flags > 0:
                    # Kalau tidak ada bonus call / roaming → pure entertainment
                    if p_call == 0 and p_roam == 0:
                        score -= 0.4
                    else:
                        score -= 0.2

                # 1. Travel logic
                if user_travel_score > 0.6:
                    if p_roam > 0:
                        score += 0.8
                    else:
                        score -= 0.3

                # 2. Video / Social / Gaming logic
                if user_pct_video > 0.5:
                    if entertainment_flags >= 2:
                        score += 0.4
                    elif entertainment_flags == 1:
                        score += 0.25

                # 3. Voice logic
                if user_avg_call > 300 and p_call > 0:
                    score += 0.4

                # 4. Penalty paket mahal untuk low spender
                if user_spend < 50000 and price > 100000:
                    score -= 0.8

                return score

            result_metadata["rule_score"] = result_metadata.apply(
                rule_score, axis=1
            )

            # 6.2 Content-based score
            content_scores = []
            for r in test_df.itertuples():
                content_scores.append(
                    self._compute_content_score(user_features_dict, r)
                )
            result_metadata["content_score"] = content_scores

            # 6.3 Normalisasi skor
            def _normalize_series(s, clip_min=0.0, clip_max=1.0):
                if s is None or len(s) == 0:
                    return s
                minv = s.min()
                maxv = s.max()
                if pd.isna(minv) or pd.isna(maxv) or minv == maxv:
                    return pd.Series([0.5] * len(s), index=s.index)
                norm = (s - minv) / (maxv - minv)
                return norm.clip(clip_min, clip_max)

            result_metadata["ml_score_n"] = _normalize_series(
                result_metadata["ml_score"]
            )
            result_metadata["rule_score_n"] = _normalize_series(
                result_metadata["rule_score"], clip_min=0.0, clip_max=1.0
            )
            result_metadata["content_score_n"] = _normalize_series(
                result_metadata["content_score"], clip_min=0.0, clip_max=1.0
            )

            # --- BOBOT: ML utama, rule + content sebagai penyesuai bisnis ---
            ml_w = 0.60
            rule_w = 0.25
            content_w = 0.15

            result_metadata["final_score"] = (
                ml_w * result_metadata["ml_score_n"]
                + rule_w * result_metadata["rule_score_n"]
                + content_w * result_metadata["content_score_n"]
            )

            # 7. Sort & format output
            all_recs_df = result_metadata.sort_values(
                by="final_score", ascending=False
            )
            top = all_recs_df.head(top_k)

            # String legacy (dipakai FE sekarang)
            recommendations = [
                f"({max(min(row.final_score, 0.999), 0.01) * 100:.1f}%) {row.product_name}"
                for row in top.itertuples()
            ]

            # Versi structured + alasan
            items = []
            for row in top.itertuples():
                reason_text = self._generate_explanation(user_features_dict, row)
                items.append(
                    {
                        "product_id": int(row.product_id),
                        "product_name": row.product_name,
                        "price": int(row.price),
                        "data_gb": int(row.data_gb),
                        "duration_days": int(row.duration_days)
                        if pd.notnull(row.duration_days)
                        else 30,
                        "streaming_gb_bonus": int(row.streaming_gb_bonus or 0),
                        "gaming_gb_bonus": int(row.gaming_gb_bonus or 0),
                        "social_gb_bonus": int(row.social_gb_bonus or 0),
                        "call_minutes_bonus": int(row.call_minutes_bonus or 0),
                        "roaming_days_bonus": int(row.roaming_days_bonus or 0),
                        "sms_bonus": int(row.sms_bonus or 0),
                        "final_score": float(row.final_score),
                        "ml_score": float(row.ml_score),
                        "reason": reason_text,
                    }
                )

            return {
                "status": "WARM",
                "recommendations": recommendations,
                "items": items,
            }

        # 8. Fallback kalau MODEL tidak siap
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

            items = []
            for row in fallback.itertuples():
                items.append(
                    {
                        "product_id": int(row.product_id),
                        "product_name": row.product_name,
                        "price": int(row.price),
                        "data_gb": int(row.data_gb),
                        "duration_days": int(row.duration_days)
                        if pd.notnull(row.duration_days)
                        else 30,
                        "streaming_gb_bonus": int(row.streaming_gb_bonus or 0),
                        "gaming_gb_bonus": int(row.gaming_gb_bonus or 0),
                        "social_gb_bonus": int(row.social_gb_bonus or 0),
                        "call_minutes_bonus": int(row.call_minutes_bonus or 0),
                        "roaming_days_bonus": int(row.roaming_days_bonus or 0),
                        "sms_bonus": int(row.sms_bonus or 0),
                        "reason": "Paket hemat rekomendasi kami.",
                    }
                )

            return {
                "status": "FALLBACK",
                "recommendations": recommendations,
                "items": items,
            }

    # --------------------- PIPELINE ---------------------
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
                    ph.customer_id, 'Prepaid', 'Android',
                    COALESCE(AVG(p.data_gb), 0), COALESCE(AVG(p.price), 0), COUNT(ph.product_id),
                    COALESCE(AVG(p.streaming_gb_bonus)/NULLIF(AVG(p.data_gb)+AVG(p.streaming_gb_bonus),0), 0.0),
                    COALESCE(AVG(p.call_minutes_bonus), 0), COALESCE(AVG(p.sms_bonus), 0),
                    LEAST(COALESCE(AVG(p.roaming_days_bonus), 0)/4.0, 1.0), 0,
                    CASE WHEN COALESCE(AVG(p.price), 0) > 100000 THEN 'high'
                         WHEN COALESCE(AVG(p.price), 0) >= 50000 THEN 'mid' ELSE 'low' END
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
                return {"message": "Pipeline berjalan, tapi belum ada history."}, 200
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
            pct_video, avg_call, travel_score, spending_tier = 0.1, 10.0, 0.0, "mid"
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
                VALUES (%s, 'Prepaid', 'Unknown', 10.0, 100000, 1, %s, %s, 0, %s, 0, %s)
                ON CONFLICT (customer_id) DO UPDATE SET
                    pct_video_usage    = EXCLUDED.pct_video_usage,
                    avg_call_duration  = EXCLUDED.avg_call_duration,
                    travel_score       = EXCLUDED.travel_score,
                    spending_tier      = EXCLUDED.spending_tier;
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
