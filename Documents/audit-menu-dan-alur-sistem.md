# Audit Menu, Fungsi, dan Alur Sistem — DLU X ALFATEVE

Dokumen ini memetakan **apa yang benar-benar ada dan berjalan** pada kode saat ini,
bukan rencana. Disusun dari pembacaan kode + data hidup (25 Nov 2026).

Legenda status:

| Tanda | Arti |
|---|---|
| **LIVE** | Ada UI, ada endpoint, tersambung, terverifikasi |
| **API-ONLY** | Endpoint ada dan berfungsi, belum ada layar CMS |
| **READ-ONLY** | Layar hanya menampilkan, belum ada aksi tulis |
| **PLANNED** | Belum dibangun |
| **STALE** | Ada di kode tetapi tidak sesuai model terbaru |

---

## 0. Ringkasan arsitektur

Dua aplikasi, dua database, tiga jenis klien.

```
                        ┌──────────────────────────────────────────┐
                        │       stayin_main  (server utama)        │
                        │  tenant · user · node · katalog master   │
                        │  detail film · rilis APK · sync job      │
                        │  app config · feature flag · audit       │
                        └───────────────┬──────────────────────────┘
                                        │
              CMS (Next.js) ────────────┤  Go API (APP_MODE=main)
              Super Admin + Mitra       │
                                        │  distribusi / inventory
                                        ▼
                        ┌──────────────────────────────────────────┐
                        │       stayin_local (server kapal)        │
                        │  mst_movie_local · kamar · TV · layout   │
                        │  pengumuman · command · watch log · scan │
                        └───────────────┬──────────────────────────┘
                                        │
                    ┌───────────────────┼───────────────────┐
                    ▼                   ▼                   ▼
              Android TV          TV (WebSocket)      HP penumpang
              REST + /ws/tv       /ws/remote          (belum dibangun)
```

Satu proses Go menjalankan keduanya hanya pada `APP_MODE=combined`
(kondisi dev / mini PC). Pada `main` dan `local` masing-masing hanya membuka
database-nya sendiri.

Bootstrap yang berjalan otomatis saat start: migrasi kedua DB, seed tenant
`dlu-alfateve`, akun super admin + admin mitra, mirror tenant ke DB lokal,
lalu pemindaian storage.

---

## 1. SUPER ADMIN

Akun milik owner/platform. JWT berisi `tenant_id = null`, sehingga tidak terikat
tenant mana pun dan boleh membaca semua tenant.

### 1.1 Overview — `/super-admin/overview` **LIVE**

| Blok | Isi | Sumber data |
|---|---|---|
| KPI | Tenant aktif/total, TV online/total, node online/total, penyimpanan + film siap + film menunggu distribusi | `GET /admin/overview` (gabungan main + local) |
| Grafik | Tren tontonan 7 hari | `GET /admin/overview/trend?days=7` |
| Perlu perhatian | Node offline, sync job gagal, dsb. | turunan dari data di atas |
| Tabel node | Kode, tenant, status, heartbeat | `GET /admin/nodes` |
| Tabel lisensi | Kuota TV vs pemakaian per tenant | `GET /admin/tenants` + hitung perangkat |

### 1.2 Management

| Menu | Rute | Fungsi nyata | Status |
|---|---|---|---|
| Tenant & Whitelabel | `/management/tenants` | Daftar tenant; **buat** tenant (nama, slug, kuota, warna); **suspend/aktifkan**. **Belum ada form edit** nama/branding/kuota. | LIVE (create + status), tidak ada update |
| Akun & Peran | `/management/users` | Daftar akun; buat akun (role SUPER_ADMIN/TENANT_ADMIN, tenant, password); ubah nama/email/status/password; `updateUserAction` terpasang. | LIVE |
| Content Library | `/management/movies` | Katalog **lintas tenant**: judul, tenant, status master (DRAFT/PENDING/PUBLISHED/ARCHIVED), status berkas kapal, sumber (Flashdisk/Server utama), ukuran, waktu siap; form tambah film dengan pilih tenant + `expected_filename` + opsi publish; hapus entri. | LIVE |
| Lisensi & Kuota | `/management/licenses` | Tabel kuota vs perangkat terdaftar per tenant. | READ-ONLY |

### 1.3 Offline

| Menu | Rute | Fungsi nyata | Status |
|---|---|---|---|
| Node Lokal | `/offline/nodes` | KPI node total/online/offline; tabel node: kode, tenant, status, heartbeat, versi agen. Tidak ada aksi. | READ-ONLY |
| Perangkat TV | `/offline/devices` | Semua TV lintas tenant: label, tenant, device UID, kode pairing, status, versi, terakhir terlihat. | READ-ONLY |
| Remote Command | `/offline/commands` | Kirim perintah ke perangkat tertentu (`REFRESH_CONFIG`, `RELOAD_CATALOG`, `ANNOUNCEMENT`, `RESTART_APP`, `SYNC_NOW`); riwayat + status. | LIVE |
| Antrean Sinkron | `/offline/sync-jobs` | Buat job (`MEDIA_RESCAN`, `LAYOUT_PUSH`, `CLOUD_PULL`, `APK_DISTRIBUTE`); riwayat, progres byte, error, retry. | LIVE |
| Pemindaian Media | `/offline/scans` | KPI file ditemukan/ditambah/diperbarui/hilang dari run terakhir; riwayat run (waktu, pemicu, status, durasi, counter). Tombol "Pindai sekarang". | LIVE |

Catatan: `admin.GET /inventory` ada (**API-ONLY**) — daftar mentah `mst_movie_local`.
Belum dipakai layar mana pun karena Content Library sudah menampilkan
status per film.

### 1.4 Application

| Menu | Rute | Fungsi nyata | Status |
|---|---|---|---|
| Rilis APK | `/application/releases` | Unggah APK (versi kode, versi nama, tenant, changelog, berkas) ke `Storage/Apk`; daftar rilis; aktif/nonaktif. | LIVE |
| Feature Flag | `/application/feature-flags` | Pilih tenant, lihat flag (`usb_playback`, `pwa_remote`, `announcement_bar`, `safety_video`, `apk_auto_update`), toggle per flag. | LIVE |
| Parameter Aplikasi | `/application/config` | Pilih tenant; ubah heartbeat detik, interval sinkron, versi minimum, timeout stream, teks layar jeda. | LIVE |

### 1.5 Setting

| Menu | Rute | Fungsi nyata | Status |
|---|---|---|---|
| Audit Log | `/setting/audit-logs` | Riwayat aksi administratif: waktu, aksi, entitas, peran, IP, metadata. | READ-ONLY (belum ada export CSV) |
| Profil & Keamanan | `/setting/profile` | Lihat akun aktif; ganti password (sesi diakhiri). | LIVE |

Tidak ada menu "Global Config" (retensi log, batas upload, rate limit, CORS).
Nilai-nilai itu hanya lewat env. Rencana lama menyebutnya; **belum dibangun**.

---

## 2. ADMIN MITRA (TENANT ADMIN)

Akun perusahaan mitra. `tenant_id` diambil dari JWT dan **selalu menimpa** input
apa pun dari request (anti-IDOR). Semua query difilter tenant tersebut.

### 2.1 Overview — `/tenant/overview` **LIVE**

| Blok | Isi | Sumber |
|---|---|---|
| KPI | Jumlah kamar, TV online, film siap (dari total katalog + jumlah menunggu berkas), penyimpanan, pengumuman aktif | `GET /tenant/overview` |
| Tren tontonan 7 hari | Bar chart | `GET /tenant/overview/trend` |
| Perlu tindakan | TV belum dipasangkan, film `MISSING`, persentase film punya poster | turunan |
| Film terpopuler | 5 teratas 30 hari | `GET /tenant/overview/top-movies` |
| Status TV per kamar | 8 perangkat pertama | `GET /tenant/devices` |
| Pengumuman aktif | 4 terakhir | `GET /tenant/announcements` |

### 2.2 Management

| Menu | Rute | Fungsi nyata | Status |
|---|---|---|---|
| Konten Film | `/management/movies` | Tambah film tanpa unggah video (judul, tahun, genre, sinopsis, sutradara, `expected_filename`, opsi kirim ke kapal). Tabel: poster, judul, status katalog, status berkas lokal (`PENDING/TRANSFERRING/READY/MISSING/FAILED`), sumber, ukuran, waktu siap. Unggah poster per film. Hapus entri. | LIVE |
| Kamar & Tamu VIP | `/management/rooms` | Daftar kamar + TV + tamu + **kode pairing**; check-in tamu VIP (sapaan, nama) yang langsung mendorong `ROOM_GUEST_UPDATED` ke TV kamar; check-out; tambah kamar. | LIVE |
| Tampilan TV | `/management/layout` | **Hanya halaman awal**: judul aplikasi, varian (`SPLIT_LEFT_CARD`/`FULLSCREEN_CENTER`/`BOTTOM_OVERLAY`), background, logo, warna primer/aksen, teks CTA, teks sapaan dengan variabel, toggle info kamar & jam, `overscan_percent`; simulator 16:9 dengan garis area aman. Publikasi menaikkan versi + broadcast `REFRESH_CONFIG`. | LIVE |
| Pengumuman | `/management/announcements` | Daftar pesan (pesan, severity, status, dibuat); buat pengumuman (langsung di-broadcast); toggle aktif; hapus. | LIVE |
| Status Perangkat | `/management/devices` | KPI total/online/offline; tabel kamar, label, UID, status, versi, terakhir terlihat; tombol per perangkat: Refresh (`REFRESH_CONFIG`), Katalog (`RELOAD_CATALOG`), Restart (`RESTART_APP`). | LIVE |

Tidak ada layar riwayat command atau riwayat scan untuk mitra, walau
`GET /tenant/commands` dan `GET /tenant/scans` tersedia (**API-ONLY**).
Mitra juga bisa **membaca** app config, feature flag, dan daftar rilis
(`GET` saja; menulis hanya Super Admin).

---

## 3. ANDROID TV

Aplikasi Expo. Status runtime masih terblokir (lihat §6), sehingga yang
dijelaskan di sini adalah perilaku kode, bukan hasil uji di perangkat.

### 3.1 Layar

| Layar | Isi | Data / aksi |
|---|---|---|
| Boot | Splash + cek token perangkat di SecureStore, lalu ambil `GET /tv/init` | `expo-secure-store`, cache SQLite |
| Pairing | Input kode 6 digit + alamat server; `POST /auth/device/pair` menyimpan `dvt_` token | LIVE di kode |
| Welcome | Background, logo, judul, sapaan `{guest_name}`/`{room_number}`, info kamar, jam, CTA, overscan 4% | `layout_config.welcome_screen` |
| Catalog | Hero film unggulan, baris "Lanjutkan Menonton", baris per genre (dibangun backend dari film `READY`), ticker pengumuman | `catalog.rows`, `announcements` |
| Detail | Poster, judul, tahun, genre, sinopsis, durasi; tombol Putar / Lanjutkan | `GET /tv/movies/:id`, `GET /tv/resume` |
| Player | `expo-video`; play/pause, seek ±10 detik, overlay subtitle sidecar, pelaporan progres | `GET /stream/:id` (byte-range), `POST /tv/watch-logs` |

Navigasi memakai state machine bertipe, bukan navigator, supaya BACK selalu
punya tujuan pasti dan fokus D-Pad dapat diprediksi.

### 3.2 Realtime yang ditangani TV

| Event | Efek |
|---|---|
| `WELCOME` | Konfirmasi socket + identitas perangkat |
| `COMMAND` | `RESTART_APP` → boot ulang; `REFRESH_CONFIG`/`RELOAD_CATALOG` → muat ulang init; lalu kirim `ACK` |
| `REFRESH_CONFIG` | Muat ulang seluruh konfigurasi |
| `CONTENT_UPDATED` | Muat ulang katalog |
| `ROOM_GUEST_UPDATED` | Ganti sapaan tamu tanpa reload penuh |
| `ANNOUNCEMENT` | Perbarui ticker |
| `KEY` | Tombol dari remote HP (`/ws/remote`) |

### 3.3 Kontrak TV yang tersedia

`POST /auth/device/pair`, `GET /tv/init`, `GET /tv/movies/:id`,
`POST /tv/heartbeat`, `POST /tv/watch-logs`, `GET /tv/resume`,
`GET /tv/commands`, `POST /tv/commands/:id/ack`, `GET|HEAD /stream/:id`,
`GET|HEAD /assets/*path`, `WS /ws/tv`.

**Tidak ada**: endpoint unduh APK/OTA untuk TV, endpoint diagnostik
(`/tv/diagnostics`), dan endpoint USB. `apk_auto_update` masih flag tanpa mesin.

---

## 4. ALUR SISTEM

### 4.1 Login admin

```
Browser → CMS /login (server action)
        → Go POST /auth/login
        → JWT access (8 jam) + refresh (7 hari)
        → cookie httpOnly
        → setiap request CMS: apiFetch meneruskan cookie → Go verifikasi JWT
          + cek user masih ACTIVE di stayin_main
```

Role menentukan tujuan: Super Admin → `/super-admin/overview`,
Mitra → `/tenant/overview`. Middleware `RequireRole` menolak role salah,
`RequireTenant` menolak akun tanpa tenant (jadi Super Admin tidak bisa masuk
portal mitra).

### 4.2 Konten dari CMS (tanpa unggah video)

```
Mitra/Super Admin isi form
   → POST /tenant/movies atau /admin/movies
   → stayin_main.mst_movies  status PENDING (atau DRAFT bila publish=false)
   → stayin_local.mst_movies  (mirror metadata, id sama)
   → stayin_local.mst_movie_local  status PENDING + expected_filename
   → trn_sync_jobs  DISTRIBUTE_MOVIE
        ├─ berkas sudah ada di Storage/Movies → scanner mengikat → job COMPLETED
        └─ berkas belum ada → job FAILED dengan pesan: kirim lewat flashdisk
```

### 4.3 Konten dari flashdisk

```
Kru salin film ke Storage/Movies (boleh subfolder)
   → scanner (otomatis tiap 5 menit, atau POST /tenant/scans)
   → cocokkan path, lalu cocokkan expected_filename untuk film PENDING
   → stayin_local.mst_movie_local: file_path, ukuran, container, status READY
   → checksum SHA-256 dihitung di latar belakang
   → mst_tenants.catalog_version naik → broadcast CONTENT_UPDATED
```

Jika berkas hilang saat scan berikutnya, status menjadi `MISSING`; baris tidak
dihapus agar metadata manual tetap ada.

### 4.4 Pelaporan kapal ke pusat

```
Node lokal → POST /nodes/inventory  (header X-Node-Key)
   → semua entri mst_movie_local dikirim
   → stayin_main.mst_edge_nodes.inventory diperbarui, node ditandai ONLINE
   → film berstatus READY dipromosikan menjadi PUBLISHED di katalog master
   → CMS menampilkan konten flashdisk sebagai tersedia
```

### 4.5 Pairing TV

```
CMS menampilkan kode pairing per kamar
   → kru masukkan kode di layar TV
   → POST /auth/device/pair {device_uid, pairing_code}
   → server menukar kode dengan device token `dvt_…` (disimpan sebagai hash)
   → TV simpan token di SecureStore
   → semua panggilan TV memakai header X-Device-Token
   → kode pairing tidak bisa dipakai dua kali; device_uid tidak bisa pindah baris
```

### 4.6 Menonton

```
TV buka katalog → pilih film → GET /tv/movies/:id
   → tombol Putar
   → GET /stream/:id dengan Range: bytes=…
   → 206 Partial Content + Content-Range, tanpa transcoding
   → TV kirim progres ke POST /tv/watch-logs
   → muncul di "Lanjutkan Menonton" (GET /tv/resume)
```

### 4.7 Tamu VIP

```
Mitra check-in tamu di CMS
   → stayin_local.mst_rooms diperbarui
   → broadcast ROOM_GUEST_UPDATED ke perangkat di kamar itu
   → layar welcome langsung mengganti sapaan tanpa reload
   → `GET /tv/init` berikutnya juga memuat sapaan baru
```

### 4.8 Perintah remote

```
CMS → POST /tenant|admin/devices/:id/commands
   → baris trn_remote_commands (QUEUED)
   → bila TV tersambung: kirim via WS `COMMAND`, status SENT
   → TV eksekusi lalu kirim ACK → status ACKED
   → bila TV offline: tetap QUEUED, dikirim saat tersambung / diambil lewat GET /tv/commands
```

### 4.9 Layout publikasi

```
Mitra ubah form → PUT /tenant/layout
   → validasi varian + warna + overscan
   → versi baru di mst_tv_layout_configs, versi lama is_active=false
   → broadcast REFRESH_CONFIG
   → semua TV tenant memuat ulang
```

---

## 5. MATRIKS HAK AKSES

| Kemampuan | Super Admin | Mitra | TV |
|---|---|---|---|
| Login CMS | ya | ya | — |
| Lihat semua tenant | ya | tidak | — |
| Buat/ubah tenant | buat + suspend (edit belum ada) | tidak | — |
| Kelola akun | semua akun | tidak ada menu | — |
| Katalog film | semua tenant | tenant sendiri | baca (READY saja) |
| Tambah film | ya (pilih tenant) | ya (tenant sendiri) | — |
| Kamar & tamu | tidak ada menu | ya | baca kamar sendiri |
| Layout | tidak ada menu | ya | baca |
| Pengumuman | tidak ada menu | ya | baca |
| Perintah remote | semua perangkat | tenant sendiri (3 perintah) | terima |
| Sync job | ya | buat/retry (tenant sendiri) | — |
| Pindai media | ya | ya | — |
| Rilis APK | unggah + aktif/nonaktif | baca | belum ada unduhan |
| Feature flag & app config | ubah | baca | baca (belum dipakai runtime) |
| Audit log | semua | tidak ada menu | — |

---

## 6. TEMUAN DAN CELAH

### 6.1 Sudah diperbaiki saat audit ini

**Job `DISTRIBUTE_MOVIE` selalu FAILED.** Setiap film yang dipublikasikan
membuat job, tetapi worker tidak mengenali tipenya sehingga error-nya
"tipe job tidak dikenal". Sekarang worker mengenali tipe itu: bila berkas
dengan `expected_filename` sudah ada di storage, scanner dijalankan dan job
selesai; bila belum ada, job gagal dengan pesan yang bisa ditindaklanjuti
("transfer jaringan belum tersedia, kirim lewat flashdisk"). Sudah diuji dua
arah.

### 6.2 Perlu keputusan Anda sebelum revisi

1. **Transfer berkas utama → kapal belum ada.** Job dan placeholder sudah
   siap, tetapi tidak ada mesin yang benar-benar mengunduh video dari server
   utama ke kapal. Saat ini satu-satunya jalur nyata adalah flashdisk.
   Perlu diputuskan: unduhan HTTP dengan resume, rsync, atau tetap
   flashdisk-only dan job distribusi dihapus.
2. **Super Admin belum bisa mengubah tenant.** Endpoint `PUT /admin/tenants/:id`
   ada, tetapi UI hanya punya buat + suspend. Edit branding/kuota belum bisa
   dilakukan dari layar.
3. **Lisensi read-only.** Tidak ada form ubah kuota; harus lewat edit tenant
   yang juga belum ada di UI.
4. **Portal mitra tidak punya riwayat command & scan.** Endpoint tersedia.
   Perlu diputuskan apakah kedua riwayat itu penting untuk operator kapal.
5. **PWA penumpang belum ada.** `/ws/remote` sudah menerima tombol dan
   meneruskannya ke TV, tetapi belum ada halaman `/m/room/:roomId`, QR code,
   atau autentikasi tamu.
6. **TV: tipe layout masih menyimpan `catalog_layout`/`rows_order`** yang sudah
   dihapus backend. Tidak dipakai saat runtime (katalog dibangun backend),
   tetapi tipenya menyesatkan dan komentar di `CatalogScreen` masih menyebut
   `rows_order`. Perlu dibersihkan saat TV dikerjakan.
7. **Belum ada unduhan APK di TV.** Rilis bisa diunggah dan flag
   `apk_auto_update` ada, tetapi TV tidak punya endpoint maupun layar update.
8. **Audit log belum bisa diekspor**, dan belum ada menu Global Config.
9. **Data dev saat ini**: 9 tenant, 10 akun, 1 node, 3 film (2 READY,
   1 MISSING), 12 kamar, 12 TV, 17 versi layout. Tenant dan akun sisa dari
   pengujian isolasi; perlu dibersihkan sebelum demo.

### 6.3 Kualitas dan keamanan yang sudah berjalan

- Isolasi tenant: `RequireTenant` + penimpaan `tenant_id` dari JWT; Super Admin
  ditolak di portal mitra; mitra ditolak di menu Super Admin (307 halaman,
  403 API).
- Envelope JSON konsisten, `gofmt`/`go vet`/`go test` bersih, `tsc` strict tanpa
  `any`, `next build` bersih.
- Verifikasi: 95/95 API, 10/10 WebSocket, 50 klien streaming paralel tanpa
  kegagalan.
- Streaming byte-range terverifikasi (`206`, `Content-Range`, `416`, `304`,
  `HEAD`).
