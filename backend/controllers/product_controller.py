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
        return pd.read_sql(query, conn, params=params)

@product_bp.route('/products/filter', methods=['POST'])
def filter_products_by_preference():
    """
    Rekomendasi Produk Berdasarkan Kuesioner (Rule-Based)
    ---
    tags:
      - Products
    parameters:
      - in: body
        name: body
        required: true
        description: Preferensi user dari kuesioner
        schema:
          type: object
          required:
            - preference
          properties:
            preference:
              type: string
              enum: [Streaming, Gaming, Voice, Hemat, Travel, Social]
              example: Gaming
    responses:
      200:
        description: Daftar produk rekomendasi
        schema:
          type: object
          properties:
            status:
              type: string
              example: RULE_BASED
            recommendations:
              type: array
              items:
                type: object
                properties:
                  product_name:
                    type: string
                  price:
                    type: integer
                  data_gb:
                    type: integer
      400:
        description: Preferensi tidak valid
    """
    data = request.get_json()
    preference = data.get('preference') 

    if not preference:
        return jsonify({"error": "Preferensi wajib diisi"}), 400

    try:
        category_map = {
            "Streaming": "Streaming Offer",
            "Gaming": "Gaming Offer",
            "Voice": "Voice Offer",
            "Hemat": "General Offer",
            "Travel": "Roaming Offer",
            "Social": "Social Offer"
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

@product_bp.route('/products', methods=['GET'])
def get_all_products():
    """
    Mengambil Semua Produk (Katalog)
    ---
    tags:
      - Products
    parameters:
      - in: query
        name: category
        type: string
        required: false
        description: Filter kategori (Streaming, Gaming, Voice, Roaming, Social, Hemat)
        enum: [Streaming, Gaming, Voice, Roaming, Social, Hemat]
    responses:
      200:
        description: List produk berhasil diambil
        schema:
          type: array
          items:
            type: object
            properties:
              product_id:
                type: integer
              product_name:
                type: string
              price:
                type: integer
              data_gb:
                type: integer
              streaming_gb_bonus:
                type: integer
              gaming_gb_bonus:
                type: integer
              social_gb_bonus:
                type: integer
      500:
        description: Internal Server Error
    """
    category = request.args.get('category') 

    try:
        query_str = "SELECT * FROM products"
        conditions = []
        
        if category:
            if category == 'Streaming':
                conditions.append("(streaming_gb_bonus > 0 OR product_name ILIKE '%%Stream%%')")
            elif category == 'Gaming':
                conditions.append("(gaming_gb_bonus > 0 OR product_name ILIKE '%%Game%%' OR product_name ILIKE '%%Play%%')")
            elif category == 'Roaming':
                conditions.append("(roaming_days_bonus > 0 OR product_name ILIKE '%%Roam%%')")
            elif category == 'Voice':
                conditions.append("(call_minutes_bonus > 0 OR product_name ILIKE '%%Nelpon%%')")
            # --- [TAMBAHAN] ---
            elif category == 'Social':
                conditions.append("(social_gb_bonus > 0 OR product_name ILIKE '%%Soc%%')")
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
    """
    Mengambil Produk Terlaris (Best Deals)
    ---
    tags:
      - Products
    responses:
      200:
        description: List 4 produk terlaris berdasarkan history pembelian
        schema:
          type: array
          items:
            type: object
            properties:
              product_name:
                type: string
              price:
                type: integer
              popularity:
                type: integer
                description: Jumlah terjual
    """
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
    """
    Simulasi Pembelian Paket
    ---
    tags:
      - Transactions
    parameters:
      - in: body
        name: body
        required: true
        description: Data transaksi pembelian
        schema:
          type: object
          required:
            - customer_id
            - product_id
          properties:
            customer_id:
              type: string
              example: CUST-001
            product_id:
              type: integer
              example: 10
    responses:
      201:
        description: Pembelian Berhasil Dicatat
        schema:
          type: object
          properties:
            message:
              type: string
              example: Pembelian berhasil disimulasikan!
      404:
        description: Produk Tidak Ditemukan
      500:
        description: Gagal Transaksi (Foreign Key Error, dll)
    """
    data = request.get_json()
    customer_id = data.get('customer_id')
    product_id = data.get('product_id')

    # 1. Validasi Input
    if not customer_id or not product_id:
        print("❌ Error: Data tidak lengkap", data)
        return jsonify({"error": "customer_id dan product_id wajib diisi"}), 400

    try:
        with db_engine.connect() as conn:
            check_sql = text("SELECT product_id FROM products WHERE product_id = :pid")
            result = conn.execute(check_sql, {"pid": product_id}).fetchone()
            
            if not result:
                print(f"❌ Error: Product ID {product_id} tidak ditemukan di DB")
                return jsonify({"error": "Produk tidak valid"}), 404
                
            insert_sql = text("""
                INSERT INTO purchase_history (customer_id, product_id, purchase_date) 
                VALUES (:cid, :pid, NOW())
            """)
            
            conn.execute(insert_sql, {"cid": customer_id, "pid": product_id})
            conn.commit()
            
            print(f"✅ Sukses: User {customer_id} beli Produk ID {product_id}")

        return jsonify({"message": "Pembelian berhasil disimulasikan!"}), 201

    except Exception as e:
        print("❌ CRITICAL ERROR saat Beli:", str(e))
        traceback.print_exc()
        return jsonify({"error": f"Gagal memproses transaksi: {str(e)}"}), 500