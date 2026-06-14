# Strategi Pemisahan Audio dengan Mode Ensemble (Ultimate Vocal Remover)

Dokumen ini berisi panduan strategi pemisahan audio menggunakan mode **Ensemble** di Ultimate Vocal Remover (UVR). Strategi ini dirancang untuk memaksimalkan kualitas vokal dan instrumen dengan memanfaatkan model-model terbaik yang tersedia saat ini, serta menyesuaikan kebutuhan komputasi perangkat (CPU vs GPU).

---

## Alur Kerja Ensemble UVR (Sequential Processing)
Perlu dicatat bahwa arsitektur UVR menjalankan proses pemisahan **satu per satu secara berurutan (sequential)**, bukan sekaligus secara paralel. Oleh karena itu, kita dapat menyesuaikan alokasi perangkat (CPU/GPU) untuk masing-masing model secara individual guna mengoptimalkan waktu proses dan mencegah kehabisan memori (*Out of Memory* / OOM).

---

## 1. Rekomendasi Model Ensemble (Best Practice)
Untuk hasil terbaik (Vocals & Instrumental), disarankan menggunakan kombinasi 3 hingga 4 model berikut secara berurutan:

1. **MDX-Net: Kim Vocal 2** (Fokus: Vokal Utama yang tebal dan jernih)
2. **MDX-Net: UVR-MDX-NET Inst HQ 3** (Fokus: Instrumen/Backing Track bersih tanpa *vocal bleed*)
3. **MDX23C: MDX23C-InstVoc HQ** (Fokus: Keseimbangan frekuensi tengah dan transisi vokal-instrumen yang natural)
4. **VR Architecture: 5_HP-Karaoke-UVR** (Fokus: Menekan vokal latar/backing vocal keras)

---

## 2. Pengaturan Perangkat (CPU vs GPU)
Karena model berjalan satu per satu, Anda bisa menentukan di mana masing-masing model dieksekusi:

| Model | Perangkat Terpilih | Alasan |
|---|---|---|
| **Kim Vocal 2** | GPU | Model MDX-Net membutuhkan pemrosesan spektogram intensif; sangat cepat di GPU. |
| **UVR-MDX-NET Inst HQ 3** | GPU | Memerlukan performa GPU untuk *vocal suppression* cepat. |
| **MDX23C-InstVoc HQ** | GPU (Alternatif: CPU) | Model all-rounder dengan beban memori sedang. |
| **5_HP-Karaoke-UVR** | CPU | Model VR Arch relatif lebih ringan untuk CPU dan membantu mengistirahatkan VRAM GPU agar tidak panas/OOM. |

---

## 3. Detail Algoritma & Parameter Ensemble (Kualitas Maksimal)
Pengaturan di bawah ini ditujukan untuk mendapatkan kualitas pemisahan terbaik tanpa memedulikan batasan spesifikasi perangkat.

*   **Ensemble Algorithm**: **Average** atau **Max** (Gunakan *Average* untuk hasil vokal yang natural, gunakan *Max* jika ingin instrumen yang sangat bersih).
*   **Spesifikasi Pengaturan Per Model**:

| Model | Segment Size | Overlap | Perangkat | Keterangan |
|---|---|---|---|---|
| **Kim Vocal 2** | 256 | Maksimal (8x / 0.99) | GPU | Menghasilkan vokal sangat presisi. |
| **UVR-MDX-NET Inst HQ 3** | 256 | Maksimal (8x / 0.99) | GPU | Menghilangkan sisa-sisa vokal pada track instrumen. |
| **MDX23C-InstVoc HQ** | 512 | Tinggi (4x / 0.75) | GPU | Menjaga stabilitas stereo image. |
| **5_HP-Karaoke-UVR** | 512 | Sedang (2x / 0.50) | CPU | Pembersihan frekuensi akhir. |

---

## 4. Alternatif Pengaturan untuk Perangkat Terbatas (Low-End / VRAM Rendah)
Jika komputer Anda mengalami crash OOM (Out of Memory) atau berjalan sangat lambat, gunakan alternatif konfigurasi berikut:

*   **Ensemble Algorithm**: **Average** (Lebih ringan dan stabil).
*   **Strategi Penghematan**:
    *   Pindahkan model MDX23C ke **CPU**.
    *   Turunkan **Overlap** menjadi 2x atau 4x (mengurangi beban komputasi secara drastis).
    *   Tingkatkan **Segment Size** ke 1024 jika memori VRAM sangat kecil (mengurangi jumlah pemotongan window yang harus diproses).

| Model | Segment Size | Overlap | Perangkat | Keterangan |
|---|---|---|---|---|
| **Kim Vocal 2** | 1024 | 2x / 0.50 | GPU / CPU | Mengurangi beban komputasi VRAM. |
| **UVR-MDX-NET Inst HQ 3** | 1024 | 2x / 0.50 | GPU / CPU | Pengurangan overlap meminimalkan risiko crash. |
| **MDX23C-InstVoc HQ** | 1024 | 2x / 0.50 | CPU | Dijalankan di RAM sistem (CPU) untuk mencegah OOM. |
| **5_HP-Karaoke-UVR** | 512 | 2x / 0.50 | CPU | Aman dijalankan di CPU. |

---

## 5. Tanya Jawab (Q&A) Strategi

### 1. Mengapa memilih menggunakan UVR-MDX-NET Inst HQ 3 dibanding HQ 4 atau HQ 5?
*   **Jawaban**: Seri **HQ 3** secara historis dan praktis memiliki keseimbangan paling optimal antara pembersihan vokal (*vocal suppression*) dan retensi instrumen (khususnya frekuensi tinggi seperti drum cymbals/hi-hats). Varian **HQ 4** dan **HQ 5** terkadang terlalu agresif dalam melakukan filtering, yang dapat menyebabkan efek "phaser" atau suara instrumen terdengar seperti teredam di bawah air pada genre musik tertentu.

### 2. Mengapa menggunakan segment size yang kecil (256) namun overlap maksimal?
*   **Segment Size Kecil (256)**: Membagi audio menjadi potongan-potongan resolusi waktu yang sangat kecil. Ini memungkinkan model AI mendeteksi perubahan transien vokal dan instrumen dengan sangat presisi.
*   **Overlap Maksimal**: Ketika segmen kecil digabungkan kembali, overlap yang tinggi bertindak sebagai filter perataan (smoothing). Tanpa overlap yang memadai, sambungan antar segmen akan menghasilkan bunyi klik atau artefak distorsi frekuensi tinggi (*spectral leakage*). Kombinasi segment 256 dan overlap maksimal memberikan kualitas audio akhir terhalus.
