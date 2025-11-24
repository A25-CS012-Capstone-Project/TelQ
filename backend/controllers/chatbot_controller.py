from flask import Blueprint, request, jsonify
import random

chatbot_bp = Blueprint('chatbot_bp', __name__)

@chatbot_bp.route('/chat', methods=['POST'])
def chat():
    data = request.get_json(silent=True) or {}
    user_message = data.get('message', '').lower()
    user_context = data.get('context', {}) # Data user/produk yang sedang dilihat
    
    # Ambil data konteks (jika ada)
    customer_name = user_context.get('user_name', 'Kak')
    top_product = user_context.get('top_product', 'Paket Spesial')
    reason = user_context.get('reason', 'kebiasaan penggunaanmu')

    response_text = ""

    # --- LOGIKA "MOCK AI" (Rule-Based Cerdas) ---
    # Di dunia nyata, bagian ini diganti dengan panggil API ke OpenAI / Gemini
    
    if "halo" in user_message or "hi" in user_message:
        response_text = f"Halo {customer_name}! Ada yang bisa saya bantu soal paket internetmu hari ini?"

    elif "mahal" in user_message or "harga" in user_message:
        response_text = f"Memang harganya menyesuaikan, tapi {top_product} ini yang paling hemat buat jangka panjang kalau dihitung per GB-nya, lho."

    elif "kenapa" in user_message or "alasan" in user_message:
        response_text = f"Sistem kami merekomendasikan ini karena {reason}. Kami ingin memastikan kuotamu nggak cepat habis di tengah bulan."

    elif "streaming" in user_message or "youtube" in user_message or "video" in user_message:
        response_text = "Untuk streaming, paket rekomendasi di atas sudah prioritas jaringan 4G/5G, jadi anti-buffering!"

    elif "game" in user_message or "gaming" in user_message:
        response_text = "Paket ini punya latensi rendah, jadi ping-nya stabil buat push rank!"

    elif "terima kasih" in user_message or "makasih" in user_message:
        response_text = "Sama-sama! Jangan ragu tanya lagi ya kalau bingung pilih paket."

    else:
        # Jawaban Default / Fallback
        fallbacks = [
            f"Menarik! Apakah kamu ingin tahu lebih detail soal kuota di {top_product}?",
            "Bisa diulangi? Aku khusus membantu memilihkan paket internet terbaik buatmu.",
            f"Intinya, {top_product} adalah pilihan paling pas berdasarkan data penggunaanmu bulan lalu."
        ]
        response_text = random.choice(fallbacks)

    return jsonify({
        "reply": response_text,
        "sender": "bot"
    })