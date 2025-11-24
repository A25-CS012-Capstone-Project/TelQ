from flask import Blueprint, request, jsonify
import random
import os

# --- SAFE IMPORT ---
try:
    import google.generativeai as genai
    HAS_LIBRARY = True
except ImportError:
    print("Warning: Library 'google-generativeai' belum diinstall. Chatbot berjalan mode offline.")
    HAS_LIBRARY = False

chatbot_bp = Blueprint('chatbot_bp', __name__)

# --- KONFIGURASI GEMINI API ---
GEMINI_API_KEY = "AIzaSyCQT1OUBsBgG_EAjYTP2RW-spyIIrX4jKE" 

# Setup Gemini
HAS_GEMINI = False
if HAS_LIBRARY:
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel('gemini-pro') 
        HAS_GEMINI = True
    except Exception as e:
        print(f"Warning: Gemini API Key bermasalah. Error: {e}")
        HAS_GEMINI = False

# ==============================================================================
# 🧠 KNOWLEDGE BASE (KAMUS PINTAR)
# Ini adalah pengganti if-else yang panjang. Cukup tambah topik di sini.
# ==============================================================================
TELCO_KNOWLEDGE_BASE = [
    {
        "keywords": ["lemot", "lambat", "lelet", "lola", "gangguan", "ngelag", "buffering"],
        "answer": "Jaringan terasa lambat ya? Coba **nyalakan Mode Pesawat** selama 10 detik lalu matikan lagi untuk refresh jaringan. Jika masih kendala, pastikan kuota utamamu masih ada ya!"
    },
    {
        "keywords": ["pulsa", "cek pulsa", "sisa pulsa", "saldo"],
        "answer": "Untuk cek sisa pulsa, kamu bisa ketik kode UMB ***888#** di menu panggilan atau cek langsung di halaman Dashboard aplikasi ini."
    },
    {
        "keywords": ["kuota habis", "cek kuota", "sisa kuota"],
        "answer": "Kamu bisa cek detail sisa kuota di halaman **Profile** aplikasi ini. Jangan lupa beli paket rekomendasi sebelum kehabisan total ya!"
    },
    {
        "keywords": ["registrasi", "daftar kartu", "kk", "ktp", "aktivasi"],
        "answer": "Untuk registrasi kartu baru, siapkan NIK dan No.KK, lalu kirim SMS ke 4444 dengan format: **REG(spasi)NIK#NoKK#**."
    },
    {
        "keywords": ["masa aktif", "tenggang", "hangus"],
        "answer": "Jangan biarkan kartumu hangus! Kamu bisa memperpanjang masa aktif dengan membeli pulsa atau paket data apa saja di menu **Products**."
    },
    {
        "keywords": ["bayar", "pembayaran", "metode", "transfer"],
        "answer": "Kami menerima pembayaran via Transfer Bank, E-Wallet (Gopay/Ovo/Dana), dan Pulsa. Pilih metode yang paling mudah buatmu saat Checkout."
    },
    {
        "keywords": ["cs", "customer service", "admin", "bantuan", "help", "manusia"],
        "answer": "Kamu sedang bicara dengan Asisten AI. Jika butuh bantuan teknis lanjut, silakan hubungi Call Center kami di **188** (24 Jam)."
    },
    {
        "keywords": ["promo", "diskon", "voucher", "murah"],
        "answer": "Untuk promo terbaru, cek bagian **'Penawaran Terlaris'** di halaman depan. Paket rekomendasi personalmu juga biasanya punya harga spesial lho!"
    }
]

@chatbot_bp.route('/chat', methods=['POST'])
def chat():
    data = request.get_json(silent=True) or {}
    user_message = data.get('message', '')
    user_context = data.get('context', {}) 
    
    # Ambil data konteks
    customer_name = user_context.get('user_name', 'Pelanggan')
    top_product = user_context.get('top_product', 'Paket Spesial')
    reason = user_context.get('reason', 'pola penggunaanmu')
    
    response_text = ""

    # ------------------------------------------------------------------
    # LAYER 1: REAL AI (GEMINI)
    # ------------------------------------------------------------------
    if HAS_GEMINI and GEMINI_API_KEY != "AIzaSyCQT1OUBsBgG_EAjYTP2RW-spyIIrX4jKE":
        try:
            system_prompt = f"""
            Kamu adalah asisten AI customer service untuk Telco bernama 'TelQ'.
            
            KONTEKS USER SAAT INI:
            - Nama User: {customer_name}
            - Produk yang direkomendasikan sistem (di dashboard): {top_product}
            - Alasan sistem: {reason}
            
            TUGAS:
            Jawab pertanyaan user.
            Jika user bertanya tentang rekomendasi yang muncul, jelaskan menggunakan alasan di atas.
            Jika user meminta hal lain (misal: traveling, gaming) tapi rekomendasi sistem berbeda, 
            jelaskan bahwa rekomendasi saat ini didasarkan pada data historis, lalu sarankan paket umum.
            """
            
            full_prompt = f"{system_prompt}\n\nUser bertanya: {user_message}\nJawaban:"
            
            response = model.generate_content(full_prompt)
            response_text = response.text.strip()
            
            return jsonify({
                "reply": response_text,
                "sender": "bot",
                "method": "AI"
            })
            
        except Exception as e:
            print(f"Gemini Error: {e}")
            pass

    # ------------------------------------------------------------------
    # LAYER 2: SMART FALLBACK (KNOWLEDGE BASE & CONTEXT)
    # Jika AI Mati, kita pakai logika pencarian kata kunci yang lebih rapi
    # ------------------------------------------------------------------
    
    msg_lower = user_message.lower()
    
    # A. Greeting
    if "halo" in msg_lower or "hi" in msg_lower or "pagi" in msg_lower or "siang" in msg_lower:
        response_text = f"Halo {customer_name}! Ada yang bisa saya bantu?"

    # B. Konteks Spesifik (Override Knowledge Base)
    elif "luar negeri" in msg_lower or "travel" in msg_lower or "roaming" in msg_lower or "jalan-jalan" in msg_lower:
        response_text = f"Wah, kalau untuk ke luar negeri, paket **{top_product}** kurang cocok karena itu paket lokal. Saya sarankan cek menu **Roaming** di halaman produk ya!"

    elif "game" in msg_lower or "gaming" in msg_lower or "main" in msg_lower or "lag" in msg_lower or "rank" in msg_lower:
        response_text = f"Buat gaming ya? Kalau mau ping stabil, coba cari paket **GamesMAX** di katalog kami. Tapi **{top_product}** yang tampil ini juga punya jaringan prioritas kok."
        
    elif "mahal" in msg_lower or "harga" in msg_lower:
        response_text = f"Memang harganya menyesuaikan benefit, tapi **{top_product}** ini *best value* kalau dihitung dari bonusnya."

    # C. Cek Knowledge Base (Looping Otomatis)
    # Ini yang bikin bot terlihat "bisa jawab banyak hal" tanpa if-else panjang
    elif not response_text:
        for item in TELCO_KNOWLEDGE_BASE:
            # Cek apakah SALAH SATU keyword ada di pesan user
            if any(keyword in msg_lower for keyword in item["keywords"]):
                response_text = item["answer"]
                break
    
    # D. Konteks Umum (Rekomendasi)
    # Ditaruh di akhir agar pertanyaan spesifik (seperti 'lemot') dijawab Knowledge Base dulu
    if not response_text:
        if "cocok" in msg_lower or "rekomendasi" in msg_lower or "bagus" in msg_lower or "sesuai" in msg_lower:
            response_text = f"Berdasarkan data penggunaanmu (seperti {reason}), sistem kami sangat merekomendasikan **{top_product}**."

    # E. Default Fallback
    if not response_text:
        fallbacks = [
            f"Maaf, koneksi AI saya sedang gangguan. Tapi intinya, **{top_product}** adalah pilihan terbaik berdasarkan data penggunaanmu terakhir.",
            f"Berdasarkan datamu, **{top_product}** adalah yang paling pas. {reason}",
            "Bisa diulangi? Saya kurang mengerti maksudnya.",
        ]
        response_text = random.choice(fallbacks)

    return jsonify({
        "reply": response_text,
        "sender": "bot",
        "method": "RuleBased"
    })