# Form Data Submission: AIClub Showcase

Gunakan teks berikut saat mengunggah karya ke https://aiclub.id/showcase/ (atau halaman submit):

---

### 1. Judul Karya (Title)
```text
UMKMense Pro: AI Financial Agent (WhatsApp Edition)
```

---

### 2. Tagline / Ringkasan Singkat (Short Description)
```text
Asisten finansial cerdas WhatsApp untuk UMKM: catat transaksi via voice note, ekstraksi nota/struk otomatis, ekspor Excel, dan monitor kasbon terjadwal dengan 7-tier AI failover.
```

---

### 3. Kategori & Tags (Pills)
* **Kategori:** Open Source / Automation / Artificial Intelligence
* **Tags:** `n8n`, `WhatsApp`, `Gemini`, `Groq`, `Evolution-API`, `UMKM`, `Finance`, `Multimodal`

---

### 4. Link Proyek (Repository / Project Link)
```text
https://github.com/ucuk048/umkmense-pro
```
*(Ganti `username` dengan nama akun GitHub Anda)*

---

### 5. Narasi / Konten Deskripsi Karya (Markdown Body)

```markdown
### Latar Belakang Masalah
Banyak pemilik UMKM di Indonesia kesulitan menjaga pembukuan arus kas karena keterbatasan waktu dan rumitnya aplikasi akuntansi konvensional. Nota belanja tercecer, piutang kasbon pelanggan lupa ditagih, dan rekap laba-rugi tidak pernah tercatat rapi.

### Solusi: UMKMense Pro
UMKMense Pro menghadirkan asisten keuangan otonom langsung di WhatsApp tanpa perlu instalasi aplikasi baru bagi pedagang:

1. **Multimodal Native:** Cukup kirimkan foto nota/struk belanja atau voice note rekaman suara ("Catat martabak laku 3 bungkus 75 ribu"), AI langsung mengekstrak entitas dan mencatatnya ke buku kas.
2. **Zero-Downtime 7-Tier Failover:** Dilengkapi cascade model AI (Gemini Utama, 2 Gemini Cadangan, Groq LLaMA 3.3 70B, dan 3 Vibe/Grok Model) sehingga bot tidak pernah mati saat salah satu API terkena limit kuota.
3. **Penyelamat Biaya (Deterministik Fast Path):** Perintah salam/menu dan rekapitulasi rutin diproses langsung oleh database tanpa memanggil token LLM (< 500 ms).
4. **Ekspor Excel (.xlsx) Sekali Klik:** Pengguna cukup mengetik "ekspor excel", sistem menghasilkan spreadsheet formal dan mengirimkannya kembali ke WhatsApp.
5. **Autonomous Kasbon Reminder:** Scheduler otomatis yang mendeteksi tanggal jatuh tempo kasbon pelanggan dan mengirimkan pesan penagihan berkala secara sopan.

### Arsitektur Teknologi
* **Workflow Engine:** n8n (v2.35+)
* **WhatsApp Gateway:** Evolution API v2 (Multi-Device QR Pairing)
* **AI Models:** Google Gemini 2.5 Flash, Groq Cloud (LLaMA-3.3 70B), Vibe AI
* **Storage & DB:** SQLite / PostgreSQL & n8n Data Tables
* **Deployment:** Docker & 1-Click Batch Automation (`START_UMKMENSE_BOT.bat`)
```
