const API_URL = "/api/v1/admin";

// --- NAVIGATION LOGIC ---
function switchView(viewName) {
  // Hide all sections
  document
    .querySelectorAll(".view-section")
    .forEach((el) => el.classList.add("hidden"));
  document.querySelectorAll(".nav-item").forEach((el) => {
    el.classList.remove("bg-primary", "text-white");
    el.classList.add("text-gray-400");
  });

  // Show selected
  document.getElementById(`view-${viewName}`).classList.remove("hidden");
  const navBtn = document.getElementById(`nav-${viewName}`);
  navBtn.classList.remove("text-gray-400");
  navBtn.classList.add("bg-primary", "text-white");

  // Update Title
  const titles = {
    dashboard: "Business Overview",
    users: "User Management",
    products: "Product Catalog",
  };
  document.getElementById("page-title").innerText = titles[viewName];

  // Trigger Fetch
  if (viewName === "users") fetchUsers();
  if (viewName === "products") fetchProducts();
}

// --- DASHBOARD CHARTS (Existing) ---
document.addEventListener("DOMContentLoaded", () => {
  fetchOverview();
  fetchSalesChart();
  fetchSegmentChart();
  fetchProductChart();
});

async function fetchOverview() {
  try {
    const res = await fetch(`${API_URL}/stats/overview`);
    const data = await res.json();
    document.getElementById("total-revenue").innerText =
      "Rp " + data.total_revenue.toLocaleString("id-ID");
    document.getElementById("active-users").innerText = data.active_users;
    document.getElementById("conversion-rate").innerText =
      data.conversion_rate + "%";
    document.getElementById("model-accuracy").innerText =
      data.model_accuracy + "%";
  } catch (e) {}
}

async function fetchSalesChart() {
  const ctx = document.getElementById("salesChart").getContext("2d");
  const res = await fetch(`${API_URL}/stats/sales-trend`);
  const data = await res.json();

  new Chart(ctx, {
    type: "line",
    data: {
      labels: data.labels,
      datasets: [
        {
          label: "AI",
          data: data.series_ai,
          borderColor: "#FF7D00",
          backgroundColor: "rgba(255, 125, 0, 0.1)",
          fill: true,
          tension: 0.4,
        },
        {
          label: "Organik",
          data: data.series_organic,
          borderColor: "#94A3B8",
          borderDash: [5, 5],
          tension: 0.4,
        },
      ],
    },
    options: { responsive: true, maintainAspectRatio: false },
  });
}

async function fetchSegmentChart() {
  const ctx = document.getElementById("segmentChart").getContext("2d");
  const res = await fetch(`${API_URL}/stats/segments`);
  const data = await res.json();

  new Chart(ctx, {
    type: "doughnut",
    data: {
      labels: data.labels,
      datasets: [
        {
          data: data.data,
          backgroundColor: ["#FF7D00", "#3B82F6", "#10B981", "#8B5CF6"],
        },
      ],
    },
    options: { responsive: true, maintainAspectRatio: false },
  });
}

async function fetchProductChart() {
  const ctx = document.getElementById("productChart").getContext("2d");
  const res = await fetch(`${API_URL}/stats/top-products`);
  const data = await res.json();

  new Chart(ctx, {
    type: "bar",
    data: {
      labels: data.labels,
      datasets: [
        {
          label: "Terjual",
          data: data.data,
          backgroundColor: "#FF7D00",
          borderRadius: 5,
        },
      ],
    },
    options: { responsive: true, maintainAspectRatio: false },
  });
}

// --- USER MANAGEMENT LOGIC ---
let userChartInstance = null;
async function fetchUsers() {
  const res = await fetch(`${API_URL}/users`);
  const users = await res.json();

  const tbody = document.getElementById("users-table-body");
  tbody.innerHTML = "";

  // Render Table
  users.forEach((u) => {
    const tr = document.createElement("tr");
    tr.className = "border-b hover:bg-gray-50 transition";
    tr.innerHTML = `
                    <td class="px-6 py-4 font-bold text-gray-800">${
                      u.firstname || "User"
                    }</td>
                    <td class="px-6 py-4 font-medium text-gray-600">${
                      u.customer_id
                    }</td>
                    <td class="px-6 py-4"><span class="px-3 py-1 rounded-full text-xs font-bold ${
                      u.persona === "Streamer"
                        ? "bg-purple-100 text-purple-600"
                        : "bg-gray-100 text-gray-600"
                    }">${u.persona}</span></td>
                    <td class="px-6 py-4">${u.device_brand}</td>
                    <td class="px-6 py-4 font-bold text-green-600">Rp ${u.total_spend.toLocaleString(
                      "id-ID"
                    )}</td>
                    <td class="px-6 py-4"><span class="w-2 h-2 rounded-full bg-green-500 inline-block mr-2"></span>Active</td>
                `;
    tbody.appendChild(tr);
  });

  const sorted = [...users].sort((a, b) => b.total_spend - a.total_spend);
  const top5 = sorted.slice(0, 5);
  const bottom5 = sorted.slice(-5).reverse();

  const chartLabels = [
    ...top5.map((u) => u.customer_id),
    ...bottom5.map((u) => u.customer_id),
  ];
  const chartData = [
    ...top5.map((u) => u.total_spend),
    ...bottom5.map((u) => u.total_spend),
  ];
  const chartColors = [
    ...top5.map(() => "#10B981"),
    ...bottom5.map(() => "#EF4444"),
  ];

  const ctx = document.getElementById("userSpendChart").getContext("2d");
  if (userChartInstance) userChartInstance.destroy();
  userChartInstance = new Chart(ctx, {
    type: "bar",
    data: {
      labels: chartLabels,
      datasets: [
        {
          label: "Total Spend (Rp)",
          data: chartData,
          backgroundColor: chartColors,
          borderRadius: 5,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: { y: { beginAtZero: true } },
    },
  });
}

// --- PRODUCT MANAGEMENT LOGIC ---
let adminProductStore = {};

function toggleProductModal() {
  document.getElementById("product-modal").classList.toggle("hidden");
}

async function fetchProducts() {
  const res = await fetch(`${API_URL}/products`);
  const products = await res.json();

  const grid = document.getElementById("products-grid");
  grid.innerHTML = "";

  products.forEach((p) => {
    // Simpan ke store agar bisa dilihat detailnya
    adminProductStore[p.product_id] = p;

    // Logic render bonus secara dinamis
    let bonusHtml = "";

    // Stream
    if (p.streaming_gb_bonus > 0) {
      bonusHtml += `<p class="text-purple-500"><iconify-icon icon="mdi:youtube" class="inline mr-1"></iconify-icon> +${p.streaming_gb_bonus} GB Stream</p>`;
    }
    // Gaming
    if (p.gaming_gb_bonus > 0) {
      bonusHtml += `<p class="text-indigo-500"><iconify-icon icon="ion:game-controller" class="inline mr-1"></iconify-icon> +${p.gaming_gb_bonus} GB Game</p>`;
    }
    // Social
    if (p.social_gb_bonus > 0) {
      bonusHtml += `<p class="text-blue-500"><iconify-icon icon="mdi:instagram" class="inline mr-1"></iconify-icon> +${p.social_gb_bonus} GB Social</p>`;
    }
    // Call
    if (p.call_minutes_bonus > 0) {
      bonusHtml += `<p class="text-green-500"><iconify-icon icon="mdi:phone" class="inline mr-1"></iconify-icon> +${p.call_minutes_bonus} Min Call</p>`;
    }
    // SMS
    if (p.sms_bonus > 0) {
      bonusHtml += `<p class="text-gray-500"><iconify-icon icon="mdi:message" class="inline mr-1"></iconify-icon> +${p.sms_bonus} SMS</p>`;
    }
    // Roaming
    if (p.roaming_days_bonus > 0) {
      bonusHtml += `<p class="text-red-500"><iconify-icon icon="mdi:airplane" class="inline mr-1"></iconify-icon> +${p.roaming_days_bonus} Hari Roam</p>`;
    }

    const el = document.createElement("div");
    el.className =
      "bg-white p-5 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition flex flex-col justify-between";
    el.innerHTML = `
                    <div>
                        <div class="flex justify-between items-start mb-2">
                            <h4 class="font-bold text-lg text-gray-800 leading-tight">${
                              p.product_name
                            }</h4>
                            <span class="bg-orange-100 text-orange-600 text-xs font-bold px-2 py-1 rounded">ID: ${
                              p.product_id
                            }</span>
                        </div>
                        <p class="text-2xl font-bold text-primary mb-1">Rp ${p.price.toLocaleString(
                          "id-ID"
                        )}</p>
                        <p class="text-xs text-gray-400 mb-4">${
                          p.duration_days
                        } Hari</p>
                        
                        <div class="space-y-1 text-sm text-gray-600 mb-4 bg-gray-50 p-2 rounded-lg">
                            <p class="font-semibold"><iconify-icon icon="mdi:database" class="inline mr-1"></iconify-icon> ${
                              p.data_gb
                            } GB Utama</p>
                            <!-- Bonus Section -->
                            ${bonusHtml}
                        </div>
                    </div>
                    
                    <!-- Tombol Edit yang memicu fungsi viewProductDetail -->
                    <button onclick="viewProductDetail(${p.product_id})" 
                        class="w-full border border-gray-200 text-gray-500 py-2 rounded-lg hover:bg-gray-50 text-sm font-bold transition">
                        Edit / Detail
                    </button>
                `;
    grid.appendChild(el);
  });
}

// Fungsi menampilkan detail produk saat tombol Edit diklik
function viewProductDetail(id) {
  const p = adminProductStore[id];
  if (!p) return;

  Swal.fire({
    title: `<strong>${p.product_name}</strong>`,
    html: `
            <div class="text-left text-sm space-y-2">
                <p><strong>Harga:</strong> Rp ${p.price.toLocaleString(
                  "id-ID"
                )}</p>
                <p><strong>Durasi:</strong> ${p.duration_days} Hari</p>
                <p><strong>Data Utama:</strong> ${p.data_gb} GB</p>
                <hr>
                <p class="font-bold text-primary">Bonus:</p>
                <ul class="list-disc pl-5">
                    <li>Streaming: ${p.streaming_gb_bonus} GB</li>
                    <li>Gaming: ${p.gaming_gb_bonus} GB</li>
                    <li>Social: ${p.social_gb_bonus} GB</li>
                    <li>Call: ${p.call_minutes_bonus} Mins</li>
                    <li>SMS: ${p.sms_bonus}</li>
                    <li>Roaming: ${p.roaming_days_bonus} Hari</li>
                </ul>
                <hr>
                <p><strong>Target Offer:</strong> ${p.target_offer}</p>
            </div>
        `,
    showCloseButton: true,
    showCancelButton: false,
    confirmButtonText: "Tutup",
    confirmButtonColor: "#FF7D00",
  });
}

// Add Product Form Submit
document
  .getElementById("add-product-form")
  .addEventListener("submit", async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());

    if (data.streaming_gb && !data.streaming_gb_bonus)
      data.streaming_gb_bonus = data.streaming_gb;
    if (data.call_minutes && !data.call_minutes_bonus)
      data.call_minutes_bonus = data.call_minutes;
    if (data.roaming_days && !data.roaming_days_bonus)
      data.roaming_days_bonus = data.roaming_days;

    const parseSafeFloat = (val) => {
      if (val === undefined || val === null || val === "") return 0;
      const num = parseFloat(val);
      return isNaN(num) ? 0 : num; 
    };

    const numericFields = [
      "price",
      "data_gb",
      "duration_days",
      "streaming_gb_bonus",
      "gaming_gb_bonus",
      "social_gb_bonus",
      "call_minutes_bonus",
      "sms_bonus",
      "roaming_days_bonus",
    ];

    numericFields.forEach((key) => {
      data[key] = parseSafeFloat(data[key]);
    });

    if (data.duration_days <= 0) {
      data.duration_days = 30;
    }

    // Auto set target offer
    data["target_offer"] = "General Offer";
    if (data.streaming_gb_bonus > 0) data["target_offer"] = "Streaming Offer";
    if (data.gaming_gb_bonus > 0) data["target_offer"] = "Gaming Offer";
    if (data.roaming_days_bonus > 0) data["target_offer"] = "Roaming Offer";
    if (data.social_gb_bonus > 0) data["target_offer"] = "Social Offer";
    if (data.call_minutes_bonus > 0) data["target_offer"] = "Voice Offer";

    try {
      const res = await fetch(`${API_URL}/products`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      if (res.ok) {
        Swal.fire("Sukses!", "Produk berhasil ditambahkan.", "success");
        toggleProductModal();
        e.target.reset();
        fetchProducts(); // Refresh list
      } else {
        const errData = await res.json();
        Swal.fire("Gagal", errData.error || "Terjadi kesalahan.", "error");
      }
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "Gagal menghubungi server.", "error");
    }
  });
