from flask import Blueprint, request, jsonify
import pandas as pd
from sqlalchemy import create_engine, text
from backend.config import DATABASE_URL
import traceback

product_bp = Blueprint('product_bp', __name__)
db_engine = create_engine(DATABASE_URL)

@product_bp.route('/products/filter', methods=['POST'])
def filter_products_by_preference():
    """
    Mencari produk berdasarkan preferensi kuesioner (Rule-Based).
    Tidak menggunakan ML, hanya SQL Query sederhana.
    """
    data = request.get_json()
    preference = data.get('preference') # Contoh: "Streaming", "Gaming"

    if not preference:
        return jsonify({"error": "Preferensi wajib diisi"}), 400

    try:
        # Mapping Pilihan Kuesioner -> Kolom 'target_offer' di Database
        # Sesuaikan dengan isi tabel products Anda (target_offer)
        category_map = {
            "Streaming": "Streaming Offer",
            "Gaming": "Gaming Offer",
            "Voice": "Voice Offer",
            "Hemat": "General Offer",
            "Travel": "Roaming Offer"
        }
        
        target = category_map.get(preference, "General Offer")

        # SQL Query Sederhana
        sql = text("SELECT * FROM products WHERE target_offer = :target ORDER BY price ASC LIMIT 4")
        
        with db_engine.connect() as conn:
            result = conn.execute(sql, {"target": target})
            # Konversi hasil SQLAlchemy ke list of dicts
            products = [dict(row._mapping) for row in result]
            
        return jsonify({
            "status": "RULE_BASED",
            "message": f"Menampilkan paket kategori {target}",
            "recommendations": products
        }), 200

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@product_bp.route('/products', methods=['GET'])
def get_all_products():
    """Mengambil semua produk dari katalog."""
    try:
        # Ambil semua produk
        sql = "SELECT * FROM products ORDER BY price ASC"
        products_df = pd.read_sql(sql, db_engine)
        products = products_df.to_dict(orient='records')
        return jsonify(products), 200
    except Exception as e:
        print(f"Error /products: {e}")
        return jsonify({"error": str(e)}), 500

@product_bp.route('/products/best-deal', methods=['GET'])
def get_best_deals():
    """Mengambil 4 produk terlaris. Fallback ke produk termurah jika history kosong."""
    try:
        # Cek apakah ada history
        with db_engine.connect() as conn:
            # Gunakan text() untuk query raw SQL yang aman
            result = conn.execute(text("SELECT COUNT(*) FROM purchase_history"))
            count = result.scalar()

        if count == 0:
            # FALLBACK: Jika belum ada yang beli, tampilkan 4 produk acak/termurah
            print("Info: Purchase history kosong. Mengambil default products.")
            sql = "SELECT * FROM products ORDER BY price ASC LIMIT 4"
        else:
            # UTAMA: Join history untuk cari yang paling laku
            sql = """
                SELECT p.*, COUNT(h.product_id) as popularity
                FROM products p
                JOIN purchase_history h ON p.product_id = h.product_id
                GROUP BY p.product_id, p.product_name, p.price, p.duration_days, p.data_gb, 
                         p.streaming_gb_bonus, p.gaming_gb_bonus, p.social_gb_bonus, 
                         p.call_minutes_bonus, p.sms_bonus, p.roaming_days_bonus, p.target_offer
                ORDER BY popularity DESC
                LIMIT 4
            """
        
        products_df = pd.read_sql(sql, db_engine)
        products = products_df.to_dict(orient='records')
        
        return jsonify(products), 200

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@product_bp.route('/simulate-purchase', methods=['POST'])
def simulate_purchase():
    """Simulasi pembelian produk."""
    data = request.get_json()
    customer_id = data.get('customer_id')
    product_id = data.get('product_id')

    if not customer_id or not product_id:
        return jsonify({"error": "customer_id dan product_id wajib diisi"}), 400

    try:
        # Gunakan text() untuk parameter binding yang aman
        sql = text("INSERT INTO purchase_history (customer_id, product_id) VALUES (:cid, :pid)")
        
        with db_engine.connect() as conn:
            conn.execute(sql, {"cid": customer_id, "pid": product_id})
            conn.commit()
            
        return jsonify({"message": "Pembelian berhasil disimulasikan!"}), 201
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500