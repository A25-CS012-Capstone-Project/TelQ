from flask import Blueprint, request, jsonify
import random
import os
import re

try:
    from backend.config import GEMINI_API_KEY as CONFIG_GEMINI_KEY
except ImportError:
    CONFIG_GEMINI_KEY = ""

try:
    import google.generativeai as genai
    HAS_LIBRARY = True
except ImportError:
    print("[Chatbot] Warning: 'google-generativeai' belum terinstall. Bot jalan di mode rule-based.")
    HAS_LIBRARY = False

chatbot_bp = Blueprint("chatbot_bp", __name__)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", CONFIG_GEMINI_KEY or "").strip()

HAS_GEMINI = False
MODEL = None

if HAS_LIBRARY and GEMINI_API_KEY:
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        MODEL = genai.GenerativeModel("gemini-pro")
        HAS_GEMINI = True
        print("[Chatbot] Gemini berhasil dikonfigurasi.")
    except Exception as e:
        print(f"[Chatbot] Warning: Gagal konfigurasi Gemini: {e}")
        HAS_GEMINI = False
else:
    if not GEMINI_API_KEY:
        print("[Chatbot] Warning: GEMINI_API_KEY tidak ditemukan. Bot akan pakai mode rule-based.")

# 🧠 KNOWLEDGE BASE 
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

# HANYA PERTANYAAN TELQ
def is_telco_related(msg_lower: str) -> bool:
    """
    Deteksi kasar apakah pesan masih seputar TelQ/telco.
    Kalau tidak, bot akan menjawab 'saya hanya bisa menjawab seputar TelQ'.
    """
    telco_keywords = [
        "telq", "paket", "kuota", "internet", "data", "jaringan", "sinyal",
        "pulsa", "roaming", "telepon", "nelpon", "sms", "kartu", "provider",
        "operator", "tagihan", "billing", "langganan", "isi ulang", "top up",
        "tenggang", "masa aktif", "bayar", "hotspot", "wifi",
        "travel", "traveling", "travelling", "jalan-jalan", "jalan jalan", "trip",
        "game", "gaming", "main"
    ]
    return any(kw in msg_lower for kw in telco_keywords)

# HELPER: CEK KEYWORD KB DENGAN WORD-BOUNDARY
def contains_keyword(msg_lower: str, keyword: str) -> bool:
    """
    - Kalau keyword mengandung spasi -> pakai substring biasa (frasa).
    - Kalau keyword satu kata -> pakai regex word boundary.
    """
    keyword = keyword.lower()
    if " " in keyword:
        return keyword in msg_lower
    pattern = r"\b" + re.escape(keyword) + r"\b"
    return re.search(pattern, msg_lower) is not None


def search_knowledge_base(msg_lower: str) -> str | None:
    for item in TELCO_KNOWLEDGE_BASE:
        for kw in item["keywords"]:
            if contains_keyword(msg_lower, kw):
                return item["answer"]
    return None


# HELPER: INTENT DETECTION
def detect_gaming_intent(msg_lower: str) -> bool:
    gaming_keywords = [
        "game", "gaming", "mlbb", "mobile legend", "mobile legends",
        "pubg", "free fire", "ff ", "rank", "push rank"
    ]
    return any(kw in msg_lower for kw in gaming_keywords)


def detect_travel_intent(msg_lower: str) -> bool:
    travel_keywords = ["luar negeri", "travel", "traveling", "travelling",
                       "roaming", "jalan-jalan", "jalan jalan", "trip"]
    return any(kw in msg_lower for kw in travel_keywords)


def detect_price_intent(msg_lower: str) -> bool:
    price_keywords = ["mahal", "harga", "kok segini", "terlalu mahal", "kemahalan", "murahan ga"]
    return any(kw in msg_lower for kw in price_keywords)


def detect_greeting(msg_lower: str) -> bool:
    greeting_keywords = ["halo", "hai", "hi ", "hi,", "pagi", "siang", "sore", "malam"]
    return any(kw in msg_lower for kw in greeting_keywords)


def detect_reco_intent(msg_lower: str) -> bool:
    reco_keywords = [
        "cocok", "rekomendasi", "rekomendasinya", "paket apa", "paket yang cocok",
        "ambil yang mana", "pilih yang mana", "paket untukku", "paket untuk saya"
    ]
    return any(kw in msg_lower for kw in reco_keywords)


# 💬 ROUTE CHATBOT
@chatbot_bp.route("/chat", methods=["POST"])
def chat():
    """
    Chat dengan Asisten AI (Chatbot)
    ---
    tags:
      - Chatbot
    parameters:
      - in: body
        name: body
        required: true
        description: Pesan dari user dan konteks tambahan
        schema:
          type: object
          required:
            - message
          properties:
            message:
              type: string
              example: "Paket apa yang cocok buat main game?"
            context:
              type: object
              properties:
                user_name:
                  type: string
                  example: "Budi"
                top_product:
                  type: string
                  example: "Gaming Max"
                reason:
                  type: string
                  example: "Suka main game"
    responses:
      200:
        description: Balasan dari Chatbot
        schema:
          type: object
          properties:
            reply:
              type: string
              example: "Untuk gaming, saya sarankan paket Gaming Max..."
            sender:
              type: string
              example: "bot"
            method:
              type: string
              example: "AI"
      400:
        description: Pesan kosong
    """
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

    customer_name = user_context.get("user_name", "Pelanggan")

    raw_top_product = user_context.get("top_product")
    has_personal_reco = bool(raw_top_product) and str(raw_top_product).lower() != "none"
    if has_personal_reco:
        top_product = str(raw_top_product)
    else:
        top_product = "paket data utama TelQ"

    raw_reason = user_context.get("reason")
    if raw_reason and str(raw_reason).lower() != "none":
        reason = str(raw_reason)
    else:
        reason = "preferensi umum seperti kuota, telepon, dan harga"

    msg_lower = user_message.lower()
    response_text = None
    method = "RuleBased"

    # SPECIAL CASE
    if detect_greeting(msg_lower) and not is_telco_related(msg_lower):
        return jsonify(
            {
                "reply": (
                    f"Halo {customer_name}! Saya Asisten AI TelQ. "
                    "Saya hanya bisa menjawab pertanyaan seputar layanan TelQ seperti paket data, kuota, "
                    "telepon, SMS, jaringan, dan pembayaran ya 😊"
                ),
                "sender": "bot",
                "method": "RuleBased",
            }
        )

    # DOMAIN GUARD
    if not is_telco_related(msg_lower):
        return jsonify(
            {
                "reply": (
                    "Maaf, saya hanya bisa menjawab pertanyaan seputar layanan TelQ "
                    "(paket data, kuota, telepon, SMS, jaringan, dan pembayaran)."
                ),
                "sender": "bot",
                "method": "DomainGuard",
            }
        )

    # LAYER 1: RULE-BASED 
    # A. Greeting
    if detect_greeting(msg_lower):
        response_text = (
            f"Halo {customer_name}! Ada yang bisa saya bantu seputar paket atau layanan TelQ-mu?"
        )

    # B. Travel intent
    if not response_text and detect_travel_intent(msg_lower):
        if has_personal_reco:
            response_text = (
                "Kalau kamu suka traveling atau sering ke luar negeri, "
                "paket yang paling cocok biasanya paket **Roaming** (harian atau mingguan). "
                "Di aplikasi TelQ, coba cek kategori **Roaming** di katalog produk, "
                "atau cari paket dengan bonus **roaming_days_bonus** yang besar. 🌍\n\n"
                f"Saat ini sistem juga merekomendasikan **{top_product}** berdasarkan {reason}, "
                "tapi untuk fokus traveling, paket roaming akan lebih optimal."
            )
        else:
            response_text = (
                "Kalau kamu suka traveling atau sering ke luar negeri, "
                "paket yang cocok buatmu biasanya paket **Roaming** (harian/mingguan) "
                "supaya biaya internet di luar negeri lebih terkontrol. 🌍\n\n"
                "Kamu bisa mulai dari paket roaming harian/mingguan di katalog TelQ. "
                "Nanti setelah kamu beberapa kali beli paket, rekomendasi di halaman utama "
                "akan jadi lebih personal buatmu 😉"
            )

    # C. Gaming intent
    if not response_text and detect_gaming_intent(msg_lower):
        if has_personal_reco:
            response_text = (
                "Untuk gaming, kamu butuh jaringan stabil dan ping rendah. "
                "Biasanya paket yang cocok adalah paket dengan kuota cukup besar dan jaringan prioritas, "
                "atau paket khusus **gaming** jika tersedia di katalog. 🎮\n\n"
                f"Rekomendasi utama di dashboard-mu sekarang **{top_product}**, "
                "tapi kalau operator menyediakan paket gaming khusus, itu biasanya lebih pas untuk push rank."
            )
        else:
            response_text = (
                "Kalau kamu fokus ke gaming, cari paket dengan kuota data yang cukup besar "
                "dan jaringan yang stabil. Kalau operator menyediakan paket **gaming khusus** "
                "(misalnya GamesMAX), itu biasanya pilihan terbaik untuk push rank. 🎮\n\n"
                "Untuk sekarang kamu bisa pilih paket data dengan kuota menengah/besar dulu, "
                "nanti setelah sistem mengenali pola pemakaianmu, rekomendasi akan jadi lebih personal."
            )

    # D. Harga / mahal-murah
    if not response_text and detect_price_intent(msg_lower):
        if has_personal_reco:
            response_text = (
                f"Kalau dilihat dari benefit yang kamu dapat (berdasarkan {reason}), "
                f"**{top_product}** itu *value for money*. "
                "Tapi kalau kamu ingin opsi yang lebih hemat, kamu bisa cek paket dengan kuota lebih kecil "
                "atau durasi harian di katalog ya."
            )
        else:
            response_text = (
                "Kalau mau hemat, pilih paket dengan kuota yang sesuai kebutuhan dan durasi yang tidak terlalu panjang. "
                "Misalnya mulai dari paket harian atau mingguan dulu. "
                "Nanti setelah kamu sering pakai, sistem TelQ akan memberikan rekomendasi harga yang lebih pas "
                "dengan pola penggunaanmu."
            )

    # E. Intent rekomendasi paket umum
    if not response_text and detect_reco_intent(msg_lower):
        if has_personal_reco:
            response_text = (
                f"Berdasarkan {reason}, sistem TelQ merekomendasikan **{top_product}** sebagai paket utama buatmu. "
                "Kalau kamu punya kebutuhan khusus (misalnya lebih sering traveling, gaming, atau ingin hemat), "
                "kasih tahu ya biar aku bantu arahkan paket yang sesuai."
            )
        else:
            response_text = (
                "Saat ini sistem belum punya riwayat penggunaanmu, jadi aku kasih saran umum dulu ya:\n\n"
                "- Kalau kamu suka **gaming**, pilih paket dengan kuota cukup besar atau paket khusus *Gaming* "
                "supaya koneksi lebih stabil saat push rank.\n"
                "- Kalau kamu sering **nonton streaming** (YouTube, Netflix, dll.), pilih paket dengan bonus "
                "atau kuota khusus streaming (misalnya paket *VideoPass* / *StreamMAX*).\n"
                "- Kalau kamu aktif di **sosmed** (IG, TikTok, dll.), paket dengan bonus kuota sosial media "
                "(misalnya *SosmedMAX*) akan lebih cocok.\n"
                "- Kalau kamu cuma butuh internet untuk keperluan sehari-hari, pilih paket **Data Pure** "
                "dengan kuota utama sesuai budget.\n\n"
                "Nanti setelah kamu beberapa kali beli paket, sistem TelQ akan memberikan rekomendasi yang "
                "lebih personal di halaman utama 😉"
            )

    # F. Knowledge base general 
    if not response_text:
        kb_answer = search_knowledge_base(msg_lower)
        if kb_answer:
            response_text = kb_answer

    # LAYER 2: GEMINI 
    if not response_text and HAS_GEMINI and MODEL is not None:
        try:
            system_prompt = f"""
Kamu adalah asisten AI customer service untuk operator fiktif bernama **TelQ**.

KONTEKS USER:
- Nama user: {customer_name}
- Produk rekomendasi utama di dashboard: {top_product if has_personal_reco else 'belum ada (user baru / cold start)'}
- Alasan rekomendasi: {reason}

ATURAN JAWABAN:
1. Jawab dengan bahasa Indonesia yang santai tapi sopan.
2. Fokus hanya pada hal yang berkaitan dengan TelQ, paket data / telepon, kuota, dan pengalaman pengguna.
3. Jika user bertanya tentang rekomendasi yang muncul dan sudah ada data, jelaskan hubungan produk {top_product} dengan kebiasaan pengguna.
4. Jika user masih baru (belum ada riwayat), berikan saran umum: gaming, streaming, sosmed, traveling, hemat.
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

    # LAYER 3: FALLBACK TERAKHIR 
    if not response_text:
        fallbacks = [
            "Maaf, aku belum bisa memahami pertanyaanmu sepenuhnya. "
            "Coba jelaskan lagi dengan kalimat yang sedikit lebih jelas ya 😊",
            "Saat ini aku hanya bisa bantu seputar layanan TelQ dan paket data/telepon. "
            "Boleh diulangi pertanyaannya?",
            (
                "Kalau kamu bingung pilih paket, kamu bisa mulai dari paket **Data Pure** dengan kuota "
                "yang sesuai kebutuhan, nanti setelah beberapa kali transaksi sistem akan kasih rekomendasi "
                "yang lebih personal."
            ),
        ]
        response_text = random.choice(fallbacks)
        method = "RuleBased"

    # RESPON FINAL
    return jsonify(
        {
            "reply": response_text,
            "sender": "bot",
            "method": method,
        }
    )