# StayIn — Deployment Bundle (POV)

Folder ini adalah paket siap-copy ke mini PC (CasaOS atau Docker biasa). Tidak
berisi source code, hanya image `.tar`, konfigurasi compose, dan skrip.

Stack ini menjalankan **dua aplikasi dengan dua database terpisah** di satu mini
PC:

| Aplikasi | Database | Peran |
|---|---|---|
| Server utama (CMS) | `stayin_main` | authoring katalog, akun admin, distribusi |
| Server lokal (kapal) | `stayin_local` | `mst_movie_local`, TV, streaming, layout |

`docker-compose.yml` memakai `APP_MODE=combined`: satu proses backend membuka
dua pool database yang tetap terpisah. `postgres/init/01-create-databases.sql`
membuat `stayin_local` saat volume pertama kali diinisialisasi.

## Isi

```
POV/
├── docker-compose.yml       # stack produksi, memakai image (bukan build)
├── docker-compose.build.yml # override untuk mesin dev (build dari ../Backend, ../Frontend)
├── .env.example             # template konfigurasi
├── nginx/default.conf       # satu origin :80, buffering dimatikan untuk /api/v1/stream
├── postgres/init/           # pembuatan stayin_main + stayin_local saat boot pertama
├── images/                  # image tar hasil export
├── scripts/
│   ├── export-images.sh     # dijalankan di mesin dev
│   ├── install.sh           # dijalankan di mini PC
│   └── healthcheck.sh
└── storage/                 # bind mount /DATA/Media
    ├── Movies/              # film hasil salin dari flashdisk
    ├── Banners/
    ├── Posters/
    └── Apk/
```

## Alur rilis (mesin dev)

```bash
cd POV
./scripts/export-images.sh 1.0.0
```

Script membangun `stayin/backend` dan `stayin/web`, menarik `postgres:16-alpine`,
lalu menulis semua image ke `images/*.tar`. Salin seluruh folder `POV` ke
flashdisk.

## Alur install (mini PC, tanpa internet)

```bash
sudo ./scripts/install.sh
./scripts/healthcheck.sh
```

`install.sh` melakukan: `docker load` semua tar, membuat `.env` beserta JWT acak,
menyiapkan folder storage, `docker compose up -d`, lalu menunggu `/healthz`.

## Alur injeksi konten (flashdisk)

Ini alur operasional utama. Tidak ada upload film besar lewat browser.

1. Salin film ke flashdisk, misalnya:

```
FLASHDISK/
└── Movies/
    ├── Laskar Pelangi (2008) 1080p.mkv
    ├── Laskar Pelangi (2008).jpg
    ├── Laskar Pelangi (2008).id.srt
    └── Action/
        ├── Inception 2010 720p.mp4
        └── catalog.json
```

2. Colokkan flashdisk ke mini PC, lalu salin ke `storage/Movies`, **atau** arahkan
   `MEDIA_HOST_DIR` di `.env` langsung ke mount flashdisk:

```
MEDIA_HOST_DIR=/media/dlu-usb
```

3. Mesin ingest akan memindai folder secara otomatis (default setiap 5 menit),
   atau klik **Scan Storage** di CMS.

4. Setiap file dipetakan menjadi baris `mst_movies` dengan:
   - `file_path` relatif terhadap media root (contoh `Movies/Action/Inception 2010 720p.mp4`)
   - URL stream `/api/v1/stream/{movie_id}` yang dipakai aplikasi TV
   - metadata detail di `mst_movie_details`

`catalog.json` opsional. Tanpa file itu, judul dan tahun diambil dari nama file,
dan file `.jpg`/`.srt` dengan nama serupa otomatis dipasangkan.

## Catatan operasional

- **IP statis**: set mini PC ke IP tetap (mis. `192.168.1.10`) agar TV tidak
  perlu dikonfigurasi ulang.
- **Tailscale**: pasang di mini PC untuk akses CMS dari kantor tanpa port
  forwarding.
- **Satu origin**: semua trafik lewat nginx port 80 supaya CORS dan scope PWA
  bersih. `/api/v1/stream` dan `/ws` diteruskan langsung tanpa buffering.
- **Backup**: volume `stayin-pgdata` menyimpan database. Folder `storage` tidak
  perlu di-backup bila isinya masih ada di flashdisk induk.
