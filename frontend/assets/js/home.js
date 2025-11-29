// assets/js/home.js
const API_BASE_URL = "/api/v1";

// --- Variabel Global untuk Konteks Chat ---
let currentTopRecommendation = null;
let currentReason = null;
let currentUserName = "User";

document.addEventListener("DOMContentLoaded", () => {
  const userStr = localStorage.getItem("user");
  if (!userStr) {
    window.location.href = "/login";
    return;
  }

  let user;
  try {
    user = JSON.parse(userStr);
    currentUserName = user.firstname || user.first_name || "User";
  } catch (e) {
    console.error("[home] Gagal parse user dari localStorage:", e);
    localStorage.removeItem("user");
    window.location.href = "/login";
    return;
  }

  // Greeting
  const nameEl = document.getElementById("user-name");
  if (nameEl) {
    nameEl.textContent = `Halo, ${currentUserName}!`;
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
      if (questBox) questBox.style.display = "none";

      if (data.items && data.items.length > 0) {
        // --- SIMPAN KONTEKS UNTUK CHATBOT ---
        currentTopRecommendation = data.items[0].product_name; // Produk paling atas
        currentReason = data.items[0].reason; // Alasan produk tsb

        renderProductCards(data.items, container, false);
      } else {
        renderProductCards(data.recommendations, container, true);
      }
    }
  } catch (error) {
    console.error("[home] fetchRecommendations error:", error);
    container.innerHTML = '<p style="color:red">Gagal memuat rekomendasi.</p>';
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
      renderBestDealsCards(products, container, false);
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
      renderQuestionerCards(data.recommendations, filterContainer, false);
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
  if (filterSection) filterSection.style.display = "none";
  const userStr = localStorage.getItem("user");
  if (!userStr) return;
  const user = JSON.parse(userStr);
  if (user.customer_id) fetchRecommendations(user.customer_id);
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
      alert("Sukses! Profil Anda telah diperbarui.");
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


// ======================= KARTU QUESTIONER =====================
function renderQuestionerCards(items, container, isRecsysString) {
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
      const match = item.match(/^\(([\d.]+%)\)\s(.+)/);
      info = match
        ? `<span style="color:#27ae60; font-weight:bold;">Match: ${match[1]}</span>`
        : "Rekomendasi";
      name = match ? match[2] : item;
      priceDisplay = "";
    } else {
      name = item.product_name;
      if (item.final_score) {
        const scorePct = (
          Math.max(Math.min(item.final_score, 0.999), 0.01) * 100
        ).toFixed(1);
        info = `<span style="color:#27ae60; font-weight:bold;">Match: ${scorePct}%</span>`;
      } else {
        info = item.target_offer || "Penawaran Spesial";
      }
      priceDisplay = `Rp ${item.price.toLocaleString("id-ID")}`;
      if (item.reason) {
        reasonHtml = `
            <div style="background-color: #e8f4fd; border: 1px solid #b3d7ff; border-radius: 6px; padding: 8px; margin-top: 8px; font-size: 0.85rem; color: #0c5460; line-height: 1.3; text-align: left;">
                <span style="font-size: 1.1em; margin-right: 4px;">💡</span>
                ${item.reason}
            </div>`;
      }
    }
    const card = document.createElement("div");
    card.className = "bg-white rounded-lg overflow-hidden flex flex-col justify-between shadow-[0_8px_16px_-4px_rgba(0,0,0,0.2)]";
    card.innerHTML = `
      <div class="p-3">
          <p class="text-sm font-bold text-gray-600">${name}</p>
          <div class="flex items-center ">
              <!-- Container dengan background image, dibuat lebih besar dan menjadi flex container -->
              <div class="relative bg-[url('../assets/img/bg_gb.png')] bg-cover bg-center h-20 w-20 rounded-lg flex flex-col items-center justify-center text-white flex-shrink-0">
                  <span class="font-bold text-xl leading-none">${item.data_gb}</span>
                  <span class="font-bold text-xs leading-none">GB</span>
              </div>
              <div class="ml-2">
                  <p class="text-xl font-bold text-[#AF5920]">${priceDisplay ? `${priceDisplay}` : "" } ${reasonHtml}</p>
                  <p class="text-xs text-gray-500">Masa aktif ${item.duration_days} hari</p>
              </div>
          </div>
          <p class="text-xs text-[#C66B2C]">Kuota Utama ${item.data_gb} GB</p>
          <button class="inline-block font-bold rounded-lg transition duration-300 bg-primary text-white hover:bg-gray-600 w-full mt-3 py-1 open-modal-btn ">BELI</button>
      </div>`;
    container.appendChild(card);
  });
}

// ======================= KARTU BEST DEALS =====================

function renderBestDealsCards(items, container, isRecsysString) {
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
      // Fungsi parser BARU - HANYA 2 BARIS sesuai perintah
      const parseProductName = (name) => {
        const words = name.trim().split(/\s+/);
        
        // Cek 2 kata pertama apakah ada GB
        if (words.length >= 2) {
          if (words[0].includes('GB') || words[1].includes('GB')) {
            // GB di 2 kata pertama → GB + sisanya di baris 2
            const gbIndex = words.findIndex(w => w.includes('GB'));
            const line1 = words.slice(0, gbIndex).join(' ');
            const line2 = words.slice(gbIndex).join(' ');
            return { line1: line1 || words[0], line2: line2 };
          } else {
            // 2 kata pertama TIDAK ada GB → 2 kata pertama di baris 1
            const line1 = words.slice(0, 2).join(' ');
            const line2 = words.slice(2).join(' ') || '';
            return { line1, line2 };
          }
        }
        
        // Default 1 kata
        return { line1: words[0], line2: '' };
      };

    const nameParts = parseProductName(item.product_name);
    const displayName = `${nameParts.line1}<br>${nameParts.line2}`;

    if (isRecsysString) {
      const match = item.match(/^\(([\d.]+%)\)\s(.+)/);
      info = match
        ? `<span style="color:#27ae60; font-weight:bold;">Match: ${match[1]}</span>`
        : "Rekomendasi";
      name = match ? match[2] : item;
      priceDisplay = "";
    } else {
      name = item.product_name;
      if (item.final_score) {
        const scorePct = (
          Math.max(Math.min(item.final_score, 0.999), 0.01) * 100
        ).toFixed(1);
        info = `<span style="color:#27ae60; font-weight:bold;">Match: ${scorePct}%</span>`;
      } else {
        info = item.target_offer || "Penawaran Spesial";
      }
      priceDisplay = `Rp ${item.price.toLocaleString("id-ID")}`;
      if (item.reason) {
        reasonHtml = `
            <div style="background-color: #e8f4fd; border: 1px solid #b3d7ff; border-radius: 6px; padding: 8px; margin-top: 8px; font-size: 0.85rem; color: #0c5460; line-height: 1.3; text-align: left;">
                <span style="font-size: 1.1em; margin-right: 4px;">💡</span> ${item.reason}
            </div>`;
      }
    }
    const card = document.createElement("div");
    card.className = "bg-white rounded-lg shadow-lg flex flex-col w-full max-w-sm flex-shrink-0";
    card.innerHTML = `
      <div class="flex items-top ">
        <div class="relative bg-[url('../assets/img/bg_gb.png')] bg-cover bg-center h-24 w-24 rounded-lg flex flex-col items-center justify-center text-white flex-shrink-0">
          <span class="font-bold text-2xl leading-none">${item.data_gb}</span>
          <span class="font-bold text-2xs leading-none">GB</span>
        </div>
        <div class="flex-1 pt-4">
          <h4 class="font-semibold text-gray-800 leading-none">${displayName}</h4>
          <p class="text-xs text-gray-600">${item.data_gb} GB kuota utama</p>
          <a href="#" class="text-xs text-primary hover:text-gray-600 font-semibold open-modal-btn">${info}</a>
        </div>
      </div>
      <div class="p-4 pt-0">
        <hr class="my-3 border-black">
        <div class="flex justify-between items-center mt-2">
            <p class="font-bold text-lg text-gray-800">
              ${priceDisplay}
            </p>
            <button class="inline-block font-bold transition duration-300 bg-primary text-white hover:bg-gray-600 rounded-full px-6 py-2 text-sm">BELI</button>
        </div>
      </div>
    `;
    container.appendChild(card);
    });
    // Panggil handleScrollButtons yang ada di global window dari HTML
  if (window.handleScrollButtons) {
    window.handleScrollButtons();
  }
}
// Pemanggilan fetchBestDeals misal di load halaman
window.addEventListener('load', () => {
  fetchBestDeals();
});

// ======================= KARTU REKOMENDASI PERSONAL(AI) =====================
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
      // Fungsi parser BARU - HANYA 2 BARIS sesuai perintah
      const parseProductName = (name) => {
        const words = name.trim().split(/\s+/);
        
        // Cek 2 kata pertama apakah ada GB
        if (words.length >= 2) {
          if (words[0].includes('GB') || words[1].includes('GB')) {
            // GB di 2 kata pertama → GB + sisanya di baris 2
            const gbIndex = words.findIndex(w => w.includes('GB'));
            const line1 = words.slice(0, gbIndex).join(' ');
            const line2 = words.slice(gbIndex).join(' ');
            return { line1: line1 || words[0], line2: line2 };
          } else {
            // 2 kata pertama TIDAK ada GB → 2 kata pertama di baris 1
            const line1 = words.slice(0, 2).join(' ');
            const line2 = words.slice(2).join(' ') || '';
            return { line1, line2 };
          }
        }
        
        // Default 1 kata
        return { line1: words[0], line2: '' };
      };

    const nameParts = parseProductName(item.product_name);
    const displayName = `${nameParts.line1}<br>${nameParts.line2}`;
    
    if (isRecsysString) {
      const match = item.match(/^\(([\d.]+%)\)\s(.+)/);
      info = match
        ? `<span style="color:#27ae60; font-weight:bold;">Match: ${match[1]}</span>`
        : "Rekomendasi";
      name = match ? match[2] : item;
      priceDisplay = "";
    } else {
      name = item.product_name;
      if (item.final_score) {
        const scorePct = (
          Math.max(Math.min(item.final_score, 0.999), 0.01) * 100
        ).toFixed(1);
        info = `<span style="color:#27ae60; font-weight:bold;">Match: ${scorePct}%</span>`;
      } else {
        info = item.target_offer || "Penawaran Spesial";
      }
      priceDisplay = `Rp ${item.price.toLocaleString("id-ID")}`;
      if (item.reason) {
        reasonHtml = `
            <div style="background-color: #e8f4fd; border: 1px solid #b3d7ff; border-radius: 6px; padding: 8px; margin-top: 8px; font-size: 0.85rem; color: #0c5460; line-height: 1.3; text-align: left;">
                <span style="font-size: 1.1em; margin-right: 4px;">💡</span>
                ${item.reason}
            </div>`;
      }
    }
    const card = document.createElement("div");
    card.className = "bg-[linear-gradient(270deg,#FFFFFF_22.18%,rgba(255,125,0,0.76)_98.14%)] rounded-xl shadow-[5px_7px_4px_rgba(0,0,0,0.25)]";
    card.innerHTML = `
    <div class="p-6 relative overflow-hidden rounded-t-xl">
        <div class="absolute top-20 -right-20 w-40 h-40 bg-[linear-gradient(205.41deg,#F9A02F_29.39%,#AF5920_92.11%)] rounded-full"></div>
        <div class="absolute top-12 right-[4.5em] w-8 h-8 bg-[#AF5920] rounded-full"></div>
        <div class="absolute top-16 right-6 w-16 h-16 bg-[#AF5920] rounded-full"></div>
        <h3 class="text-4xl font-semibold leading-tight">${displayName}</h3>
      </div>
      <div class="bg-white p-6 rounded-t-2xl ">
        <h4 class="font-semibold text-gray-500 mb-3">KEUNTUNGAN</h4>
          <ul class="space-y-2 text-black text-sm">
              <li class="flex items-center"><iconify-icon icon="iconoir:clock" class="mr-2 text-xl"></iconify-icon>Masa berlaku ${item.duration_days} Hari</li>
              <li class="flex items-center"><iconify-icon icon="iconoir:clock" class="mr-2 text-xl"></iconify-icon>Kuota utama ${item.data_gb} GB</li>
          </ul>
        <div class="mt-6">
          <p class="font-semibold text-gray-500">HARGA</p>
          <p class="text-xl font-bold text-[#AF5920]">${priceDisplay} / ${item.duration_days} Hari</p>
        </div>
      </div>
      <div class="bg-white px-6 pb-6 rounded-b-xl flex justify-between items-center">
        <button onclick="buyProduct(${item.product_id}, '${item.product_name.replace(/'/g, "\\'")}')" 
                class="font-bold transition duration-300 bg-primary text-white hover:bg-gray-600 w-20 py-2 rounded-full text-sm">
          BELI
        </button>
        <button onclick="showProductDetail(${item.product_id})" 
                class="text-xs text-primary hover:text-gray-600 font-semibold">
          LIHAT DETAIL
        </button>
      </div>`;
    container.appendChild(card);
  });
}

function handleLogout() {
  localStorage.removeItem("user");
  window.location.href = "/login";
}

// ======================== CHATBOT LOGIC ========================
function toggleChat() {
  const chatWindow = document.getElementById("chat-window");
  if (chatWindow.style.display === "none" || chatWindow.style.display === "") {
    chatWindow.style.display = "flex";
    // Auto focus input
    setTimeout(() => document.getElementById("chat-input").focus(), 100);
  } else {
    chatWindow.style.display = "none";
  }
}

function handleEnter(event) {
  if (event.key === "Enter") {
    sendChat();
  }
}

async function sendChat() {
  const inputEl = document.getElementById("chat-input");
  const bodyEl = document.getElementById("chat-body");
  const message = inputEl.value.trim();

  if (!message) return;

  // 1. Tampilkan pesan user
  appendMessage(message, "user");
  inputEl.value = "";

  // 2. Loading sementara
  const loadingId = "loading-" + Date.now();
  const loadingDiv = document.createElement("div");
  loadingDiv.className = "msg msg-bot";
  loadingDiv.id = loadingId;
  loadingDiv.innerText = "Mengetik...";
  bodyEl.appendChild(loadingDiv);
  bodyEl.scrollTop = bodyEl.scrollHeight;

  try {
    // 3. Kirim ke API dengan KONTEKS (User Name & Top Recommendation)
    const context = {
      user_name: currentUserName,
      top_product: currentTopRecommendation || "Paket Internet",
      reason: currentReason || "pola penggunaanmu",
    };

    const response = await fetch(`${API_BASE_URL}/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        message: message,
        context: context,
      }),
    });

    const data = await response.json();

    // 4. Hapus loading, tampilkan balasan bot
    document.getElementById(loadingId).remove();
    appendMessage(data.reply, "bot");
  } catch (error) {
    console.error("Chat Error:", error);
    document.getElementById(loadingId).remove();
    appendMessage("Maaf, aku lagi pusing. Coba tanya lagi nanti ya.", "bot");
  }
}

function appendMessage(text, sender) {
  const bodyEl = document.getElementById("chat-body");
  const div = document.createElement("div");
  div.className = `msg msg-${sender}`;
  div.innerText = text;
  bodyEl.appendChild(div);
  bodyEl.scrollTop = bodyEl.scrollHeight;
}
