const API_BASE_URL = "/api/v1/auth";

// --- FUNGSI REGISTER ---
async function handleRegister(event) {
  event.preventDefault(); // Mencegah reload halaman

  // Ambil data dari form
  const firstname = document.getElementById("firstname").value;
  const lastname = document.getElementById("lastname").value;
  const customer_id = document.getElementById("customer_id").value;
  const email = document.getElementById("email").value;
  const password = document.getElementById("password").value;

  const payload = {
    firstname: firstname,
    lastname: lastname,
    customer_id: customer_id,
    email: email,
    password: password,
  };

  try {
    // Tampilkan loading state (opsional, agar terlihat responsif)
    const submitBtn = event.target.querySelector("button[type='submit']");
    const originalBtnText = submitBtn.innerHTML;
    submitBtn.innerHTML = "Memproses...";
    submitBtn.disabled = true;

    const response = await fetch(`${API_BASE_URL}/register`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const result = await response.json();

    // Kembalikan tombol ke semula
    submitBtn.innerHTML = originalBtnText;
    submitBtn.disabled = false;

    if (response.ok) {
      // SWAL SUKSES
      Swal.fire({
        icon: "success",
        title: "Registrasi Berhasil!",
        text: "Akun Anda telah dibuat. Silakan login.",
        showConfirmButton: false,
        timer: 2000, // Tunggu 2 detik sebelum pindah
      }).then(() => {
        window.location.href = "/login";
      });
    } else {
      // SWAL ERROR DARI API
      Swal.fire({
        icon: "error",
        title: "Registrasi Gagal",
        text: result.error || "Terjadi kesalahan saat mendaftar.",
        confirmButtonColor: "#FF7D00", // Warna Primary TelQ
      });
    }
  } catch (error) {
    console.error("Error:", error);
    // SWAL ERROR JARINGAN
    Swal.fire({
      icon: "error",
      title: "Koneksi Bermasalah",
      text: "Gagal menghubungi server backend.",
      confirmButtonColor: "#FF7D00",
    });
  }
}

// --- FUNGSI LOGIN ---
async function handleLogin(event) {
  event.preventDefault();

  const email = document.getElementById("email").value;
  const password = document.getElementById("password").value;

  const payload = {
    email: email,
    password: password,
  };

  try {
    // Tampilkan loading state
    const submitBtn = event.target.querySelector("button[type='submit']");
    const originalBtnText = submitBtn.innerHTML;
    submitBtn.innerHTML = "Masuk...";
    submitBtn.disabled = true;

    const response = await fetch(`${API_BASE_URL}/login`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const result = await response.json();

    // Kembalikan tombol
    submitBtn.innerHTML = originalBtnText;
    submitBtn.disabled = false;

    if (response.ok) {
      localStorage.setItem("user", JSON.stringify(result.user));

      // SWAL SUKSES
      Swal.fire({
        icon: "success",
        title: "Login Berhasil!",
        text: `Selamat datang kembali, ${result.user.firstname || "User"}!`,
        showConfirmButton: false,
        timer: 1500, // Tunggu 1.5 detik
      }).then(() => {
        window.location.href = "/"; // Arahkan ke dashboard
      });
    } else {
      // SWAL ERROR LOGIN
      Swal.fire({
        icon: "error",
        title: "Login Gagal",
        text: result.error || "Cek email atau password Anda.",
        confirmButtonColor: "#FF7D00",
      });
    }
  } catch (error) {
    console.error("Error:", error);
    // SWAL ERROR SERVER
    Swal.fire({
      icon: "warning",
      title: "Server Tidak Merespon",
      text: "Pastikan backend/app.py sedang berjalan.",
      confirmButtonColor: "#FF7D00",
    });
  }
}

// --- FUNGSI LOGOUT (Dengan Konfirmasi) ---
function handleLogout() {
  Swal.fire({
    title: "Yakin ingin keluar?",
    text: "Anda harus login kembali untuk mengakses akun.",
    icon: "question",
    showCancelButton: true,
    confirmButtonColor: "#FF7D00",
    cancelButtonColor: "#d33",
    confirmButtonText: "Ya, Keluar",
    cancelButtonText: "Batal",
  }).then((result) => {
    if (result.isConfirmed) {
      localStorage.removeItem("user");

      Swal.fire({
        title: "Berhasil Keluar",
        icon: "success",
        showConfirmButton: false,
        timer: 1000,
      }).then(() => {
        window.location.href = "/login";
      });
    }
  });
}
