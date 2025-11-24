// assets/js/home.js
const API_BASE_URL = "/api/v1";

document.addEventListener("DOMContentLoaded", () => {
  const userStr = localStorage.getItem("user");
  if (!userStr) {
    window.location.href = "/login";
    return;
  }

  let user;
  try {
    user = JSON.parse(userStr);
  } catch (e) {
    console.error("[home] Gagal parse user dari localStorage:", e);
    localStorage.removeItem("user");
    window.location.href = "/login";
    return;
  }

  // Greeting (kalau elemen-nya ada di halaman)
  const nameEl = document.getElementById("user-name");
  if (nameEl) {
    const firstName = user.firstname || user.first_name || "User";
    nameEl.textContent = `Halo, ${firstName}!`;
  }

  // Jalankan kedua fetch secara paralel
  if (user.customer_id) {
    fetchRecommendations(user.customer_id);
  } else {
    console.warn("[home] customer_id tidak ditemukan di user object:", user);
  }
  fetchBestDeals();
});

// ======================== REKOMENDASI PERSONAL (AI) ========================
async function fetchRecommendations(customerId) {
  const container = document.getElementById("recommendation-container");
  const questBox = document.getElementById("questionnaire-box");

  if (!container) {
    console.warn(
      "[home] #recommendation-container tidak ditemukan di halaman."
    );
    return;
  }

  container.innerHTML = "<p>Sedang memuat rekomendasi...</p>";

  try {
    const response = await fetch(`${API_BASE_URL}/recommend`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ customer_id: customerId }),
    });

    if (!response.ok) throw new Error("Gagal fetch API /recommend");

    const data = await response.json();
    container.innerHTML = "";

    if (data.status === "COLD") {
      // --- LOGIKA COLD START ---
      const filterSection = document.getElementById("filter-result-section");

      // Tampilkan kuesioner hanya jika section filter sedang disembunyikan
      if (filterSection && filterSection.style.display === "none") {
        if (questBox) questBox.style.display = "block";
      }

      container.innerHTML = `
        <div style="grid-column: 1/-1; text-align:center; color:#7f8c8d; padding:20px; background:#f8f9fa; border-radius:8px;">
          <p><em>Belum ada data historis untuk rekomendasi AI.</em></p>
          <p><small>Silakan isi kuesioner di atas atau lakukan <strong>Simulasi Belanja</strong>.</small></p>
        </div>`;
    } else {
      // --- LOGIKA WARM START ---
      if (questBox) questBox.style.display = "none";
      renderProductCards(data.recommendations, container, true);
    }
  } catch (error) {
    console.error("[home] fetchRecommendations error:", error);
    container.innerHTML =
      '<p style="color:red">Gagal memuat rekomendasi. Cek koneksi backend.</p>';
  }
}

// =========================== BEST DEALS ==========================
async function fetchBestDeals() {
  const container = document.getElementById("best-deal-container");
  if (!container) {
    console.warn("[home] #best-deal-container tidak ditemukan di halaman.");
    return;
  }

  container.innerHTML = "<p>Mencari penawaran terbaik...</p>";

  try {
    const response = await fetch(`${API_BASE_URL}/products/best-deal`);
    if (!response.ok) throw new Error("API Error /products/best-deal");

    const products = await response.json();

    if (!Array.isArray(products) || products.length === 0) {
      container.innerHTML = "<p>Belum ada data penjualan.</p>";
    } else {
      renderProductCards(products, container, false);
    }
  } catch (error) {
    console.error("[home] Best Deal Error:", error);
    container.innerHTML = '<p style="color:red">Gagal memuat Best Deals.</p>';
  }
}

// ======================= KUESIONER (FILTER) ======================
async function submitPreference(pref) {
  const questBox = document.getElementById("questionnaire-box");
  const filterSection = document.getElementById("filter-result-section");
  const filterContainer = document.getElementById("filter-result-container");

  if (!filterSection || !filterContainer || !questBox) {
    console.warn("[home] elemen untuk filter/kuesioner tidak lengkap.");
    return;
  }

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
      renderProductCards(data.recommendations, filterContainer, false);
    } else {
      alert("Gagal memuat produk.");
    }
  } catch (error) {
    console.error("[home] submitPreference error:", error);
  } finally {
    questBox.style.opacity = "1";
  }
}

function closeFilterSection() {
  const filterSection = document.getElementById("filter-result-section");
  if (filterSection) {
    filterSection.style.display = "none";
  }

  const userStr = localStorage.getItem("user");
  if (!userStr) return;
  const user = JSON.parse(userStr);

  if (user.customer_id) {
    fetchRecommendations(user.customer_id);
  }
}

// ======================= PIPELINE BUTTON =========================
async function handleTriggerPipeline() {
  const userStr = localStorage.getItem("user");
  if (!userStr) return;
  const user = JSON.parse(userStr);

  const btn = document.getElementById("btn-pipeline");
  if (!btn) {
    console.warn("[home] #btn-pipeline tidak ditemukan.");
    return;
  }

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

      console.log("[home] Pipeline sukses, mengambil rekomendasi baru...");
      await fetchRecommendations(user.customer_id);

      const filterSection = document.getElementById("filter-result-section");
      if (filterSection) filterSection.style.display = "none";
    } else {
      alert("Gagal: " + (res.error || "Pipeline error"));
    }
  } catch (error) {
    console.error("[home] Pipeline Error:", error);
    alert("Gagal menghubungi server pipeline.");
  } finally {
    btn.disabled = false;
    btn.innerHTML = "🔄 Perbarui Profil (Pipeline)";
  }
}

// ======================= HELPER RENDER KARTU =====================
function renderProductCards(items, container, isRecsysString) {
  container.innerHTML = "";

  if (!items || items.length === 0) {
    container.innerHTML = "<p>Tidak ada produk ditemukan.</p>";
    return;
  }

  items.forEach((item) => {
    let name, info, priceDisplay;

    if (isRecsysString) {
      // Format string dari ML: "(98.5%) Nama Produk"
      const match = item.match(/^\(([\d.]+%)\)\s(.+)/);
      info = match
        ? `<span style="color:#27ae60; font-weight:bold;">Match: ${match[1]}</span>`
        : "Rekomendasi";
      name = match ? match[2] : item;
      priceDisplay = ""; // Harga tidak ada di string output ML sederhana
    } else {
      // Object produk dari DB (Best Deal / Filter)
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

// =========================== LOGOUT ==============================
function handleLogout() {
  localStorage.removeItem("user");
  window.location.href = "/login";
}
