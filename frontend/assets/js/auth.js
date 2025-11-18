// Konfigurasi URL Backend (Pastikan port 5000 sesuai dengan Flask Anda)
const API_BASE_URL = "http://127.0.0.1:5000/api/v1/auth";

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
      alert("Registrasi Berhasil! Silakan Login.");
      window.location.href = "login.html";
    } else {
      alert("Gagal: " + (result.error || "Terjadi kesalahan"));
    }
  } catch (error) {
    console.error("Error:", error);
    alert("Gagal menghubungi server backend.");
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

      alert("Login Berhasil! Mengalihkan ke dashboard...");
      window.location.href = "index.html"; // Arahkan ke dashboard
    } else {
      alert("Login Gagal: " + (result.error || "Cek email/password Anda"));
    }
  } catch (error) {
    console.error("Error:", error);
    alert(
      "Gagal menghubungi server backend. Pastikan backend/app.py berjalan."
    );
  }
}

// --- FUNGSI LOGOUT (Untuk dipanggil nanti) ---
function handleLogout() {
  localStorage.removeItem("user");
  window.location.href = "login.html";
}
