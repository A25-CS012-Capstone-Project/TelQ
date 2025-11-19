🎨 Panduan Frontend 

Halo Bg Adi as a FE! 👋

Dokumen ini berisi dua bagian penting:

Aturan Integrasi: Cara agar kode kalian jalan di server Backend Python.

Standar Pengembangan: Tech stack dan tugas yang harus dikerjakan.

⚠️ Bagian 1: Cara Menjalankan Aplikasi

JANGAN membuka file HTML langsung dari File Explorer (klik ganda index.html).

Nyalakan Backend dulu:

# Di terminal root project
python -m backend.app


Buka browser di alamat: http://127.0.0.1:5000

⚠️ Bagian 2: Aturan Path & Link (Integrasi Flask)

Karena server Flask memetakan folder frontend/assets ke URL /assets:

1. Static Files (CSS/JS/Img)

Gunakan Absolute Path dengan awalan /assets/.

❌ Salah: <link href="../assets/css/style.css">

✅ Benar: <link href="/assets/css/style.css">

2. Link Halaman (Navigasi)

Gunakan Route URL bersih, jangan nama file.

❌ Salah: <a href="login.html">Login</a>

✅ Benar: <a href="/login">Login</a>

✅ Benar: <a href="/">Dashboard</a>

3. JavaScript Redirect

❌ Salah: window.location.href = "index.html"

✅ Benar: window.location.href = "/"

🛠️ Bagian 3: Standar Pengembangan (Tech Stack)

Mohon ikuti standar ini agar kode seragam dan UI konsisten.

1. Tech Stack Wajib

HTML5: Struktur semantik.

Tailwind CSS: Untuk styling.

Gunakan CDN untuk setup cepat di head: <script src="https://cdn.tailwindcss.com"></script>

Atau setup CLI jika kalian prefer.

Vanilla JavaScript (ES6+): Logic frontend. Tidak perlu React/Vue untuk saat ini.

2. Implementasi Desain (Figma)

Pixel Perfect: Tampilan harus sesuai dengan desain di Figma. Perhatikan padding, margin, warna, dan font size.

Responsive: Pastikan tampilan rapi di Desktop dan Mobile.

3. Library Tambahan

Alerts: WAJIB menggunakan SweetAlert2 untuk semua notifikasi (Login sukses, Error, Konfirmasi).

Dilarang keras menggunakan alert() bawaan browser.

CDN: <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

Contoh:

Swal.fire({
  title: 'Berhasil!',
  text: 'Login sukses, mengalihkan...',
  icon: 'success',
  confirmButtonText: 'Lanjut'
})


✅ Bagian 4: Daftar Tugas (To-Do List)

Selain memperbaiki halaman Login/Register yang sudah ada, tolong buat halaman baru berikut:

1. Halaman Detail Produk (products.html atau detail modal)

Menampilkan informasi lengkap paket data (Kuota Utama, Bonus, Masa Aktif).

Tombol "Beli Sekarang" yang mengarah ke Checkout.

2. Halaman Checkout

Menampilkan ringkasan pesanan.

Pilihan metode pembayaran (simulasi UI saja).

Tombol "Bayar" yang memanggil API simulasi pembelian (nanti dikoordinasikan dengan Backend).

Happy Coding! Jangan lupa git pull dulu sebelum mulai kerja. 🚀