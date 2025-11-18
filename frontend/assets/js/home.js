const API_BASE_URL = "http://127.0.0.1:5000/api/v1";

document.addEventListener("DOMContentLoaded", () => {
  const userStr = localStorage.getItem("user");
  if (!userStr) {
    window.location.href = "login.html";
    return;
  }

  const user = JSON.parse(userStr);
  document.getElementById("user-name").textContent = `Halo, ${user.firstname}!`;

  // Jalankan kedua fetch secara paralel
  fetchRecommendations(user.customer_id);
  fetchBestDeals();
});

async function fetchRecommendations(customerId) {
  const container = document.getElementById("recommendation-container");
  const questBox = document.getElementById("questionnaire-box");

  container.innerHTML = "<p>Sedang memuat rekomendasi...</p>";

  try {
    const response = await fetch(`${API_BASE_URL}/recommend`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ customer_id: customerId }),
    });

    if (!response.ok) throw new Error("Gagal fetch API");

    const data = await response.json();
    container.innerHTML = "";

    if (data.status === "COLD") {
      // --- LOGIKA COLD START ---

      // 1. Tampilkan Kuesioner (jika belum ada hasil filter yang aktif)
      const filterSection = document.getElementById("filter-result-section");
      if (filterSection.style.display === "none") {
        if (questBox) questBox.style.display = "block";
      }

      // 2. Tampilkan pesan di grid rekomendasi personal (karena AI belum bisa kerja)
      container.innerHTML = `
                <div style="grid-column: 1/-1; text-align:center; color:#7f8c8d; padding:20px; background:#f8f9fa; border-radius:8px;">
                    <p><em>Belum ada data historis untuk rekomendasi AI.</em></p>
                    <p><small>Silakan isi kuesioner di atas atau lakukan <strong>Simulasi Belanja</strong>.</small></p>
                </div>`;
    } else {
      // --- LOGIKA WARM START ---

      // 1. Sembunyikan Kuesioner (User sudah dikenal)
      if (questBox) questBox.style.display = "none";

      // 2. Render kartu produk dari AI
      renderProductCards(data.recommendations, container, true);
    }
  } catch (error) {
    console.error(error);
    container.innerHTML =
      '<p style="color:red">Gagal memuat rekomendasi. Cek koneksi backend.</p>';
  }
}

async function fetchBestDeals() {
  const container = document.getElementById("best-deal-container");
  container.innerHTML = "<p>Mencari penawaran terbaik...</p>";

  try {
    const response = await fetch(`${API_BASE_URL}/products/best-deal`);
    if (!response.ok) throw new Error("API Error");

    const products = await response.json();

    if (products.length === 0) {
      container.innerHTML = "<p>Belum ada data penjualan.</p>";
    } else {
      renderProductCards(products, container, false);
    }
  } catch (error) {
    console.error("Best Deal Error:", error);
    container.innerHTML = '<p style="color:red">Gagal memuat Best Deals.</p>';
  }
}

// --- LOGIKA KUESIONER (FILTER) ---
async function submitPreference(pref) {
  const questBox = document.getElementById("questionnaire-box");
  const filterSection = document.getElementById("filter-result-section");
  const filterContainer = document.getElementById("filter-result-container");

  filterContainer.innerHTML = "<p>Mencari paket...</p>";
  filterSection.style.display = "block"; // Tampilkan section khusus filter
  questBox.style.opacity = "0.5";

  try {
    const response = await fetch(`${API_BASE_URL}/products/filter`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ preference: pref }),
    });

    const data = await response.json();

    if (response.ok) {
      questBox.style.display = "none"; // Sembunyikan kuesioner setelah memilih

      // Render ke container KHUSUS FILTER
      renderProductCards(data.recommendations, filterContainer, false);
    } else {
      alert("Gagal memuat produk.");
    }
  } catch (error) {
    console.error("Error:", error);
  } finally {
    questBox.style.opacity = "1";
  }
}

function closeFilterSection() {
  document.getElementById("filter-result-section").style.display = "none";
  // Tampilkan kembali kuesioner jika user menutup hasil filter (dan masih Cold Start)
  // Kita biarkan fetchRecommendations yang menentukan apakah kuesioner perlu muncul lagi
  const user = JSON.parse(localStorage.getItem("user"));
  fetchRecommendations(user.customer_id);
}

// --- LOGIKA PIPELINE ---
async function handleTriggerPipeline() {
  const user = JSON.parse(localStorage.getItem("user"));
  const btn = document.getElementById("btn-pipeline");

  btn.disabled = true;
  btn.innerHTML = "⏳ Sedang Menghitung Profil...";

  try {
    const response = await fetch(`${API_BASE_URL}/trigger-pipeline`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ customer_id: user.customer_id }),
    });

    const res = await response.json();

    if (response.ok) {
      alert(
        "Sukses! Profil Anda telah diperbarui berdasarkan pembelian terakhir."
      );

      // PAKSA Refresh Semua Data
      console.log("Pipeline sukses, mengambil rekomendasi baru...");
      await fetchRecommendations(user.customer_id);

      // Jika user sudah Warm Start, tutup section filter kuesioner jika masih terbuka
      document.getElementById("filter-result-section").style.display = "none";
    } else {
      alert("Gagal: " + (res.error || "Pipeline error"));
    }
  } catch (error) {
    console.error("Pipeline Error:", error);
    alert("Gagal menghubungi server pipeline.");
  } finally {
    btn.disabled = false;
    btn.innerHTML = "🔄 Perbarui Profil (Pipeline)";
  }
}

// --- HELPER RENDER KARTU ---
function renderProductCards(items, container, isRecsysString) {
  container.innerHTML = "";

  if (!items || items.length === 0) {
    container.innerHTML = "<p>Tidak ada produk ditemukan.</p>";
    return;
  }

  items.forEach((item) => {
    let name, info, priceDisplay;

    if (isRecsysString) {
      // Jika input string dari ML: "(98.5%) Nama Produk"
      const match = item.match(/^\(([\d.]+%)\)\s(.+)/);
      info = match
        ? `<span style="color:#27ae60; font-weight:bold;">Match: ${match[1]}</span>`
        : "Rekomendasi";
      name = match ? match[2] : item;
      priceDisplay = ""; // Harga tidak ada di string output ML sederhana
    } else {
      // Jika input object produk asli dari DB (Best Deal / Filter)
      name = item.product_name;
      info = item.target_offer || "Penawaran Spesial";
      priceDisplay = `Rp ${item.price.toLocaleString("id-ID")}`;
    }

    const card = document.createElement("div");
    card.className = "product-card";

    card.innerHTML = `
            <div class="card-score">${info}</div>
            <div class="card-title" style="min-height:50px;">${name}</div>
            ${
              priceDisplay
                ? `<div style="font-size:1.1rem; font-weight:bold; color:#2c3e50; margin-bottom:10px;">${priceDisplay}</div>`
                : ""
            }
            <button class="btn-primary" onclick="alert('Fitur detail untuk ${name} akan segera hadir!')">
                Lihat Detail
            </button>
        `;
    container.appendChild(card);
  });
}

function handleLogout() {
  localStorage.removeItem("user");
  window.location.href = "login.html";
}
