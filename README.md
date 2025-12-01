TelQ - Intelligent Telecommunication Plan Recommender

<!-- Ganti path gambar di atas jika ada banner project -->

TelQ adalah aplikasi web cerdas yang membantu pengguna menemukan paket telekomunikasi (Internet, Telepon, Roaming) terbaik berdasarkan pola penggunaan mereka menggunakan Machine Learning (Hybrid Recommendation System).

Project ini dibuat sebagai Capstone Project untuk program Dicoding - Pengembang Machine Learning & Front-End.

🚀 Fitur Utama

🛒 Rekomendasi Cerdas: Menggunakan algoritma Hybrid (Content-Based + Rule-Based) untuk mencocokkan paket dengan profil user.

🤖 Smart Chatbot: Asisten virtual yang siap menjawab pertanyaan seputar paket.

📊 Admin Dashboard: Halaman admin lengkap untuk memantau penjualan, menambah produk, dan melihat analitik user.

📱 Responsif UI: Tampilan modern dan ramah seluler menggunakan Tailwind CSS.

🔐 Multi-Role Auth: Sistem login aman untuk User dan Admin.

🛠️ Teknologi yang Digunakan

Frontend: HTML5, Tailwind CSS, Vanilla JavaScript.

Backend: Python Flask.

Database: PostgreSQL.

Machine Learning: Scikit-Learn, Pandas, NumPy.

ORM: SQLAlchemy.

📋 Prasyarat (Requirements)

Sebelum memulai, pastikan laptop kamu sudah terinstall:

Python 3.8+: Download di sini

PostgreSQL: Download di sini (Install juga pgAdmin 4).

Git: (Opsional, untuk clone repo).

⚡ Cara Instalasi & Menjalankan (Langkah demi Langkah)

1. Clone atau Download Project

Download source code project ini dan ekstrak ke folder di laptop kamu.
Buka terminal (CMD/PowerShell/Terminal) dan arahkan ke folder project tersebut.

cd path/to/TelQ



2. Buat Virtual Environment (Sangat Disarankan)

Agar library project tidak bentrok dengan sistem laptopmu.

Windows:

python -m venv venv
venv\Scripts\activate



Mac/Linux:

python3 -m venv venv
source venv/bin/activate



(Tanda berhasil: muncul tulisan (venv) di sebelah kiri terminal).

3. Install Library Python

Install semua kebutuhan backend dan machine learning.

pip install -r requirements.txt



4. Setup Database PostgreSQL

Buka aplikasi pgAdmin 4.

Buat database baru: Klik Kanan Databases > Create > Database.

Beri nama: telq_recommender_db (atau nama lain, bebas).

Klik Save.

5. Konfigurasi Environment (.env)

Buat file baru bernama .env di folder root project (sejajar dengan app.py).

Salin isi berikut dan sesuaikan dengan konfigurasi lokal kamu:

SECRET_KEY=calon_best_capstone
GEMINI_API_KEY=AIzaSyCQT1OUBsBgG_EAjYTP2RW-spyIIrX4jKE

# Konfigurasi Database
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432
DB_NAME=telq_recommender_db

# Konfigurasi ML (Sesuaikan path jika perlu)
ML_MODEL_PATH=backend/models/telq_model.joblib
ML_COLUMNS_PATH=backend/models/telq_model_columns.joblib


6. Inisialisasi Database (Membuat Tabel & Data Awal)

Jalankan script python ini untuk membuat tabel (Users, Products, History) dan mengisi data dummy produk secara otomatis.

cd backend/models
python database.py



Jika berhasil, akan muncul pesan: ✅ SUKSES: Database berhasil diinisialisasi!

Kembali ke folder root:

cd ../..



7. Jalankan Aplikasi 🚀

Sekarang saatnya menyalakan server!

python app.py



Atau:

flask run



Buka browser (Chrome/Edge) dan akses:
👉 https://www.google.com/search?q=http://127.0.0.1:5000

👤 Akun Demo

Kamu bisa menggunakan akun ini untuk login:

Admin (Dashboard)

Email: admin@super.com

Password: admin123

Akses: Manajemen Produk, User Analytics, Sales Report.

User (Pelanggan)

Silakan Register akun baru di halaman Login.

Atau gunakan user demo (jika ada di database).

📂 Struktur Folder

TelQ/
├── assets/             # Gambar, CSS, JS Frontend
├── backend/
│   ├── controllers/    # Logika Auth, Produk, Rekomendasi
│   ├── models/         # Skema Database & Script Init DB
│   ├── services/       # Logic ML & Helper
│   └── config.py       # Konfigurasi App
├── templates/          # File HTML (Home, Login, Admin)
├── app.py              # Entry Point Aplikasi Flask
├── requirements.txt    # Daftar Library
└── README.md           # Dokumentasi ini



❓ Troubleshooting (Masalah Umum)

Error ModuleNotFoundError: Pastikan kamu sudah menjalankan pip install -r requirements.txt dalam kondisi (venv) aktif.

Error Database Connection: Cek kembali file .env. Pastikan password PostgreSQL benar dan nama database sesuai dengan yang dibuat di pgAdmin.

Produk tidak muncul saat ditambah: Pastikan di .env nama database sudah benar. Data mungkin masuk ke database yang salah jika ada banyak database di pgAdmin.

Selamat Mencoba! 🎉