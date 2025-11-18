# 🧠 Machine Learning Workspace

Folder ini adalah area kerja khusus untuk Tim ML. Karena folder ini berada di dalam struktur Backend, harap ikuti aturan berikut agar tidak merusak API Production.

## 📂 Struktur Folder
* **`notebooks/`**: Tempat file `.ipynb` untuk eksplorasi data dan training model.
* **`data/`**: Tempat menaruh file CSV/Dataset.
    * *Note: Jangan commit file CSV yang ukurannya > 50MB ke GitHub.*

## ⚠️ Aturan Penting (DOs and DON'Ts)

### 1. Jangan Sentuh `backend/requirements.txt` Sembarangan!
File `requirements.txt` di folder luar (parent folder) hanya untuk library yang dibutuhkan saat **API Berjalan** (contoh: Flask, NumPy, scikit-learn, xgboost).
* **JANGAN** masukkan `jupyter`, `matplotlib`, `seaborn` di requirements luar. Itu hanya bikin server berat.
* Jika butuh library untuk training, masukkan di `backend/ml/requirements.txt` atau install manual di environment lokal kalian.

### 2. Format Output Model
Setiap kali selesai training ulang dan mendapatkan model yang lebih bagus, simpan dengan nama yang **SAMA** agar Backend tidak perlu ubah kode.
* Contoh: Selalu simpan sebagai `xgboost_recsys.pkl`.
* Jangan pakai nama `xgboost_v1.pkl`, `xgboost_v2_final_banget.pkl`.