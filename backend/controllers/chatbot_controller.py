from flask import Blueprint, request, jsonify
import random
import os
from backend.config import GEMINI_API_KEY

# --- IMPORT GEMINI DENGAN AMAN ---
try:
    import google.generativeai as genai
    HAS_LIBRARY = True
except ImportError:
    print("[Chatbot] Warning: 'google-generativeai' belum terinstall. Bot jalan di mode rule-based.")
    HAS_LIBRARY = False

chatbot_bp = Blueprint("chatbot_bp", __name__)

# ==============================================================================
# 🔐 KONFIGURASI GEMINI API (PAKAI ENV VAR)
# ==============================================================================
# Set di terminal / .env:
#   export GEMINI_API_KEY="xxx"
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()

HAS_GEMINI = False
MODEL = None

if HAS_LIBRARY and GEMINI_API_KEY:
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        # Sesuaikan nama model dengan versi library kamu:
        # 'gemini-1.5-flash', 'gemini-1.5-pro', atau 'gemini-pro'
        MODEL = genai.GenerativeModel("gemini-pro")
        HAS_GEMINI = True
        print("[Chatbot] Gemini berhasil dikonfigurasi.")
    except Exception as e:
        print(f"[Chatbot] Warning: Gagal konfigurasi Gemini: {e}")
        HAS_GEMINI = False
else:
    if not GEMINI_API_KEY:
        print("[Chatbot] Warning: GEMINI_API_KEY tidak ditemukan. Bot akan pakai mode rule-based.")

# ==============================================================================
# 🧠 KNOWLEDGE BASE (KAMUS PINTAR)
# ==============================================================================
TELCO_KNOWLEDGE_BASE = [
    {
        "keywords": ["lemot", "lambat", "lelet", "lola", "gangguan", "ngelag", "buffering"],
        "answer": (
            "Jaringan terasa lambat ya? Coba aktifkan **Mode Pesawat** selama 10 detik "
            "lalu matikan lagi untuk refresh jaringan. Jika masih lambat, cek apakah "
            "kuota utamamu masih tersedia dan sinyal di lokasimu kuat. 😊"
        ),
    },
    {
        "keywords": ["pulsa", "cek pulsa", "sisa pulsa", "saldo"],
        "answer": (
            "Untuk cek sisa pulsa, kamu bisa ketik kode UMB ***888#** di menu panggilan "
            "atau cek langsung di halaman Dashboard aplikasi ini."
        ),
    },
    {
        "keywords": ["kuota habis", "cek kuota", "sisa kuota"],
        "answer": (
            "Kamu bisa cek detail sisa kuota di halaman **Profil / Usage** aplikasi ini. "
            "Jangan lupa beli paket rekomendasi sebelum benar-benar habis ya!"
        ),
    },
    {
        "keywords": ["registrasi", "daftar kartu", "kk", "ktp", "aktivasi"],
        "answer": (
            "Untuk registrasi kartu baru, siapkan NIK dan No.KK, lalu kirim SMS ke **4444** "
            "dengan format: `REG(spasi)NIK#NoKK#`."
        ),
    },
    {
        "keywords": ["masa aktif", "tenggang", "hangus"],
        "answer": (
            "Supaya kartumu tidak hangus, kamu bisa memperpanjang masa aktif dengan "
            "membeli pulsa atau paket data apa saja di menu **Products**."
        ),
    },
    {
        "keywords": ["bayar", "pembayaran", "metode", "transfer"],
        "answer": (
            "Kami menerima pembayaran via Transfer Bank, E-Wallet (Gopay/Ovo/Dana), "
            "dan pulsa. Pilih metode yang paling nyaman saat Checkout."
        ),
    },
    {
        "keywords": ["cs", "customer service", "admin", "bantuan", "help", "manusia"],
        "answer": (
            "Kamu sedang berbicara dengan Asisten AI TelQ. "
            "Untuk bantuan teknis lebih lanjut, kamu bisa hubungi Call Center kami di **188** (24 Jam)."
        ),
    },
    {
        "keywords": ["promo", "diskon", "voucher", "murah"],
        "answer": (
            "Untuk promo terbaru, cek bagian **Penawaran Terlaris (Best Deals)** di halaman depan. "
            "Paket rekomendasi personalmu biasanya juga punya harga spesial 😉."
        ),
    },
]

# ==============================================================================
# 🔧 HELPER: CARI JAWABAN DI KNOWLEDGE BASE
# ==============================================================================
def search_knowledge_base(msg_lower: str) -> str | None:
    for item in TELCO_KNOWLEDGE_BASE:
        if any(keyword in msg_lower for keyword in item["keywords"]):
            return item["answer"]
    return None


# ==============================================================================
# 💬 ROUTE CHATBOT
# ==============================================================================
@chatbot_bp.route("/chat", methods=["POST"])
def chat():
    data = request.get_json(silent=True) or {}
    user_message = (data.get("message") or "").strip()
    user_context = data.get("context") or {}

    if not user_message:
        return jsonify(
            {
                "reply": "Pesan kosong. Coba tulis pertanyaan atau keluhan yang ingin kamu sampaikan ya 😉",
                "sender": "bot",
                "method": "Validation",
            }
        ), 400

    # Ambil konteks user (kalau ada)
    customer_name = user_context.get("user_name", "Pelanggan")
    top_product = user_context.get("top_product", "Paket Spesial TelQ")
    reason = user_context.get("reason", "pola penggunaanmu (data, telepon, dan roaming)")

    msg_lower = user_message.lower()
    response_text = None
    method = "RuleBased"

    # ------------------------------------------------------------------
    # LAYER 1: REAL AI (GEMINI) – kalau tersedia
    # ------------------------------------------------------------------
    if HAS_GEMINI and MODEL is not None:
        try:
            system_prompt = f"""
Kamu adalah asisten AI customer service untuk operator fiktif bernama **TelQ**.

KONTEKS USER:
- Nama user: {customer_name}
- Produk rekomendasi utama di dashboard: {top_product}
- Alasan rekomendasi: {reason}

ATURAN JAWABAN:
1. Jawab dengan bahasa Indonesia yang santai tapi sopan.
2. Fokus hanya pada hal yang berkaitan dengan TelQ, paket data / telepon, kuota, dan pengalaman pengguna.
3. Jika user bertanya tentang rekomendasi yang muncul, jelaskan hubungan produk {top_product} dengan kebiasaan pengguna (alasan di atas).
4. Jika user minta paket untuk kebutuhan lain (misal: traveling, gaming, hemat), berikan saran paket secara umum
   dan jelaskan bahwa rekomendasi saat ini berdasarkan data historis pengguna.
5. Kalau pertanyaan di luar domain TelQ (misal politik, kesehatan, dll.), jawab singkat bahwa kamu hanya
   bisa membantu terkait layanan TelQ.
"""

            full_prompt = f"{system_prompt}\n\nUser: {user_message}\n\nJawaban:"

            response = MODEL.generate_content(full_prompt)
            text = (getattr(response, "text", "") or "").strip()

            if text:
                response_text = text
                method = "AI"
        except Exception as e:
            print(f"[Chatbot] Gemini Error, fallback ke rule-based. Detail: {e}")

    # ------------------------------------------------------------------
    # LAYER 2: RULE-BASED + KNOWLEDGE BASE
    # ------------------------------------------------------------------
    if not response_text:
        # A. Greeting sederhana
        if any(greet in msg_lower for greet in ["halo", "hai", "hi ", "pagi", "siang", "sore", "malam"]):
            response_text = f"Halo {customer_name}! Ada yang bisa saya bantu seputar paket TelQ-mu?"

        # B. Intent khusus berbasis konteks (override KB)
        elif any(word in msg_lower for word in ["luar negeri", "travel", "roaming", "jalan-jalan", "jalan jalan"]):
            response_text = (
                f"Mau ke luar negeri ya? Paket **{top_product}** ini lebih cocok untuk pemakaian lokal. "
                "Untuk roaming, silakan cek menu **Roaming** di katalog produk. "
                "Biasanya ada paket harian/mingguan khusus traveler. 🌍"
            )
        elif any(word in msg_lower for word in ["game", "gaming", "mlbb", "pubg", "ff", "lag", "rank"]):
            response_text = (
                "Untuk gaming, kamu butuh jaringan stabil dan ping rendah. "
                f"Rekomendasi saat ini **{top_product}** sudah cukup oke untuk penggunaan umum, "
                "tapi kalau operator menyediakan paket khusus gaming (misalnya 'GamesMAX'), itu biasanya lebih optimal. 🎮"
            )
        elif any(word in msg_lower for word in ["mahal", "harga", "kok segini", "terlalu mahal"]):
            response_text = (
                f"Kalau dilihat dari benefit yang kamu dapat (berdasarkan {reason}), "
                f"**{top_product}** itu *value for money*. "
                "Tapi kalau kamu ingin opsi yang lebih hemat, kamu bisa cek paket dengan kuota lebih kecil "
                "atau durasi harian di katalog ya."
            )

        # C. Knowledge base general (FAQ telco)
        if not response_text:
            kb_answer = search_knowledge_base(msg_lower)
            if kb_answer:
                response_text = kb_answer

        # D. Konteks rekomendasi umum
        if not response_text and any(
            word in msg_lower
            for word in ["cocok", "rekomendasi", "bagus", "sesuai", "paket apa", "ambil yang mana"]
        ):
            response_text = (
                f"Berdasarkan {reason}, sistem TelQ merekomendasikan **{top_product}** sebagai paket utama buatmu. "
                "Kalau kebutuhanmu berubah (misalnya lebih sering traveling atau gaming), "
                "profilmu bisa diperbarui lewat menu **Perbarui Profil (Pipeline)** atau dengan transaksi terbaru."
            )

        # E. Fallback terakhir
        if not response_text:
            fallbacks = [
                f"Maaf, aku belum bisa memahami pertanyaanmu sepenuhnya. "
                f"Yang bisa aku jelaskan, saat ini sistem merekomendasikan **{top_product}** berdasarkan {reason}.",
                f"Saat ini aku hanya bisa bantu seputar layanan TelQ dan paket data/telepon. "
                f"Berdasarkan datamu, **{top_product}** adalah pilihan paling pas.",
                "Boleh diulangi pertanyaannya dengan kalimat yang sedikit lebih jelas? 😊",
            ]
            response_text = random.choice(fallbacks)

    # ------------------------------------------------------------------
    # RESPON FINAL
    # ------------------------------------------------------------------
    return jsonify(
        {
            "reply": response_text,
            "sender": "bot",
            "method": method,
        }
    )
