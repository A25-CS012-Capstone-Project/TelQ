const API_BASE_URL = "/api/v1";
let currentUserName = "User";
let productsStore = {}; 

document.addEventListener("DOMContentLoaded", () => {
  checkAuth();

  loadProductsByCategory("Streaming", "streaming-container");
  loadProductsByCategory("Gaming", "gaming-container");
  loadProductsByCategory("Hemat", "hemat-container");
  loadProductsByCategory("Voice", "voice-container");
  loadProductsByCategory("Roaming", "roaming-container");
  loadProductsByCategory("Social", "sosmed-container");

  setupMobileMenu();
});

function setupMobileMenu() {
  const btn = document.getElementById("mobile-menu-button");
  const menu = document.getElementById("mobile-menu");

  if (btn && menu) {
    btn.addEventListener("click", () => {
      menu.classList.toggle("hidden");
    });

    const links = menu.querySelectorAll("a");
    links.forEach((link) => {
      link.addEventListener("click", () => {
        menu.classList.add("hidden");
      });
    });
  }
}

function checkAuth() {
  const userStr = localStorage.getItem("user");
  if (!userStr) window.location.href = "/login";
  const user = JSON.parse(userStr);
  currentUserName = user.firstname || "User";
  const nameEl =
    document.querySelector("#user-name span") ||
    document.getElementById("user-name");
  if (nameEl) nameEl.textContent = `Halo, ${currentUserName}!`;
}

// ======================= FETCH DATA =======================
async function loadProductsByCategory(category, containerId) {
  const container = document.getElementById(containerId);
  if (!container) return;
  container.innerHTML = `<p class="col-span-full text-center py-10 text-gray-500">Memuat paket ${category}...</p>`;
  try {
    const res = await fetch(`${API_BASE_URL}/products?category=${category}`);
    const products = await res.json();
    if (products.length === 0) {
      container.innerHTML = `<p class="col-span-full text-center py-10">Tidak ada produk kategori ini.</p>`;
    } else {
      renderCategoryCards(products, container);
    }
  } catch (e) {
    console.error(e);
    container.innerHTML = `<p class="col-span-full text-center text-red-500">Gagal memuat data.</p>`;
  }
}

// ======================= HELPER =======================
const parseProductName = (name) => {
  const words = name.trim().split(/\s+/);
  if (words.length >= 2) {
    if (words[0].includes("GB") || words[1].includes("GB")) {
      const gbIndex = words.findIndex((w) => w.includes("GB"));
      return {
        line1: words.slice(0, gbIndex).join(" "),
        line2: words.slice(gbIndex).join(" "),
      };
    } else {
      return {
        line1: words.slice(0, 2).join(" "),
        line2: words.slice(2).join(" ") || "",
      };
    }
  }
  return { line1: words[0], line2: "" };
};

window.scrollToSection = function (id) {
  const el = document.getElementById(id);
  if (el) el.scrollIntoView({ behavior: "smooth", block: "start" });
};

// ======================= RENDER CARDS =======================
function renderCategoryCards(items, container) {
  container.innerHTML = "";
  items.forEach((item) => {
    productsStore[item.product_id] = item;

    let name = item.product_name;
    let priceDisplay = `Rp ${item.price.toLocaleString("id-ID")}`;
    let dataGb = item.data_gb || 0;
    let duration = item.duration_days || 30;

    const nameParts = parseProductName(name);
    const displayName = `${nameParts.line1}<br>${nameParts.line2}`;

    const card = document.createElement("div");
    card.className =
      "bg-[linear-gradient(270deg,#FFFFFF_22.18%,rgba(255,125,0,0.76)_98.14%)] rounded-xl shadow-[5px_7px_4px_rgba(0,0,0,0.25)] flex flex-col justify-between h-full group hover:scale-[1.02] transition-transform duration-300 min-w-[85vw] sm:min-w-[350px] snap-center flex-shrink-0";

    card.innerHTML = `
            <div class="p-6 relative overflow-hidden rounded-t-xl">
                <div class="absolute top-20 -right-20 w-40 h-40 bg-[linear-gradient(205.41deg,#F9A02F_29.39%,#AF5920_92.11%)] rounded-full"></div>
                <div class="absolute top-12 right-[4.5em] w-8 h-8 bg-[#AF5920] rounded-full"></div>
                <div class="absolute top-16 right-6 w-16 h-16 bg-[#AF5920] rounded-full"></div>
                <h3 class="text-3xl font-semibold leading-tight relative z-10 text-gray-800">${displayName}</h3>
            </div>
            
            <div class="bg-white p-6 rounded-t-2xl flex-grow flex flex-col">
                <h4 class="font-semibold text-gray-500 mb-3 text-xs tracking-widest">KEUNTUNGAN</h4>
                <ul class="space-y-2 text-black text-sm flex-grow">
                    <li class="flex items-center"><iconify-icon icon="iconoir:clock" class="mr-2 text-xl text-gray-400"></iconify-icon>Masa berlaku ${duration} Hari</li>
                    <li class="flex items-center"><iconify-icon icon="mdi:database-outline" class="mr-2 text-xl text-gray-400"></iconify-icon>Kuota utama ${dataGb} GB</li>
                </ul>
                <div class="mt-6 border-t pt-4">
                    <p class="font-semibold text-gray-500 text-xs">HARGA</p>
                    <p class="text-xl font-bold text-primary">${priceDisplay}</p>
                </div>
            </div>
            
            <div class="bg-white px-6 pb-6 rounded-b-xl flex justify-between items-center gap-3">
                <button onclick="buyProduct(${item.product_id}, '${name.replace(
      /'/g,
      "\\'"
    )}')" class="flex-grow bg-primary text-white font-bold py-3 px-4 rounded-xl shadow-lg hover:bg-orange-600 transition text-sm cursor-pointer">BELI</button>
                <button onclick="showProductDetail(${
                  item.product_id
                })" class="px-4 py-3 text-sm font-bold text-gray-500 hover:text-primary transition cursor-pointer">DETAIL</button>
            </div>
        `;
    container.appendChild(card);
  });
}

// ======================= FITUR BELI & DETAIL =======================

// 1. Fungsi Beli
window.buyProduct = async function (id, name) {
  const userStr = localStorage.getItem("user");
  if (!userStr) {
    Swal.fire("Error", "Silakan login dulu.", "error");
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
        const purchaseRes = await fetch(`${API_BASE_URL}/simulate-purchase`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            customer_id: user.customer_id,
            product_id: id,
          }),
        });

        if (!purchaseRes.ok) throw new Error("Gagal beli");

        // Update profil AI background
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
    if (result.isConfirmed) Swal.fire("Berhasil!", "Paket aktif.", "success");
  });
};

// 2. Fungsi Tampilkan Detail (PENTING)
window.showProductDetail = function (productId) {
  const product = productsStore[productId];
  if (!product) return;

  const modal = document.getElementById("detail-paket-modal");
  const container = document.getElementById("detailPaket");

  if (modal && container) {
    const priceDisplay = `Rp ${product.price.toLocaleString("id-ID")}`;

    let bonusStream = product.streaming_gb_bonus || 0;
    let bonusGame = product.gaming_gb_bonus || 0;
    let bonusCall = product.call_minutes_bonus || 0;
    let bonusRoam = product.roaming_days_bonus || 0;
    let bonusSocmed = product.social_gb_bonus || 0;

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
                        <iconify-icon icon="material-symbols:timer" class="text-primary text-4xl"></iconify-icon>
                        <span class="text-xl font-semibold flex-grow text-left ml-3">Masa aktif</span>
                        <span class="font-bold text-primary px-2 py-1 rounded"> ${
                          product.duration_days || 30
                        } HARI</span>
                    </div>
                    <div class="flex justify-between items-center">
                        <iconify-icon icon="mdi:internet" class="text-primary text-4xl"></iconify-icon>
                        <span class="text-xl font-semibold flex-grow text-left ml-3">Kuota Internet</span>
                        <span class="font-bold text-primary px-2 py-1 rounded">${
                          product.data_gb || 0
                        } GB</span>
                    </div>
                    <div class="text-sm text-gray-600 bg-gray-50 p-3 rounded-lg border border-gray-100 mt-4">
                        <p class="font-semibold text-gray-800">Termasuk:</p>
                        <ul class="list-disc ml-4 mt-1 text-primary">
                            <li>Kuota Utama ${product.data_gb || 0} GB</li>
                            ${
                              bonusStream > 0
                                ? `<li>Bonus Streaming ${bonusStream} GB</li>`
                                : ""
                            }
                            ${
                              bonusGame > 0
                                ? `<li>Bonus Gaming ${bonusGame} GB</li>`
                                : ""
                            }
                            ${
                              bonusCall > 0
                                ? `<li>Bonus Telepon ${bonusCall} Menit</li>`
                                : ""
                            }
                            ${
                              bonusRoam > 0
                                ? `<li>Bonus Roaming ${bonusRoam} Hari</li>`
                                : ""
                            }
                            ${
                              bonusSocmed > 0
                                ? `<li>Bonus Sosmed ${bonusSocmed} GB</li>`
                                : ""
                            }
                        </ul>
                    </div>
                </div>

                <div class="mt-6 border-t border-primary pt-4">
                    <div class="flex justify-between items-center">
                        <iconify-icon icon="solar:dollar-bold" class="text-primary text-4xl"></iconify-icon>
                        <span class="font-semibold text-xl flex-grow text-left ml-3">Total Harga</span>
                        <span class="font-bold text-primary px-2 py-1 rounded">${priceDisplay}</span>
                    </div>
                    <button onclick="buyProduct(${
                      product.product_id
                    }, '${product.product_name.replace(
      /'/g,
      "\\'"
    )}')" class="inline-block font-bold rounded-lg transition duration-300 bg-primary text-white hover:bg-gray-600 w-full py-3 mt-6 text-center">
                        Beli Sekarang
                    </button>
                </div>
            </div>
        `;
    modal.classList.remove("hidden");
    document.body.classList.add("overflow-hidden");
  }
};
