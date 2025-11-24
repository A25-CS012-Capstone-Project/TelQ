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

  // Greeting
  const nameEl = document.getElementById("user-name");
  if (nameEl) {
    const firstName = user.firstname || user.first_name || "User";
    nameEl.textContent = `Halo, ${firstName}!`;
  }

  // Jalankan fetch
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

  if (!container) return;

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

      // PERUBAHAN DISINI:
      // Kita cek apakah backend mengirim 'items' (Object baru) atau 'recommendations' (String lama)
      // Kita prioritaskan 'items' karena ada field 'reason' (Explainable AI)
      if (data.items && data.items.length > 0) {
        renderProductCards(data.items, container, false); // False karena ini object, bukan string
      } else {
        renderProductCards(data.recommendations, container, true); // Fallback ke string lama
      }
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
  if (!container) return;

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

  if (!filterSection || !filterContainer || !questBox) return;

  filterContainer.innerHTML = "<p>Mencari paket...</p>";
  filterSection.style.display = "block";
  questBox.style.opacity = "0.5";

  try {
    const response = await fetch(`${API_BASE_URL}/products/filter`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ preference: pref }),
    });

    const data = await response.json();

    if (response.ok) {
      questBox.style.display = "none";
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
  if (!btn) return;

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
// Fungsi ini diupdate untuk menangani Fitur Explainable AI
function renderProductCards(items, container, isRecsysString) {
  container.innerHTML = "";

  if (!items || items.length === 0) {
    container.innerHTML = "<p>Tidak ada produk ditemukan.</p>";
    return;
  }

  items.forEach((item) => {
    let name,
      info,
      priceDisplay,
      reasonHtml = "";

    if (isRecsysString) {
      // --- LOGIKA LAMA (String) ---
      const match = item.match(/^\(([\d.]+%)\)\s(.+)/);
      info = match
        ? `<span style="color:#27ae60; font-weight:bold;">Match: ${match[1]}</span>`
        : "Rekomendasi";
      name = match ? match[2] : item;
      priceDisplay = "";
    } else {
      // --- LOGIKA BARU (Object) ---
      name = item.product_name;

      // Jika ada final_score (dari ML), format jadi persentase
      if (item.final_score) {
        const scorePct = (
          Math.max(Math.min(item.final_score, 0.999), 0.01) * 100
        ).toFixed(1);
        info = `<span style="color:#27ae60; font-weight:bold;">Match: ${scorePct}%</span>`;
      } else {
        info = item.target_offer || "Penawaran Spesial";
      }

      priceDisplay = `Rp ${item.price.toLocaleString("id-ID")}`;

      // --- BAGIAN INOVASI: Tampilkan Alasan (Explainable AI) ---
      if (item.reason) {
        reasonHtml = `
            <div style="
                background-color: #e8f4fd; 
                border: 1px solid #b3d7ff;
                border-radius: 6px;
                padding: 8px;
                margin-top: 8px;
                font-size: 0.85rem;
                color: #0c5460;
                line-height: 1.3;
                text-align: left;
            ">
                <span style="font-size: 1.1em; margin-right: 4px;">💡</span>
                ${item.reason}
            </div>
          `;
      }
    }

    const card = document.createElement("div");
    card.className = "product-card";

    // Struktur Kartu HTML
    card.innerHTML = `
      <div class="card-score">${info}</div>
      <div class="card-title" style="min-height:50px;">${name}</div>
      
      ${
        priceDisplay
          ? `<div style="font-size:1.1rem; font-weight:bold; color:#2c3e50; margin-bottom:5px;">${priceDisplay}</div>`
          : ""
      }
      
      <!-- Insert Alasan AI Disini -->
      ${reasonHtml}

      <div style="margin-top: 15px;">
          <button class="btn-primary" onclick="alert('Fitur detail untuk ${name} akan segera hadir!')">
            Lihat Detail
          </button>
      </div>
    `;

    container.appendChild(card);
  });
}

function handleLogout() {
  localStorage.removeItem("user");
  window.location.href = "/login";
}
