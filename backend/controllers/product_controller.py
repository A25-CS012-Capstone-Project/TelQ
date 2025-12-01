from flask import Blueprint, request, jsonify
import pandas as pd
from sqlalchemy import create_engine, text
from backend.config import DATABASE_URL
import traceback

product_bp = Blueprint('product_bp', __name__)
db_engine = create_engine(DATABASE_URL)

# Helper function
def get_db_dataframe(query, params=None):
    with db_engine.connect() as conn:
        # Menggunakan pandas read_sql dengan koneksi SQLAlchemy
        return pd.read_sql(query, conn, params=params)

@product_bp.route('/products/filter', methods=['POST'])
def filter_products_by_preference():
    """
    Mencari produk berdasarkan preferensi kuesioner (Rule-Based).
    """
    data = request.get_json()
    preference = data.get('preference') 

    if not preference:
        return jsonify({"error": "Preferensi wajib diisi"}), 400

    try:
        # Mapping Pilihan Kuesioner -> Kolom 'target_offer' di Database
        category_map = {
            "Streaming": "Streaming Offer",
            "Gaming": "Gaming Offer",
            "Voice": "Voice Offer",
            "Hemat": "General Offer",
            "Travel": "Roaming Offer"
        }
        
        target = category_map.get(preference, "General Offer")

        sql = text("SELECT * FROM products WHERE target_offer = :target ORDER BY price ASC LIMIT 4")
        
        with db_engine.connect() as conn:
            result = conn.execute(sql, {"target": target})
            products = [dict(row._mapping) for row in result]
            
        return jsonify({
            "status": "RULE_BASED",
            "message": f"Menampilkan paket kategori {target}",
            "recommendations": products
        }), 200

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

# --- [BAGIAN YANG DIPERBAIKI] ---
@product_bp.route('/products', methods=['GET'])
def get_all_products():
    """
    Mengambil produk, bisa semua atau difilter berdasarkan kategori (GET param).
    Contoh: /api/v1/products?category=Streaming
    """
    category = request.args.get('category') # Tangkap parameter category

    try:
        query_str = "SELECT * FROM products"
        conditions = []
        
        # Logika Filter SQL Manual (Agar sesuai dengan JS)
        if category:
            if category == 'Streaming':
                # Cari yang punya bonus streaming ATAU namanya mengandung 'Stream'
                conditions.append("(streaming_gb_bonus > 0 OR product_name ILIKE '%%Stream%%')")
            elif category == 'Gaming':
                conditions.append("(gaming_gb_bonus > 0 OR product_name ILIKE '%%Game%%' OR product_name ILIKE '%%Play%%')")
            elif category == 'Roaming':
                conditions.append("(roaming_days_bonus > 0 OR product_name ILIKE '%%Roam%%')")
            elif category == 'Voice':
                conditions.append("(call_minutes_bonus > 0 OR product_name ILIKE '%%Nelpon%%')")
            elif category == 'Hemat':
                conditions.append("price < 25000")
        
        # Gabungkan kondisi jika ada
        if conditions:
            query_str += " WHERE " + " AND ".join(conditions)
        
        query_str += " ORDER BY price ASC"
        
        # Eksekusi
        products_df = pd.read_sql(query_str, db_engine)
        products = products_df.to_dict(orient='records')
        
        return jsonify(products), 200
    except Exception as e:
        print(f"Error /products: {e}")
        return jsonify({"error": str(e)}), 500

@product_bp.route('/products/best-deal', methods=['GET'])
def get_best_deals():
    """Mengambil 4 produk terlaris."""
    try:
        with db_engine.connect() as conn:
            result = conn.execute(text("SELECT COUNT(*) FROM purchase_history"))
            count = result.scalar()

        if count == 0:
            # Fallback
            print("Info: Purchase history kosong. Mengambil default products.")
            sql = "SELECT * FROM products ORDER BY price ASC LIMIT 4"
        else:
            # Join history untuk cari yang paling laku
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
    """Simulasi pembelian produk dengan data lengkap."""
    data = request.get_json()
    customer_id = data.get('customer_id')
    product_id = data.get('product_id')

    # 1. Validasi Input
    if not customer_id or not product_id:
        print("❌ Error: Data tidak lengkap", data)
        return jsonify({"error": "customer_id dan product_id wajib diisi"}), 400

    try:
        # 2. Gunakan Transaction Block
        with db_engine.connect() as conn:
            # Cek dulu apakah produknya beneran ada?
            # (Kita tidak perlu ambil price lagi untuk di-insert, cukup cek keberadaan produk)
            check_sql = text("SELECT product_id FROM products WHERE product_id = :pid")
            result = conn.execute(check_sql, {"pid": product_id}).fetchone()
            
            if not result:
                print(f"❌ Error: Product ID {product_id} tidak ditemukan di DB")
                return jsonify({"error": "Produk tidak valid"}), 404
                
            # 3. Insert ke purchase_history
            # PERBAIKAN: Hapus kolom 'price' karena tidak ada di tabel database kamu
            insert_sql = text("""
                INSERT INTO purchase_history (customer_id, product_id, purchase_date) 
                VALUES (:cid, :pid, NOW())
            """)
            
            conn.execute(insert_sql, {"cid": customer_id, "pid": product_id})
            conn.commit() # Wajib commit
            
            print(f"✅ Sukses: User {customer_id} beli Produk ID {product_id}")

        return jsonify({"message": "Pembelian berhasil disimulasikan!"}), 201

    except Exception as e:
        print("❌ CRITICAL ERROR saat Beli:", str(e))
        traceback.print_exc() # Ini akan memunculkan detail error di terminal kamu
        return jsonify({"error": f"Gagal memproses transaksi: {str(e)}"}), 500