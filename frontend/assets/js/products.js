const API_BASE_URL = "/api/v1";

document.addEventListener("DOMContentLoaded", () => {
  fetchAllProducts();
});

async function fetchAllProducts() {
  const container = document.getElementById("all-products-container");
  try {
    const response = await fetch(`${API_BASE_URL}/products`);
    const products = await response.json();

    container.innerHTML = "";
    products.forEach((p) => {
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

    const nameParts = parseProductName(p.product_name);
    const displayName = `${nameParts.line1}<br>${nameParts.line2}`;

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
              <li class="flex items-center"><iconify-icon icon="iconoir:clock" class="mr-2 text-xl"></iconify-icon>Masa berlaku ${p.duration_days} Hari</li>
              <li class="flex items-center"><iconify-icon icon="iconoir:clock" class="mr-2 text-xl"></iconify-icon>Kuota utama ${p.data_gb} GB</li>
          </ul>
        <div class="mt-6">
          <p class="font-semibold text-gray-500">HARGA</p>
          <p class="text-xl font-bold text-[#AF5920]">Rp ${p.price.toLocaleString()} / ${p.duration_days} Hari</p>
        </div>
      </div>
      <div class="bg-white px-6 pb-6 rounded-b-xl flex justify-between items-center">
        <button onclick="buyProduct(${p.product_id}, '${p.product_name.replace(/'/g, "\\'")}')" 
                class="font-bold transition duration-300 bg-primary text-white hover:bg-gray-600 w-20 py-2 rounded-full text-sm">
          BELI
        </button>
        <button onclick="showProductDetail(${p.product_id})" 
                class="text-xs text-primary hover:text-gray-600 font-semibold">
          LIHAT DETAIL
        </button>
      </div>
    `;
    container.appendChild(card);
  });

  } catch (error) {
    console.error(error);
    container.innerHTML = "<p>Gagal memuat produk.</p>";
  }
}

async function buyProduct(productId, productName) {
  const user = JSON.parse(localStorage.getItem("user"));
  if (!user) {
    alert("Silakan login dulu.");
    return;
  }

  if (!confirm(`Anda yakin ingin membeli "${productName}"?`)) return;

  try {
    const response = await fetch(`${API_BASE_URL}/simulate-purchase`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        customer_id: user.customer_id,
        product_id: productId,
      }),
    });

    if (response.ok) {
      alert(`Sukses membeli ${productName}!`);
      // Opsional: Arahkan kembali ke dashboard
      window.location.href = "/";
    } else {
      alert("Gagal membeli produk.");
    }
  } catch (error) {
    console.error(error);
    alert("Terjadi kesalahan koneksi.");
  }
}
