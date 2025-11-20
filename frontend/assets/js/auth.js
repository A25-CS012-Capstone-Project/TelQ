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
    const response = await fetch(`${API_BASE_URL}/register`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const result = await response.json();

    if (response.ok) {
      Swal.fire({
        title: "Registrasi Berhasil!",
        text: "Akun Anda telah dibuat. Silakan login.",
        icon: "success",
        confirmButtonText: "OK",
      }).then(() => {
        window.location.href = "/login";
      });
    } else {
      Swal.fire({
        title: "Registrasi Gagal",
        text: result.error || "Terjadi kesalahan pada server.",
        icon: "error",
        confirmButtonText: "Coba Lagi",
      });
    }
  } catch (error) {
    console.error("Error:", error);
    Swal.fire({
      title: "Error",
      text: "Gagal menghubungi server backend.",
      icon: "error",
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
    const response = await fetch(`${API_BASE_URL}/login`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const result = await response.json();

    if (response.ok) {
      // SIMPAN SESI USER DI BROWSER (LocalStorage)
      // Ini penting agar kita tahu siapa yang sedang login di halaman Dashboard nanti
      localStorage.setItem("user", JSON.stringify(result.user));

      Swal.fire({
        title: "Login Berhasil!",
        text: "Mengalihkan ke dashboard...",
        icon: "success",
        timer: 1500, // Tutup otomatis setelah 1.5 detik
        showConfirmButton: false,
      }).then(() => {
        window.location.href = "/"; // Arahkan ke dashboard
      });
    } else {
      Swal.fire({
        title: "Login Gagal",
        text: result.error || "Cek kembali email dan password Anda.",
        icon: "error",
        confirmButtonText: "OK",
      });
    }
  } catch (error) {
    console.error("Error:", error);
    Swal.fire({
      title: "Koneksi Error",
      text: "Gagal menghubungi server. Pastikan backend berjalan.",
      icon: "error",
    });
  }
}

// --- FUNGSI LOGOUT (Untuk dipanggil nanti) ---
function handleLogout() {
  localStorage.removeItem("user");
  window.location.href = "/login";
}
