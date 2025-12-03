TelQ - Intelligent Telecommunication Plan Recommender

TelQ adalah aplikasi web cerdas yang membantu pengguna menemukan paket telekomunikasi (Internet, Telepon, Roaming) terbaik berdasarkan pola penggunaan mereka menggunakan Machine Learning (Hybrid Recommendation System).

Project ini dibuat sebagai Capstone Project untuk program Asah lied by Dicoding

# 🚀 Fitur Utama:

- 🛒 **Rekomendasi Cerdas**: Menggunakan algoritma Hybrid (Content-Based + Rule-Based) untuk mencocokkan paket dengan profil user.
- 🤖 **Smart Chatbot**: Asisten virtual yang siap menjawab pertanyaan seputar paket.
- 🔍 **Explainable AI (XAI)**: Transparansi sistem rekomendasi yang memberikan alasan logis ("Cocok untukmu karena...") di balik setiap saran produk, sehingga meningkatkan kepercayaan pengguna.
- 👤 **User Analytics Dashboard**: Halaman profil interaktif bagi pengguna untuk melihat persona digital mereka (misal: Streamer/Traveler), statistik pengeluaran, dan riwayat belanja.
- 📊 **Admin Dashboard**: Halaman admin lengkap untuk memantau penjualan, menambah produk, dan melihat analitik user.
- 🔐 **Multi-Role Auth**: Sistem login aman untuk User dan Admin.



# 🛠️ Teknologi yang Digunakan

1. **Frontend**: HTML5, Tailwind CSS, Vanilla JavaScript.
2. **Backend**: Python Flask.
3. **Database**: PostgreSQL.
4. **Machine Learning**: Scikit-Learn, Pandas, NumPy (Model XGBoost).
5. **Infrastructure**: Docker & Docker Compose.



# 🐳 Cara Menjalankan Project (Metode Docker - Disarankan)

Ini adalah cara termudah dan tercepat. Tidak perlu install Python atau PostgreSQL secara manual di laptopmu.

**1.Prasyarat**

Pastikan kamu sudah menginstall:

- Docker Desktop
- Pastikan Docker sudah berjalan (Cek ikon paus di taskbar).



**2.Konfigurasi Environment (.env)**

Buat file baru bernama .env di folder paling luar (sejajar dengan docker-compose.yml). Copy isi di bawah ini:

```env
SECRET_KEY=calon_best_capstone
GEMINI_API_KEY=AIzaSyCQT1OUBsBgG_EAjYTP2RW-spyIIrX4jKE

# Konfigurasi Database (Untuk Docker)
DB_USER=postgres
DB_PASSWORD=password123
DB_HOST=db
DB_PORT=5432
DB_NAME=telq_recommender_db

# Konfigurasi Model ML
ML_MODEL_PATH=backend/models/telq_model.pkl
ML_COLUMNS_PATH=backend/models/telq_model_columns.pkl
```


**3.Jalankan Aplikasi**

Buka terminal di folder project, lalu jalankan perintah ini:

```docker-compose up --build```

Tunggu proses download sampai muncul pesan `Running on` lalu buka `http://0.0.0.0:5000`.



**4.Isi Database (Hanya Sekali di Awal)**

Buka Terminal Baru (biarkan terminal pertama tetap jalan), lalu jalankan perintah ini untuk membuat tabel dan data dummy:

```docker-compose exec web python backend/models/database.py```

Jika muncul pesan `✅ SUKSES: Database berhasil diinisialisasi!`, berarti aplikasi siap digunakan.



**5.Akses Aplikasi 🚀**

Buka browser dan kunjungi:
**👉 `http://localhost:5000`**

**👤 Akun Demo**<br>
Gunakan akun ini untuk masuk ke dashboard:

**Admin (Dashboard)**<br>
- Email: `admin@super.com`
- Password: `admin123`
- Akses: Manajemen Produk, User Analytics, Sales Report.

**User (Pelanggan)**<br>
- Silakan Register akun baru.


# 🔧 Alternatif: Instalasi Manual (Tanpa Docker)

Jika kamu ingin menjalankan tanpa Docker, ikuti langkah ini:

1.Install Python 3.10+ & PostgreSQL.<br>
2.Buat Database di pgAdmin dengan nama ``telq_recommender_db``.<br>
3.Update `.env`: Ubah ``DB_HOST=db`` menjadi ``DB_HOST=localhost``. -> **INI PENTING**<br>
4.Install Library:
`pip install -r backend/requirements.txt` <br>
5.Jalankan Aplikasi:
`python -m backend.app`


# ❓ Troubleshooting (Masalah Umum)

- **Error bind**: address already in use: Port 5000 atau 5432 sedang dipakai. Matikan service - - PostgreSQL lokal di laptopmu jika bentrok.
- **Error ML Model not found**: Pastikan file .pkl model sudah ada di folder backend/models/.
- **Database Kosong**: Jangan lupa jalankan langkah No. 4 (Isi Database) setelah Docker menyala.

Selamat Mencoba! 🎉