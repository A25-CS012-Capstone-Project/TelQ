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
      const card = document.createElement("div");
      card.className = "product-card";
      card.innerHTML = `
                <div class="card-title">${p.product_name}</div>
                <p class="card-desc">Harga: Rp ${p.price.toLocaleString()}</p>
                <p class="card-desc">Data: ${p.data_gb} GB | Masa Aktif: ${
        p.duration_days
      } Hari</p>
                <div style="margin-top:10px; font-size:0.8rem; color:#666;">
                   Bonus: Stream ${p.streaming_gb_bonus}GB, Call ${
        p.call_minutes_bonus
      }mnt
                </div>
                <button onclick="buyProduct(${p.product_id}, '${
        p.product_name
      }')" class="btn-primary" style="margin-top:15px; background-color:#27ae60;">Beli Sekarang</button>
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
