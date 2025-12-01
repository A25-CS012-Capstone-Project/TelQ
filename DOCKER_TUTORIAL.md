🐳 Panduan Menjalankan TelQ Menggunakan Docker

Dokumen ini adalah panduan langkah demi langkah untuk menjalankan project TelQ di laptop baru tanpa perlu menginstall Python atau PostgreSQL secara manual.

1️⃣ Langkah Pertama: Nyalakan Mesinnya

Sebelum mengetik kode apa pun, kita harus menyalakan "mesin" Docker terlebih dahulu.

Buka aplikasi Docker Desktop yang sudah diinstall di laptop.

Tunggu sebentar sampai loading selesai.

Pastikan status di pojok kiri bawah aplikasi berwarna HIJAU atau bertuliskan "Engine running".

Atau cek di Taskbar (Windows) / Menu Bar (Mac), pastikan ikon Paus Docker sudah diam (tidak berkedip).

Jangan ditutup. Minimize saja aplikasinya agar tetap berjalan di latar belakang.

2️⃣ Langkah Kedua: Siapkan Terminal

Buka folder project TelQ ini di VS Code (atau File Explorer).

Jika di VS Code: Buka Terminal dengan cara klik menu Terminal > New Terminal.

Jika pakai CMD/PowerShell biasa, pastikan sudah masuk ke dalam folder project (cd path/ke/folder/TelQ).

3️⃣ Langkah Ketiga: Jalankan Aplikasi (Build & Run)

Di terminal tadi, ketik perintah sakti ini lalu tekan Enter:

docker-compose up --build


Apa yang terjadi?

Docker akan mendownload Python & PostgreSQL secara otomatis.

Docker akan menginstall semua library yang ada di requirements.txt.

Docker akan menghubungkan database dan aplikasi.

⏳ Catatan: Proses ini butuh koneksi internet dan memakan waktu agak lama (5-10 menit) untuk pertama kali. Tunggu sampai tulisan di terminal berhenti bergerak dan muncul pesan seperti Running on http://0.0.0.0:5000.

4️⃣ Langkah Keempat: Isi Database (Hanya Sekali)

Saat ini aplikasi sudah jalan, tapi databasenya masih kosong melompong. Kita perlu mengisinya.

Biarkan terminal pertama tadi tetap berjalan. Jangan dimatikan.

Buka Terminal Baru (Klik tanda + di terminal VS Code atau buka jendela CMD baru).

Ketik perintah ini untuk membuat tabel dan data produk:

docker-compose exec web python backend/models/database.py


Jika sukses, akan muncul pesan:

✅ SUKSES: Database berhasil diinisialisasi!

5️⃣ Langkah Terakhir: Buka Website! 🚀

Sekarang semuanya sudah siap.

Buka browser (Chrome/Edge).

Ketik alamat ini:
👉 http://localhost:5000

Login Admin:

Email: admin@super.com

Password: admin123

Login User:

Silakan coba register akun baru.

🛑 Cara Mematikan

Jika sudah selesai demo/presentasi:

Kembali ke terminal tempat docker-compose up berjalan.

Tekan tombol CTRL + C di keyboard.

Tunggu sampai proses berhenti (Gracefully stopping).

(Opsional) Untuk membersihkan total, ketik: docker-compose down.

Selamat Presentasi! 🎉