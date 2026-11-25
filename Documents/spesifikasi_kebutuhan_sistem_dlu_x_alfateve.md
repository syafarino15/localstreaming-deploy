# SPESIFIKASI KEBUTUHAN SISTEM (SOFTWARE REQUIREMENTS SPECIFICATION)
## Proyek: DLU X ALFATEVE (Onboard Smart Entertainment & Digital Passenger Platform)
**Versi Dokumen:** 1.0  
**Status:** Dokumen Konsolidasi Utuh (Fase 1 - Fase 3)  
**Target Platform:** Smart TV/STB Kapal, Edge Server Onboard, Central Cloud CMS, Mobile BYOD App  

---

## 1. PENDAHULUAN

### 1.1 Latar Belakang & Tujuan
PT Dharma Lautan Utama (DLU) merupakan salah satu operator pelayaran penyeberangan dan pelayaran niaga terkemuka di Indonesia. Untuk meningkatkan pengalaman penumpang (*passenger experience*), keselamatan pelayaran, serta menciptakan peluang pendapatan baru (*ancillary revenue*), DLU bekerja sama dengan AlfaTEVE untuk menghadirkan platform sistem hiburan, informasi, dan layanan digital di atas kapal.

Tujuan dari dokumen ini adalah untuk mendefinisikan secara lengkap kebutuhan fungsional dan non-fungsional dari platform **DLU X ALFATEVE** mulai dari peletakan fondasi sistem offline di atas kapal (Fase 1), integrasi ekosistem armada dan layanan penumpang (Fase 2), hingga implementasi analitik cerdas, IoT, dan monetisasi berbasis AI (Fase 3).

### 1.2 Ruang Lingkup Sistem
Sistem DLU X ALFATEVE mencakup 3 (tiga) fase pengembangan utama:
*   **Fase 1: Core System & Local Edge Launcher**  
    Fokus pada fondasi infrastruktur *Edge Local Server* di atas kapal, *Launcher Smart TV/STB* khusus kamar/lounge, *Safety Video Playback Engine*, pemutaran konten media *offline HLS*, serta *CMS Central Sync*.
*   **Fase 2: Enterprise Integration & Passenger Services**  
    Fokus pada integrasi data manifes/tiket DLU, layanan *Bring Your Own Device* (BYOD) streaming via Wi-Fi lokal, pemesanan makanan/kantin onboard (*e-room service*), serta *Emergency Override System* untuk keselamatan pelayaran.
*   **Fase 3: Smart Ecosystem, IoT Telemetry & Advanced Monetization**  
    Fokus pada integrasi sensor IoT kapal (posisi GPS, kecepatan, kondisi cuaca laut), mesin personalisasi konten berbasis AI, platform iklan terprogram (*Dynamic Ad Insertion*), serta *Store-and-Forward Data Sync Engine* untuk kondisi konektivitas maritim terputus (*offline-first*).

### 1.3 Definisi & Akronim
*   **DLU:** PT Dharma Lautan Utama.
*   **AlfaTEVE:** Platform penyedia konten hiburan dan ekosistem OTT/Smart TV.
*   **Edge Server / Local Server:** Peladen lokal yang ditempatkan di dalam ruang kontrol/server kapal untuk menyajikan konten tanpa membutuhkan koneksi internet publik berkecepatan tinggi secara terus-menerus.
*   **BYOD (Bring Your Own Device):** Konsep di mana penumpang menggunakan perangkat pribadi (smartphone/tablet) untuk mengakses layanan streaming onboard melalui jaringan Wi-Fi lokal kapal.
*   **DRM (Digital Rights Management):** Perlindungan hak cipta media streaming offline.
*   **STB (Set-Top Box):** Perangkat keras Android TV yang terhubung ke televisi di kabin/lounge penumpang.

### 1.4 Pengguna Target
1.  **Penumpang (Passengers):** Pengguna layanan hiburan, informasi pelayaran, dan pemesanan fasilitas kapal.
2.  **Kru Kapal & Kapten (Ship Crew & Officers):** Pengelola siaran darurat, pengawasan operasional onboard, dan pemrosesan pesanan kantin/kabin.
3.  **Administrator Pusat (DLU & AlfaTEVE Headquarter Admin):** Pengelola lisensi konten, penjadwalan iklan, konfigurasi perangkat armada, dan pengelola analitik bisnis.

---

## 2. DESKRIPSI ARSITEKTUR & OVERVIEW SISTEM

### 2.1 Arsitektur Hibrida (Cloud-to-Edge Architecture)
Sistem menggunakan pola arsitektur **Offline-First Hybrid Cloud-Edge**:
*   **Cloud Central (Pusat):** Mengelola pustaka konten (*content library*), manajemen armada (*fleet management*), akun & otentikasi, agregasi analitik, serta modul iklan.
*   **Ship Edge Local Server (Kapal):** Berjalan di atas infrastruktur mini server/NAS kelas maritim di setiap kapal DLU. Menyimpan cache film, episode drama, media iklan, peta lokal, serta API server lokal untuk TV dan BYOD mobile app.

```
 [ Cloud CMS Pusat (AlfaTEVE & DLU) ]
                 │
  Sync via Satellite / 4G (Docking)
                 │
                 ▼
     [ Ship Edge Local Server ] ── (Wi-Fi Onboard) ──► [ BYOD Smartphone App ]
                 │
        (LAN Ethernet Cable)
                 │
                 ▼
    [ Smart TV / STB Kabin & Lounge ]
```

### 2.2 Peta Jalan Pengembangan (Roadmap Matrix)

| Fase | Fokus Utama | Komponen Utama |
|---|---|---|
| **Fase 1** | Infrastructure & Essential Entertainment | Smart TV Launcher, Local HLS Stream, Safety Video Auto-play, Local Admin CMS |
| **Fase 2** | Passenger Engagement & DLU Integration | BYOD Mobile Web/App, Ticket Manifest Auth, Onboard Food Ordering, Emergency Broadcast |
| **Fase 3** | Smart Platform, IoT & Monetization | IoT Ship Tracking, Dynamic Ad Server, AI Content Recommendation, Store-and-Forward Sync |

---

## 3. SPESIFIKASI KEBUTUHAN FUNGSIONAL (FUNCTIONAL REQUIREMENTS)

### 3.1 FASE 1: Core System & Local Edge Launcher

#### FR-F1-01: Custom Android TV Launcher
*   **Deskripsi:** Sistem harus menyediakan antarmuka pengguna (*user interface*) kustom untuk Android TV/STB yang ramah remote control.
*   **Detail Kebutuhan:**
    1.  Tampilan Beranda (*Home Dashboard*) menampilkan ucapan selamat datang, nama kapal, rute pelayaran, dan perkiraan waktu tiba (ETA).
    2.  Kategori navigasi utama: *Film & Drama*, *TV Live/CCTV*, *Fasilitas Kapal*, *Panduan Keselamatan*, dan *Informasi Rute*.
    3.  Mendukung *branding* bersama DLU x AlfaTEVE secara dinamis.
    4.  *Kios Mode / Lock Task Mode:* Mencegah penumpang keluar ke menu pengaturan Android TV standar.

#### FR-F1-02: Local Content Streaming Engine (Offline HLS)
*   **Deskripsi:** Edge Server kapal harus memuat dan menyajikan streaming video resolusi HD (720p/1080p) tanpa koneksi internet.
*   **Detail Kebutuhan:**
    1.  Dukungan protokol HTTP Live Streaming (HLS) dengan bitrate adaptif lokal.
    2.  Kapasitas penyimpanan lokal Edge Server minimum $2\text{ TB}$ per kapal untuk menyimpan koleksi film AlfaTEVE dan video promosi DLU.
    3.  Pemberian penanda tontonan (*resume playback*) per sesi perangkat.

#### FR-F1-03: Safety Video & Mandatory Announcement Engine
*   **Deskripsi:** Pemutaran otomatis video keselamatan pelayaran (Safety Briefing) sesuai regulasi keselamatan maritim.
*   **Detail Kebutuhan:**
    1.  Sistem secara otomatis memutar video keselamatan pelayaran saat STB pertama kali dinyalakan.
    2.  Pusat kontrol kru dapat memicu (*trigger*) pemutaran video keselamatan ke seluruh TV secara bersamaan (*broadcast reset*).
    3.  Fitur interupsi: Penumpang tidak dapat melompati (*skip*) video keselamatan saat pemutaran reguler awal berlayar.

#### FR-F1-04: Digital Signage & Announcement Banner
*   **Deskripsi:** Tampilan running text dan banner pengumuman untuk informasi operasional kapal.
*   **Detail Kebutuhan:**
    1.  Admin lokal/kru kapal dapat memasukkan pesan pengumuman (misal: "Kapal akan bersandar dalam 30 menit").
    2.  Running text ditampilkan di bagian bawah layar tanpa mengganggu pemutaran video hiburan yang sedang berjalan.

#### FR-F1-05: Synchronizer & CMS Management (Lokal & Pusat)
*   **Deskripsi:** Pengelolaan konten media dan lisensi dari Cloud CMS ke Edge Server Kapal.
*   **Detail Kebutuhan:**
    1.  Kemampuan *differential update* (hanya mengunduh konten baru/perubahan data) saat kapal mendapatkan sinyal 4G/Wi-Fi pelabuhan saat bersandar (*docking*).
    2.  Verifikasi integritas file menggunakan checksum (SHA-256) sebelum konten disajikan ke pengguna.

---

### 3.2 FASE 2: Enterprise Integration & Passenger Services

#### FR-F2-01: Bring Your Own Device (BYOD) Mobile Portal
*   **Deskripsi:** Akses portal hiburan dan informasi dari smartphone/tablet penumpang melalui Wi-Fi onboard.
*   **Detail Kebutuhan:**
    1.  Captive portal pintar saat penumpang terhubung ke jaringan Wi-Fi kapal "DLU-AlfaTEVE-FreeWiFi".
    2.  PWA (Progressive Web App) dan Web Portal tanpa mengharuskan penumpang mengunduh aplikasi native dari Play Store/App Store.
    3.  Kemampuan streaming film AlfaTEVE dan cek rute kapal dari HP penumpang.

#### FR-F2-02: Integrasi Sistem Tiket & Manifes DLU
*   **Deskripsi:** Integrasi data penumpang dari DLU Ticketing System ke platform AlfaTEVE.
*   **Detail Kebutuhan:**
    1.  Penumpang dapat melakukan otentikasi login menggunakan Nomor Kode Booking Tiket DLU atau PNR.
    2.  Penerapan personalisasi ucapan di TV kabin VIP: "Selamat Datang, Bapak/Ibu [Nama Penumpang] di KM Dharma Kartika".
    3.  Informasi hak akses konten berdasarkan kelas tiket (Kabin VIP, Kelas 1, Kelas Ekonomi).

#### FR-F2-03: Onboard E-Commerce & Ordering System (Kantin/Kabin Service)
*   **Deskripsi:** Layanan pemesanan makanan, minuman, dan merchandise kapal dari TV kabin atau HP penumpang.
*   **Detail Kebutuhan:**
    1.  Katalog digital makanan/minuman kantin kapal lengkap dengan foto dan harga.
    2.  Pilihan metode pengantaran: "Antar ke Kabin (Nomor Kabin)" atau "Ambil Sendiri di Kantin".
    3.  Dashboard POS (Point of Sale) ringkas untuk kru dapur/kantin kapal untuk menerima dan memproses status pesanan.

#### FR-F2-04: Emergency & Captain Announcement Override
*   **Deskripsi:** Mekanisme pengambilalihan layar siaran saat kondisi darurat maritim.
*   **Detail Kebutuhan:**
    1.  Tombol fisik atau sakelar digital di anjungan (*bridge*) kapal yang dapat menghentikan seluruh siaran media di TV & BYOD secara instan.
    2.  Mengganti tampilan layar dengan instruksi evakuasi darurat, lokasi sekoci, dan jalur penyelamatan (*muster station*).
    3.  Pengalihan audio (*audio passthrough*) dari mikrofon pengumuman kapten ke speaker TV/STB.

#### FR-F2-05: Premium VOD & System Token Payment Gateway
*   **Deskripsi:** Pengelolaan konten berbayar (*Pay-Per-View*) atau paket Wi-Fi premium.
*   **Detail Kebutuhan:**
    1.  Dukungan pembelian token fisik/voucher yang dijual di kasir kapal.
    2.  Dukungan pembayaran online QRIS/E-Wallet saat kapal berada dalam jangkauan koneksi internet VSAT/4G.
    3.  Pencatatan transaksi keuangan offline di Edge Server dan sinkronisasi otomatis ke server keuangan pusat DLU.

---

### 3.3 FASE 3: Smart Ecosystem, IoT Telemetry & Advanced Monetization

#### FR-F3-01: Dynamic Ad Insertion (DAI) & Ad Platform Engine
*   **Deskripsi:** Platform monetisasi iklan berbasis lokasi dan demografi penumpang.
*   **Detail Kebutuhan:**
    1.  Mesin iklan yang dapat menyisipkan video ad (Pre-roll, Mid-roll) pada konten hiburan dan banner interaktif.
    2.  Geofencing Ad Trigger: Iklan produk lokal kota tujuan diputar secara otomatis ketika posisi kapal mencapai radius koordinat tertentu (misal: radius $20\text{ km}$ sebelum Pelabuhan Tanjung Perak).
    3.  Pencatatan log tayang iklan (*proof of play*) yang tervalidasi secara kriptografis di Edge Server untuk disinkronkan ke pengiklan.

#### FR-F3-02: Telemetri IoT Kapal & Interactive Voyage Map
*   **Deskripsi:** Menampilkan peta pelayaran interaktif berbasis koordinat GPS/AIS kapal secara nyata (*real-time*).
*   **Detail Kebutuhan:**
    1.  Integrasi antarmuka ke perangkat GPS/NMEA 0183/2000 kapal via jaringan LAN Edge Server.
    2.  Tampilan visual rute kapal di laut, indikator kecepatan kapal dalam knot ($\text{knots}$), cuaca laut lokal, serta estimasi waktu tiba (ETA) di pelabuhan tujuan.
    3.  Integrasi sensor lingkungan kapal (misal: suhu kabin, indikator ombak) jika tersedia.

#### FR-F3-03: Mesin Rekomendasi & AI Personalization
*   **Deskripsi:** Mesin rekomendasi cerdas berbasis kecerdasan buatan untuk konten dan penawaran promo.
*   **Detail Kebutuhan:**
    1.  Rekomendasi judul film AlfaTEVE berdasarkan riwayat tontonan dan demografi kelompok penumpang pada pelayaran tersebut.
    2.  Penawaran paket makanan kantin berbasis waktu (misal: Promo Sarapan di pagi hari, Promo Kopi di malam hari).
    3.  Model machine learning ringan (*edge-ML*) yang berjalan langsung di Edge Server tanpa membutuhkan cloud.

#### FR-F3-04: Robust Offline-First Store-and-Forward Sync Engine
*   **Deskripsi:** Mesin sinkronisasi data yang tahan terhadap kondisi jaringan terputus-putus (*intermittent connectivity*).
*   **Detail Kebutuhan:**
    1.  Seluruh transaksi (pemesanan makanan, log tayang iklan, analitik pengguna) disimpan pada antrean lokal (Local Queue DB).
    2.  Secara otomatis melakukan *handshake* dan mendistribusikan data antrean ke Cloud Pusat saat mendeteksi koneksi internet berkecepatan tinggi (docking/satellite slot).
    3.  Dukungan resolusi konflik data (*conflict resolution protocol*) berbasis timestamp.

#### FR-F3-05: Executive Analytics Dashboard (DLU & AlfaTEVE HQ)
*   **Deskripsi:** Dashboard analitik komprehensif di tingkat pusat untuk pengambil keputusan.
*   **Detail Kebutuhan:**
    1.  Metrik performa konten: Film terbanyak ditonton, total durasi menonton (*watch time*), rasio keterlibatan BYOD vs TV.
    2.  Metrik finansial: Pendapatan e-commerce onboard, penjualan voucher VOD, pendapatan iklan per rute kapal.
    3.  Metrik operasional perangkat: Status kesehatan STB (Online/Offline), performa Edge Server, penggunaan bandwidth Wi-Fi.

---

## 4. SPESIFIKASI KEBUTUHAN NON-FUNGSIONAL (NON-FUNCTIONAL REQUIREMENTS)

### 4.1 Performa (Performance Requirements)
1.  **Concurrency Video Streaming:** Edge Server kapal wajib mampu melayani streaming konkuen minimum $150$ *concurrent streams* resolusi 720p HLS (bitrate $\sim 2\text{ Mbps}$) secara simultan via Wi-Fi & LAN tanpa kecacatan frame (*frame drop* $> 2\%$).
2.  **Latency Launcher UI:** Respon antarmuka remote TV terhadap penekanan tombol tidak boleh melebihi $200\text{ ms}$.
3.  **Waktu Booting:** STB Android harus memuat (*booting*) langsung ke Launcher DLU X ALFATEVE dalam waktu kurang dari $35\text{ detik}$ sejak daya dinyalakan.

### 4.2 Keamanan & Hak Cipta (Security & DRM Requirements)
1.  **Content Protection:** Pustaka film premium AlfaTEVE wajib dilindungi dengan enkripsi media (AES-128 HLS / Widevine L3 Offline DRM) untuk mencegah penyalinan tanpa izin oleh penumpang.
2.  **Network Isolation:** Jaringan Wi-Fi hiburan penumpang wajib terisolasi (*VLAN separation*) dari jaringan navigasi utama kapal dan jaringan telemetri keselamatan.
3.  **Data Privacy:** Data pribadi dan manifes penumpang wajib dienkripsi saat disimpan (*at rest*) maupun transit (*in transit*) mengacu pada UU Perlindungan Data Pribadi (UU PDP).

### 4.3 Keandalan & Availability (Reliability & Resilience)
1.  **Offline Availability:** 100% fitur utama (streaming film, video keselamatan, peta GPS lokal, katalog kantin) harus dapat beroperasi penuh secara offline tanpa internet.
2.  **Watchdog & Auto-Recovery:** Perangkat STB dan Edge Server harus dilengkapi dengan sistem *Watchdog* otomatis yang melakukan restart layanan jika terjadi *crash* atau *freeze*.
3.  **Hardware Durability:** Perangkat keras Edge Server dan STB harus berstandar industri dengan ketahanan terhadap kelembapan tinggi, korosi uap garam laut, serta guncangan/vibrasi kapal.

### 4.4 Ketersediaan & Modulabilitas (Maintainability & Scalability)
1.  **Modular Architecture:** Menggunakan kontainerisasi (Docker/Containerd) pada Edge Server untuk memfasilitasi pembaruan perangkat lunak per modul secara independen.
2.  **Remote Diagnostics:** Kemampuan pengiriman log kesehatan sistem dan diagnostik otomatis saat kapal terhubung ke jaringan darat.

---

## 5. ANTARMUKA SISTEM & LINGKUNGAN OPERASIONAL

### 5.1 Antarmuka Perangkat Keras (Hardware Interfaces)
*   **Display:** Output HDMI 2.0+ dari STB ke TV Kabin/Lounge (Mendukung resolusi Full HD 1080p dan 4K).
*   **GPS Receiver Interface:** Koneksi RS-422 / Serial-to-Ethernet NMEA 0183 dari antena GPS kapal ke Edge Server.
*   **Network Hardware:** High-density Wi-Fi 6 Access Points (AP) yang dipasang di dek penumpang dan area publik kapal.

### 5.2 Antarmuka Perangkat Lunak & API (Software Interfaces)
*   **DLU Ticketing API:** Core RESTful API untuk verifikasi kode booking dan data kelas penumpang.
*   **AlfaTEVE DRM & Licensing Server:** API sinkronisasi lisensi tayang film dan hak cipta.
*   **Payment Gateway API:** API transaksi QRIS/E-Wallet (Xendit/Midtrans/DOKU) untuk transaksi sync mode.

---

## 6. MATRIKS TRACEABILITY & VERIFIKASI FASE

| ID Kebutuhan | Nama Fitur | Fase Target | Metode Verifikasi |
|---|---|---|---|
| **FR-F1-01** | Custom TV Launcher | Fase 1 | Uji Fungsional & UI Testing |
| **FR-F1-02** | Offline HLS Streaming | Fase 1 | Uji Beban (Load Test 150 User) |
| **FR-F1-03** | Safety Video Override | Fase 1 | Uji Regulasi & Interupsi |
| **FR-F2-01** | BYOD Web Portal | Fase 2 | Cross-browser & Cross-device Test |
| **FR-F2-02** | Integrasi Tiket DLU | Fase 2 | Integration API Test |
| **FR-F2-03** | Order Kantin / Kabin | Fase 2 | End-to-End Transaction Test |
| **FR-F2-04** | Emergency Audio/Video Override | Fase 2 | Field Test Anjungan Kapal |
| **FR-F3-01** | Dynamic Ad Insertion | Fase 3 | Geo-trigger Simulation Test |
| **FR-F3-02** | IoT Ship Telemetry & GPS | Fase 3 | Serial Data Stream Test |
| **FR-F3-04** | Store-and-Forward Sync Engine | Fase 3 | Network Disconnect/Reconnect Simulation |

---

## 7. PENUTUP & REKOMENDASI TAHAP SELANJUTNYA
Dokumen Spesifikasi Kebutuhan Sistem ini menjadi acuan baku bagi tim pengembang software dan arsitek infrastruktur. Langkah tindak lanjut setelah pengesahan dokumen ini adalah:
1.  Penyusunan **Dokumen Arsitektur Sistem (System Architecture Document / SAD)**.
2.  Pembuatan prototipe *Launcher STB Android* dan *Edge Server Minimal Viable Product (MVP)* untuk Uji Coba Lapangan (Pilot Test) pada 1 unit kapal armada DLU.
3.  Finalisasi integrasi API *DLU Ticketing Core* dan skema *content licensing* AlfaTEVE.