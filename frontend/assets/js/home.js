const API_BASE_URL = "/api/v1";

// --- Variabel Global ---
let currentTopRecommendation = null;
let currentReason = null;
let currentUserName = "User";
let productsStore = {}; // Simpan data produk untuk modal detail

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
    console.error("Auth Error:", e);
    window.location.href = "/login";
    return;
  }

  const nameEl = document.querySelector("#user-name, .user-name-display");
  if (nameEl) nameEl.textContent = `Halo, ${currentUserName}!`;

  if (user.customer_id) {
    fetchRecommendations(user.customer_id);
  }
  fetchBestDeals();
});

// ======================== 1. PIPELINE BUTTON ========================
window.handleTriggerPipeline = async function (btnElement) {
  const userStr = localStorage.getItem("user");
  if (!userStr) return;
  const user = JSON.parse(userStr);

  let originalContent = "🔄 Update Profil";
  if (btnElement) {
    const span = btnElement.querySelector("span");
    if (span) {
      originalContent = span.innerHTML;
      span.innerHTML = "⏳ Memproses...";
    } else {
      originalContent = btnElement.innerHTML;
      btnElement.innerHTML = "⏳ Memproses...";
    }
    btnElement.disabled = true;
    btnElement.classList.add("opacity-75", "cursor-not-allowed");
  }

  try {
    const res = await fetch(`${API_BASE_URL}/trigger-pipeline`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ customer_id: user.customer_id }),
    });

    if (res.ok) {
      Swal.fire({
        icon: "success",
        title: "Profil Diperbarui!",
        text: "AI sedang menghitung ulang rekomendasi...",
        timer: 2000,
        showConfirmButton: false,
      });
      await fetchRecommendations(user.customer_id);
    } else {
      Swal.fire("Gagal", "Terjadi kesalahan saat update profil.", "error");
    }
  } catch (e) {
    console.error(e);
    Swal.fire("Error", "Gagal menghubungi server.", "error");
  } finally {
    if (btnElement) {
      const span = btnElement.querySelector("span");
      if (span) {
        span.innerHTML = originalContent;
      } else {
        btnElement.innerHTML = originalContent;
      }
      btnElement.disabled = false;
      btnElement.classList.remove("opacity-75", "cursor-not-allowed");
    }
  }
};

// ======================== 2. FETCH REKOMENDASI AI ========================
async function fetchRecommendations(customerId) {
  const container = document.getElementById("recommendation-container");
  const questBox = document.getElementById("questionnaire-box");

  if (!container) return;

  container.innerHTML = `<p class="col-span-full text-center text-gray-500 py-10">Sedang memuat rekomendasi cerdas...</p>`;

  try {
    const response = await fetch(`${API_BASE_URL}/recommend`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ customer_id: customerId }),
    });

    const data = await response.json();
    container.innerHTML = "";

    if (data.status === "COLD") {
      const filterSection = document.getElementById("filter-result-section");
      if (
        questBox &&
        filterSection &&
        (filterSection.style.display === "none" ||
          filterSection.classList.contains("hidden"))
      ) {
        questBox.classList.remove("hidden");
      }

      container.innerHTML = `
        <div class="col-span-full text-center p-8 bg-white/50 rounded-xl border border-dashed border-gray-300">
          <p class="text-gray-500 italic">Belum ada data historis.</p>
          <p class="text-sm text-gray-400">Isi kuesioner di atas untuk hasil terbaik.</p>
        </div>`;
    } else {
      if (questBox) questBox.classList.add("hidden");

      if (data.items && data.items.length > 0) {
        currentTopRecommendation = data.items[0].product_name;
        currentReason = data.items[0].reason;
        renderProductCards(data.items.slice(0, 6), container, "gradient"); 
      } else {
        renderProductCards(
          data.recommendations.slice(0, 6),
          container,
          "gradient"
        );
      }
    }
  } catch (error) {
    console.error("Rec Error:", error);
    container.innerHTML =
      '<p class="col-span-full text-center text-red-500">Gagal memuat rekomendasi.</p>';
  }
}

// ======================== 3. FETCH BEST DEALS ========================
async function fetchBestDeals() {
  const container = document.getElementById("best-deal-container");
  if (!container) return;

  try {
    const response = await fetch(`${API_BASE_URL}/products/best-deal`);
    const products = await response.json();

    if (!Array.isArray(products) || products.length === 0) {
      container.innerHTML =
        "<p class='text-white'>Belum ada promo saat ini.</p>";
    } else {
      renderBestDealsCards(products, container);
    }
  } catch (error) {
    console.error("Best Deal Error:", error);
  }
}

// ======================== 4. LOGIC KUESIONER ========================
async function submitPreference(pref) {
  const questBox = document.getElementById("questionnaire-box");
  const filterSection = document.getElementById("filter-result-section");
  const filterContainer = document.getElementById("filter-result-container");

  if (!filterContainer) return;

  filterContainer.innerHTML =
    "<p class='col-span-full text-center'>Mencari paket...</p>";

  if (filterSection) {
    filterSection.style.display = "block";
    filterSection.classList.remove("hidden");
  }
  if (questBox) questBox.classList.add("hidden");

  try {
    const response = await fetch(`${API_BASE_URL}/products/filter`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ preference: pref }),
    });

    const data = await response.json();
    if (response.ok) {
      renderQuestionerCards(data.recommendations, filterContainer, false);
    }
  } catch (error) {
    console.error("Filter Error:", error);
  }
}

function closeFilterSection() {
  const filterSection = document.getElementById("filter-result-section");
  if (filterSection) {
    filterSection.style.display = "none";
    filterSection.classList.add("hidden");
  }
  const userStr = localStorage.getItem("user");
  if (!userStr) return;
  const user = JSON.parse(userStr);
  if (user.customer_id) fetchRecommendations(user.customer_id);
}

// ======================== HELPER ========================
const parseProductName = (name) => {
  const words = name.trim().split(/\s+/);
  if (words.length >= 2) {
    if (words[0].includes("GB") || words[1].includes("GB")) {
      const gbIndex = words.findIndex((w) => w.includes("GB"));
      const line1 = words.slice(0, gbIndex).join(" ");
      const line2 = words.slice(gbIndex).join(" ");
      return { line1: line1 || words[0], line2: line2 };
    } else {
      const line1 = words.slice(0, 2).join(" ");
      const line2 = words.slice(2).join(" ") || "";
      return { line1, line2 };
    }
  }
  return { line1: words[0], line2: "" };
};

// ======================== RENDERERS ========================

function renderQuestionerCards(items, container, isRecsysString) {
  container.innerHTML = "";
  if (!items || items.length === 0) {
    container.innerHTML = "<p>Tidak ada produk ditemukan.</p>";
    return;
  }
  items.forEach((item) => {
    if (!isRecsysString) productsStore[item.product_id] = item;

    let name,
      priceDisplay,
      reasonHtml = "";

    if (isRecsysString) {
      const match = item.match(/^\(([\d.]+%)\)\s(.+)/);
      name = match ? match[2] : item;
      priceDisplay = "";
    } else {
      name = item.product_name;
      priceDisplay = `Rp ${item.price.toLocaleString("id-ID")}`;
      if (item.reason) {
        reasonHtml = `
            <div style="background-color: #e8f4fd; border: 1px solid #b3d7ff; border-radius: 6px; padding: 4px; margin-top: 4px; font-size: 0.75rem; color: #0c5460; line-height: 1.2;">
                <span style="font-size: 1em;">💡</span> ${item.reason.substring(
                  0,
                  25
                )}...
            </div>`;
      }
    }

    const card = document.createElement("div");
    card.className =
      "bg-white rounded-lg overflow-hidden flex flex-col justify-between shadow-[0_8px_16px_-4px_rgba(0,0,0,0.2)]";
    card.innerHTML = `
      <div class="p-3">
          <p class="text-sm font-bold text-gray-600 min-h-[40px]">${name}</p>
          <div class="flex items-center mt-2">
              <div class="relative bg-[url('/assets/img/bg_gb.png')] bg-cover bg-center h-20 w-20 rounded-lg flex flex-col items-center justify-center text-white flex-shrink-0">
                  <span class="font-bold text-xl leading-none">${
                    item.data_gb || "?"
                  }</span>
                  <span class="font-bold text-xs leading-none">GB</span>
              </div>
              <div class="ml-2">
                  <p class="text-xl font-bold text-[#AF5920]">${priceDisplay}</p>
                  <p class="text-xs text-gray-500">Masa aktif ${
                    item.duration_days || 30
                  } hari</p>
                  ${reasonHtml}
              </div>
          </div>
          <p class="text-xs text-[#C66B2C] mt-2">Kuota Utama ${
            item.data_gb || 0
          } GB</p>
          <button onclick="buyProduct(${item.product_id || 0}, '${name.replace(
      /'/g,
      "\\'"
    )}')" class="inline-block font-bold rounded-lg transition duration-300 bg-primary text-white hover:bg-gray-600 w-full mt-3 py-1 open-modal-btn">BELI</button>
      </div>`;
    container.appendChild(card);
  });
}

// --- [BAGIAN UTAMA YANG DIPERBAIKI] ---
function renderProductCards(items, container) {
  container.innerHTML = "";
  if (!items || items.length === 0) {
    container.innerHTML = "<p>Data produk kosong.</p>";
    return;
  }

  items.forEach((item) => {
    // Simpan ke store agar bisa diakses Modal
    if (typeof item !== "string") productsStore[item.product_id] = item;

    let name,
      priceDisplay,
      reasonHtml = "",
      dataGb = 0,
      duration = 30,
      bonusStream = 0,
      matchBadge = "";

    if (typeof item === "string") {
      name = item;
      priceDisplay = "Cek Detail";
    } else {
      name = item.product_name;
      priceDisplay = `Rp ${item.price.toLocaleString("id-ID")}`;
      dataGb = item.data_gb || 0;
      duration = item.duration_days || 30;
      bonusStream = item.streaming_gb_bonus || 0;

      // PERBAIKAN BADGE: Style lebih modern & Z-Index diperbaiki
      if (item.final_score) {
        const scorePct = (
          Math.max(Math.min(item.final_score, 0.999), 0.01) * 100
        ).toFixed(0);
        matchBadge = `
            <div class="absolute top-6 left-6 z-20 bg-white/95 text-primary px-3 py-1.5 rounded-full text-[11px] font-bold shadow-sm border border-orange-100 backdrop-blur-sm tracking-wide uppercase">
                Match ${scorePct}%
            </div>`;
      }

      // PERBAIKAN AI INSIGHT: Layout terpisah yang rapi
      if (item.reason) {
        reasonHtml = `
            <div class="mt-4 p-3 bg-orange-50 border border-orange-100 rounded-xl flex gap-3 items-start">
                <iconify-icon icon="mdi:lightbulb-on-outline" class="text-primary text-xl shrink-0 mt-0.5"></iconify-icon>
                <div class="flex-grow">
                    <p class="text-[10px] font-bold text-primary uppercase tracking-wide mb-0.5">AI Insight</p>
                    <p class="text-xs text-gray-600 leading-relaxed">${item.reason}</p>
                </div>
            </div>`;
      }
    }

    const nameParts = parseProductName(name);
    const displayName = `${nameParts.line1}<br>${nameParts.line2}`;

    const card = document.createElement("div");
    // Layout kartu diperbaiki agar height setara
    card.className =
      "bg-[linear-gradient(270deg,#FFFFFF_18.18%,rgba(255,125,0,0.76)_98.14%)] rounded-2xl shadow-[0_10px_20px_rgba(255,125,0,0.15)] hover:shadow-[0_15px_30px_rgba(255,125,0,0.25)] transition-all duration-300 flex flex-col justify-between h-full relative overflow-hidden group";

    card.innerHTML = `
        <!-- Header Kartu (Warna Oranye) -->
        <div class="relative p-6 pt-8 pb-10 overflow-hidden rounded-t-2xl">
            ${matchBadge}
            <div class="absolute top-[-20%] right-[-10%] w-[160px] h-[160px] bg-[linear-gradient(205deg,#F9A02F_30%,#AF5920_90%)] rounded-full"></div>
            <div class="absolute top-[15%] right-[18%] w-8 h-8 bg-[#AF5920] rounded-full"></div>
            <div class="absolute top-[25%] right-[5%] w-12 h-12 bg-[#AF5920] rounded-full"></div>

            <h3 class="relative z-10 font-sans font-bold text-black text-3xl leading-tight tracking-tight drop-shadow-sm mt-8 group-hover:scale-[1.02] transition-transform duration-300 origin-left">
                ${displayName}
            </h3>
        </div>

        <!-- Body Kartu (Putih) -->
        <div class="flex-grow bg-white p-6 -mt-4 rounded-t-2xl relative z-10 flex flex-col gap-4">
            <!-- Benefits List -->
            <div>
                <h4 class="font-sans font-bold text-gray-400 text-[10px] tracking-widest uppercase mb-3">KEUNTUNGAN</h4>
                <ul class="space-y-3">
                    <li class="flex items-center text-gray-700 text-sm font-medium">
                        <div class="w-6 flex justify-center mr-2"><iconify-icon icon="iconoir:clock" class="text-lg text-gray-400"></iconify-icon></div>
                        <span>Masa aktif <b class="text-gray-900">${duration} Hari</b></span>
                    </li>
                    <li class="flex items-center text-gray-700 text-sm font-medium">
                        <div class="w-6 flex justify-center mr-2"><iconify-icon icon="mdi:database-outline" class="text-lg text-gray-400"></iconify-icon></div>
                        <span>Kuota utama <b class="text-gray-900">${dataGb} GB</b></span>
                    </li>
                    ${
                      bonusStream > 0
                        ? `
                    <li class="flex items-center text-primary text-sm font-medium">
                        <div class="w-6 flex justify-center mr-2"><iconify-icon icon="mdi:youtube" class="text-lg"></iconify-icon></div>
                        <span>Bonus Streaming <b>${bonusStream} GB</b></span>
                    </li>`
                        : ""
                    }
                </ul>
            </div>
            
            <!-- Insert AI Reason -->
            ${reasonHtml}

            <!-- Harga -->
            <div class="mt-auto pt-4 border-t border-gray-100">
                <p class="font-sans font-bold text-gray-400 text-[10px] tracking-widest uppercase mb-1">HARGA</p>
                <div class="flex items-baseline gap-1">
                    <p class="font-sans font-extrabold text-2xl text-[#AF5920]">${priceDisplay}</p>
                </div>
            </div>
        </div>

        <!-- Footer Buttons -->
        <div class="bg-white px-6 pb-6 pt-0 rounded-b-2xl flex justify-between items-center gap-3">
            <button onclick="buyProduct(${
              item.product_id || 0
            }, '${name.replace(/'/g, "\\'")}')" 
                class="flex-grow bg-primary text-white font-bold py-3 px-4 rounded-xl shadow-lg shadow-orange-200 hover:shadow-xl hover:bg-orange-600 transition-all duration-300 transform hover:-translate-y-0.5 text-sm">
                BELI
            </button>
            <button onclick="showProductDetail(${item.product_id || 0})" 
                class="px-4 py-3 text-sm font-bold text-gray-500 hover:text-primary transition-colors duration-300">
                DETAIL
            </button>
        </div>
    `;

    container.appendChild(card);
  });
}

function renderBestDealsCards(items, container, isGridMode = false) {
  container.innerHTML = "";

  items.forEach((item) => {
    // Simpan ke store
    productsStore[item.product_id] = item;

    let name = item.product_name || item;
    let price = item.price ? `Rp ${item.price.toLocaleString("id-ID")}` : "";
    let gb = item.data_gb || "?";
    let duration = item.duration_days || 30;

    const nameParts = parseProductName(name);
    const displayName = `${nameParts.line1}<br>${nameParts.line2}`;

    const card = document.createElement("div");
    let wrapperClass =
      "bg-white rounded-lg shadow-lg flex flex-col flex-shrink-0 overflow-hidden";
    wrapperClass += isGridMode ? " w-full" : " w-full max-w-sm";

    card.className = wrapperClass;

    card.innerHTML = `
      <div class="flex items-top p-3 pb-0">
        <div class="relative bg-[url('/assets/img/bg_gb.png')] bg-cover bg-center h-24 w-24 rounded-lg flex flex-col items-center justify-center text-white flex-shrink-0">
          <span class="font-bold text-2xl leading-none">${gb}</span>
          <span class="font-bold text-2xs leading-none">GB</span>
        </div>
        <div class="flex-1 pl-3 pt-2">
          <h4 class="font-semibold text-gray-800 leading-tight">${displayName}</h4>
          <p class="text-xs text-gray-600 mt-1">${gb} GB kuota utama</p>
          <a href="#" class="text-xs text-primary hover:text-gray-600 font-semibold mt-2 block" onclick="showProductDetail(${
            item.product_id || 0
          }); return false;">LIHAT DETAIL</a>
        </div>
      </div>
      <div class="p-4 pt-2">
        <hr class="my-2 border-gray-200">
        <div class="flex justify-between items-center mt-2">
            <div>
                <p class="font-bold text-lg text-gray-800">${price}</p>
                <p class="text-[10px] text-gray-400">${duration} Hari</p>
            </div>
            <button onclick="buyProduct(${
              item.product_id || 0
            }, '${name.replace(
      /'/g,
      "\\'"
    )}')" class="inline-block font-bold transition duration-300 bg-primary text-white hover:bg-gray-600 rounded-full px-6 py-2 text-sm">BELI</button>
        </div>
      </div>
    `;
    container.appendChild(card);
  });

  if (!isGridMode && window.handleScrollButtons) {
    window.handleScrollButtons();
  }
}

// ======================== ACTIONS & UTILS ========================

// 5. Logic Pembelian Real (Update DB + Pipeline)
window.buyProduct = async function (id, name) {
  const userStr = localStorage.getItem("user");
  if (!userStr) {
    Swal.fire("Error", "Silakan login terlebih dahulu.", "error");
    return;
  }
  const user = JSON.parse(userStr);

  Swal.fire({
    title: "Beli Paket?",
    text: name,
    icon: "question",
    showCancelButton: true,
    confirmButtonText: "Ya, Beli",
    confirmButtonColor: "#FF7D00",
    cancelButtonColor: "#d33",
    showLoaderOnConfirm: true,
    preConfirm: async () => {
      try {
        // 1. Catat Pembelian ke Database
        const purchaseRes = await fetch(`${API_BASE_URL}/simulate-purchase`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            customer_id: user.customer_id,
            product_id: id,
          }),
        });

        if (!purchaseRes.ok) throw new Error("Gagal memproses transaksi");

        // 2. Trigger Pipeline (Update Profil User)
        await fetch(`${API_BASE_URL}/trigger-pipeline`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ customer_id: user.customer_id }),
        });

        return true;
      } catch (error) {
        Swal.showValidationMessage(`Gagal: ${error}`);
      }
    },
    allowOutsideClick: () => !Swal.isLoading(),
  }).then((result) => {
    if (result.isConfirmed) {
      Swal.fire({
        title: "Berhasil!",
        text: "Paket aktif. Rekomendasi Anda sedang diperbarui...",
        icon: "success",
        timer: 2000,
        showConfirmButton: false,
      }).then(() => {
        // 3. Refresh Halaman / Rekomendasi
        fetchRecommendations(user.customer_id);
      });
    }
  });
};

// 6. Show Detail (Modal Dinamis)
window.showProductDetail = function (productId) {
  const product = productsStore[productId];
  if (!product) return;

  const modal = document.getElementById("detail-paket-modal");
  const container = document.getElementById("detailPaket");

  if (modal && container) {
    // Re-render isi modal dengan data produk yang diklik
    const priceDisplay = `Rp ${product.price.toLocaleString("id-ID")}`;

    container.innerHTML = `
        <div class="p-8">
            <div class="flex items-center mb-6 pb-4 relative">
                <button onclick="document.getElementById('detail-paket-modal').classList.add('hidden'); document.body.classList.remove('overflow-hidden');" class="text-primary hover:text-gray-600 absolute left-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
                    </svg>
                </button>
                <h2 class="text-3xl font-semibold text-black-800 flex-grow text-center">Detail Paket</h2>
            </div>

            <h3 class="text-xl font-semibold text-center mb-4">${
              product.product_name
            }</h3>

            <div class="space-y-4 text-gray-700">
                <div class="flex justify-between items-center">
                    <div class="flex items-center">
                        <iconify-icon icon="material-symbols:timer" class="text-primary text-3xl"></iconify-icon>
                        <span class="text-lg font-semibold ml-3">Masa aktif</span>
                    </div>
                    <span class="font-bold text-primary px-3 py-1 rounded bg-orange-50 border border-orange-100">${
                      product.duration_days || 30
                    } HARI</span>
                </div>
                <div class="flex justify-between items-center">
                    <div class="flex items-center">
                        <iconify-icon icon="mdi:internet" class="text-primary text-3xl"></iconify-icon>
                        <span class="text-lg font-semibold ml-3">Kuota Internet</span>
                    </div>
                    <span class="font-bold text-primary px-3 py-1 rounded bg-orange-50 border border-orange-100">${
                      product.data_gb || 0
                    } GB</span>
                </div>
                <div class="text-sm text-gray-600 bg-gray-50 p-4 rounded-xl border border-gray-100 mt-6">
                    <p class="font-bold text-gray-800 mb-2">Termasuk:</p>
                    <ul class="list-disc ml-4 space-y-1">
                        <li>Kuota Utama ${product.data_gb || 0} GB</li>
                        ${
                          product.streaming_gb_bonus > 0
                            ? `<li>Bonus Streaming ${product.streaming_gb_bonus} GB</li>`
                            : ""
                        }
                        ${
                          product.call_minutes_bonus > 0
                            ? `<li>Bonus Telepon ${product.call_minutes_bonus} Menit</li>`
                            : ""
                        }
                        ${
                          product.roaming_days_bonus > 0
                            ? `<li>Roaming ${product.roaming_days_bonus} Hari</li>`
                            : ""
                        }
                    </ul>
                </div>
            </div>

            <div class="mt-8 border-t border-gray-100 pt-6">
                <div class="flex justify-between items-center mb-4">
                    <span class="font-bold text-gray-500 uppercase tracking-wider text-xs">TOTAL HARGA</span>
                    <span class="font-extrabold text-2xl text-primary">${priceDisplay}</span>
                </div>
                <button onclick="buyProduct(${
                  product.product_id
                }, '${product.product_name.replace(
      /'/g,
      "\\'"
    )}')" class="block w-full bg-primary text-white font-bold rounded-xl py-4 hover:bg-orange-600 shadow-lg shadow-orange-200 transition-all transform hover:-translate-y-0.5">
                    Beli Sekarang
                </button>
            </div>
        </div>
      `;

    modal.classList.remove("hidden");
    document.body.classList.add("overflow-hidden");
  }
};

window.handleLogout = function () {
  localStorage.removeItem("user");
  window.location.href = "/login";
};

// ======================== CHATBOT ========================
function toggleChat() {
  const w = document.getElementById("chat-window");
  w.style.display = w.style.display === "flex" ? "none" : "flex";
  if (w.style.display === "flex")
    setTimeout(() => document.getElementById("chat-input").focus(), 100);
}

function handleEnter(e) {
  if (e.key === "Enter") sendChat();
}

async function sendChat() {
  const input = document.getElementById("chat-input");
  const body = document.getElementById("chat-body");
  const msg = input.value.trim();
  if (!msg) return;

  appendMsg(msg, "user");
  input.value = "";

  const loadId = "load-" + Date.now();
  body.innerHTML += `<div id="${loadId}" class="msg msg-bot">...</div>`;
  body.scrollTop = body.scrollHeight;

  try {
    const res = await fetch(`${API_BASE_URL}/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        message: msg,
        context: {
          user_name: currentUserName,
          top_product: currentTopRecommendation,
          reason: currentReason,
        },
      }),
    });
    const data = await res.json();
    document.getElementById(loadId).remove();
    appendMsg(data.reply, "bot");
  } catch (e) {
    document.getElementById(loadId).remove();
    appendMsg("Error koneksi bot.", "bot");
  }
}

function appendMsg(txt, sender) {
  const body = document.getElementById("chat-body");
  const div = document.createElement("div");

  const base =
    "max-w-[80%] px-3 py-2 rounded-xl mb-1 text-[0.8rem] leading-relaxed";

  if (sender === "user") {
    // bubble user (kanan, oranye)
    div.className = `${base} self-end bg-primary text-white`;
  } else {
    // bubble bot (kiri, krem)
    div.className = `${base} self-start bg-orange-50 border border-orange-100 text-orange-900`;
  }

  div.innerText = txt;
  body.appendChild(div);
  body.scrollTop = body.scrollHeight;
}
