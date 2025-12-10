let allHistoryData = []; 

document.addEventListener("DOMContentLoaded", async () => {
  const user = JSON.parse(localStorage.getItem("user"));
  if (!user) {
    window.location.href = "/login";
    return;
  }

  const firstName = user.firstname || user.first_name || user.name || "";
  const lastName = user.lastname || user.last_name || "";

  const displayName = `${firstName} ${lastName}`.trim() || user.customer_id;

  document.getElementById("user-name").textContent = displayName;
  document.getElementById("customer-id").textContent = user.customer_id;

  await fetchProfileData(user.customer_id);
});

async function fetchProfileData(customerId) {
  try {
    const response = await fetch(
      `/api/v1/users/profile?customer_id=${customerId}`
    );
    const data = await response.json();

    if (response.ok) {
      renderHeader(data.header);
      renderPersona(data.persona_list);
      renderBehavior(data.behavior_stats);

      allHistoryData = data.history_list;
      renderHistory(allHistoryData);

      renderSummary(data.history_summary);
      renderRecommendations(data.recommendations);
    } else {
      console.error("Gagal:", data.error);
    }
  } catch (error) {
    console.error("Error fetching profile:", error);
  }
}

// 1. Render Header Badges
function renderHeader(header) {
  const container = document.getElementById("badge-container");
  const badges = [];

  // Badge Plan
  badges.push(
    `<span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-xs font-bold border border-blue-200">${header.plan}</span>`
  );
  // Badge Device
  badges.push(
    `<span class="bg-gray-100 text-gray-700 px-3 py-1 rounded-full text-xs font-semibold border border-gray-200">${header.device}</span>`
  );
  // Badge Spending
  let color =
    header.spending_tier === "high"
      ? "yellow"
      : header.spending_tier === "mid"
      ? "green"
      : "gray";
  badges.push(
    `<span class="bg-${color}-100 text-${color}-800 px-3 py-1 rounded-full text-xs font-bold border border-${color}-200 uppercase">Spending: ${header.spending_tier}</span>`
  );

  container.innerHTML = badges.join("");
}

// 2. Render Persona (Kartu Kiri)
function renderPersona(personas) {
  const container = document.getElementById("persona-list");
  container.innerHTML = personas
    .map(
      (p) => `
        <div class="flex items-start gap-3 mb-4 last:mb-0">
            <div class="text-2xl bg-white/20 w-10 h-10 flex items-center justify-center rounded-lg backdrop-blur-sm">
                ${p.icon}
            </div>
            <div>
                <h4 class="font-bold text-white text-sm">${p.title}</h4>
                <p class="text-blue-100 text-xs leading-snug">${p.desc}</p>
            </div>
        </div>
    `
    )
    .join("");
}

// 3. Render Behavior Stats
function renderBehavior(stats) {
  const fmtMoney = new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0,
  });

  document.getElementById("stat-data").textContent =
    stats.avg_data_gb.toFixed(1);
  document.getElementById("stat-spend").textContent = fmtMoney.format(
    stats.monthly_spend
  );
  document.getElementById("stat-freq").textContent = stats.topup_freq;

  // Progress Bars
  const travelPct = Math.min(stats.travel_score * 100, 100);
  document.getElementById("bar-travel").style.width = `${travelPct}%`;
  document.getElementById("val-travel").textContent =
    stats.travel_score.toFixed(2);

  const videoPct = Math.min(stats.pct_video * 100, 100);
  document.getElementById("bar-video").style.width = `${videoPct}%`;
  document.getElementById("val-video").textContent = `${videoPct.toFixed(0)}%`;
}

// 4. Render History Cards
function renderHistory(historyList) {
  const container = document.getElementById("history-container");
  const fmtMoney = new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0,
  });

  container.className = "space-y-3 max-h-[450px] overflow-y-auto pr-2";

  if (historyList.length === 0) {
    container.innerHTML =
      '<p class="text-center text-gray-400 py-4">Tidak ada riwayat pembelian.</p>';
    container.classList.remove("overflow-y-auto");
    return;
  }

  container.innerHTML = historyList
    .map((item) => {
      let borderClass = "border-gray-300";
      let tagClass = "bg-gray-100 text-gray-600";

      const cat = item.category || ""; 

      if (cat.includes("Streaming")) {
        borderClass = "border-red-500";
        tagClass = "bg-red-50 text-red-600";
      } else if (cat.includes("Roaming") || cat.includes("Travel")) {
        borderClass = "border-yellow-500";
        tagClass = "bg-yellow-50 text-yellow-600";
      } else if (cat.includes("Voice") || cat.includes("Call")) {
        borderClass = "border-blue-500";
        tagClass = "bg-blue-50 text-blue-600";
      }
      else if (cat.includes("Social") || cat.includes("Socmed")) {
        borderClass = "border-pink-500";
        tagClass = "bg-pink-50 text-pink-600";
      }
      else if (cat.includes("Gaming") || cat.includes("Game")) {
        borderClass = "border-purple-500"; 
        tagClass = "bg-purple-50 text-purple-600";
      }

      // Format Tanggal
      const dateStr = item.purchase_date
        ? new Date(item.purchase_date).toLocaleDateString("id-ID")
        : "-";

      return `
        <div class="bg-white p-4 rounded-xl shadow-sm border-l-4 ${borderClass} hover:shadow-md transition flex justify-between items-center group mr-1">
            <div>
                <div class="flex items-center gap-2 mb-1">
                    <span class="text-xs text-gray-400 font-mono">${dateStr}</span>
                    <span class="${tagClass} text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wide">
                        ${item.category}
                    </span>
                </div>
                <h4 class="font-bold text-gray-800 text-sm group-hover:text-primary transition">
                    ${item.product_name}
                </h4>
                <p class="text-xs text-gray-500 mt-1">
                    Data: <b>${item.data_gb} GB</b> | Durasi: ${
        item.duration_days
      } Hari
                </p>
            </div>
            <div class="text-right">
                <p class="font-bold text-gray-800 text-sm">${fmtMoney.format(
                  item.price
                )}</p>
                <a href="/products" class="text-[10px] text-primary hover:underline font-semibold">Beli Lagi</a>
            </div>
        </div>
        `;
    })
    .join("");
}

// 5. Fitur Filter
function filterHistory() {
  const filterValue = document.getElementById("history-filter").value;
  if (filterValue === "All") {
    renderHistory(allHistoryData);
  } else {
    const filtered = allHistoryData.filter((item) => {
      const itemCat = (item.category || "").toString();
      return itemCat.includes(filterValue);
    })
    renderHistory(filtered);
  }
}

// 6. Render Summary
function renderSummary(summary) {
  const fmtMoney = new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0,
  });
  document.getElementById("sum-trx").textContent = summary.total_trx;
  document.getElementById("sum-spend").textContent = fmtMoney.format(
    summary.total_spend
  );
  document.getElementById("sum-fav").textContent = summary.favorite_product;
}

// 7. Render Mini Recommendations
function renderRecommendations(recs) {
  const container = document.getElementById("mini-recs-container");

  if (!recs || recs.length === 0) {
    container.innerHTML =
      '<p class="text-xs text-gray-400">Belum ada rekomendasi saat ini.</p>';
    return;
  }

  container.innerHTML = recs
    .map((recStr) => {
      const cleanName = recStr.replace(/\(\d+\.\d+%\)\s*/, "");

      return `
        <div class="bg-white p-3 rounded-lg border border-gray-100 shadow-sm hover:border-purple-300 transition cursor-pointer" onclick="window.location.href='/products'">
            <h5 class="text-xs font-bold text-gray-800 mb-1">${cleanName}</h5>
            <p class="text-[10px] text-gray-500">🔥 Cocok dengan personamu</p>
        </div>
        `;
    })
    .join("");
}

// Fungsi Logout
function handleLogout() {
  localStorage.removeItem("user");
  window.location.href = "/login";
}
