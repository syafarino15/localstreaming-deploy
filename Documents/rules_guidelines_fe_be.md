# Rules & Guidelines: Frontend & Backend Development

Dokumen ini berisi standar, pedoman, dan praktik terbaik (*best practices*) yang wajib diikuti oleh tim pengembang Frontend (FE) dan Backend (BE) untuk menjaga kualitas, konsistensi, dan skalabilitas sistem.

---

## 1. Backend Guidelines (Golang)

### 1.1 Tech Stack & Standard Library
* **Bahasa Utama:** Go (Golang) versi 1.21+
* **Framework / Router:** Gin Web Framework / Echo / Chi (Pilih salah satu sesuai kebutuhan performa dan kesederhanaan).
* **Database Driver / ORM:** `pgx` (PostgreSQL driver) atau GORM / Ent ORM.
* **Configuration:** `viper` atau `godotenv`.
* **Logging:** `zap` (Uber) atau `zerolog` untuk structured JSON logging.
* **Testing:** Standard library `testing`, `testify` (assertions), dan `mockery` / `gomock` untuk mocking.

### 1.2 Structure & Architecture
Sistem backend menggunakan pola **Clean Architecture / Layered Architecture**:
```text
cmd/
  ├── api/
  │   └── main.go
internal/
  ├── delivery/
  │   └── http/         # Handlers, Router, Middleware
  ├── usecase/          # Business logic Layer
  ├── repository/       # Data Access Layer (Database, External APIs)
  └── domain/           # Models, Structs, Interface definitions
pkg/                    # Utility/Shared Libraries (Utils, Response Format, Auth)
config/                 # Application Configuration
db/                     # Migrations & Seeders
```

### 1.3 Coding Standards & Conventions
* **Formatting:** Wajib menggunakan `gofmt` atau `goimports`.
* **Linting:** Wajib lolos pemeriksaan `golangci-lint`.
* **Naming Conventions:**
  * Packages: `lowercase`, satu kata pendek (contoh: `user`, `auth`, `order`).
  * Structs / Interfaces: `PascalCase` (contoh: `UserRepository`, `UserService`).
  * Variables & Functions: `camelCase` untuk private, `PascalCase` untuk public/exported.
  * Constants: `PascalCase` atau `UPPER_SNAKE_CASE` sesuai lingkup.
* **Error Handling:**
  * Jangan abaikan error (`err != nil` harus diselesaikan atau di-wrap).
  * Gunakan `fmt.Errorf("context: %w", err)` untuk wrapping error.
  * Kembalikan custom domain error pada layer usecase untuk dipetakan ke status code HTTP yang sesuai pada handler.

### 1.4 REST API & Response Format
Semua respons API wajib menggunakan format JSON standar:

**Success Response:**
```json
{
  "success": true,
  "message": "Data berhasil ditemukan",
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 10,
    "total_data": 100,
    "total_page": 10
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": [
    {
      "field": "email",
      "message": "Format email tidak valid"
    }
  ]
}
```

---

## 2. Frontend Guidelines

### 2.1 Tech Stack
* **Framework:** React / Next.js dengan **TypeScript** (Wajib mode `strict`).
* **State Management:** Zustand / Redux Toolkit / React Context.
* **Data Fetching / Async State:** TanStack Query (React Query) / SWR.
* **Styling:** Tailwind CSS / CSS Modules / Shadcn UI.
* **Form & Validation:** React Hook Form + Zod.

### 2.2 Component & Folder Structure
```text
src/
  ├── assets/          # Static assets (images, icons)
  ├── components/      # Reusable UI components (Button, Modal, Input)
  ├── features/        # Feature-based modules (Auth, Dashboard, Profile)
  │   ├── components/
  │   ├── hooks/
  │   ├── services/
  │   └── types/
  ├── hooks/           # Global custom hooks
  ├── services/        # API clients (Axios instance, endpoints)
  ├── store/           # Global State Management
  ├── types/           # Global TypeScript definitions/interfaces
  └── utils/           # Helper functions
```

### 2.3 Coding Standards
* **Component Naming:** Gunakan `PascalCase` untuk nama file dan komponen (contoh: `UserProfileCard.tsx`).
* **Hooks Naming:** Awali dengan `use` menggunakan `camelCase` (contoh: `useAuth.ts`).
* **Type Safety:** Dilarang keras menggunakan tipe `any`. Gunakan `unknown` atau buatkan interface/type explisit.
* **Immutability:** Selalu jaga sifat *immutable* pada state React.

---

## 3. Integrasi FE & BE

### 3.1 Kontrak API & Dokumentasi
* **OpenAPI / Swagger:** BE wajib menyediakan spesifikasi OpenAPI yang dapat diakses di endpoint `/swagger/index.html`.
* **CORS Policy:** BE membatasi akses CORS hanya untuk domain FE yang terdaftar di konfigurasi environment.
* **Authentication:** Menggunakan **JWT (JSON Web Token)** dalam header `Authorization: Bearer <token>` atau HTTP-Only Cookies.

### 3.2 Environment Variables
* File `.env.example` wajib disediakan di repository FE dan BE.
* Data sensitif seperti DB Password, API Keys, dan JWT Secret **TIDAK BOLEH** di-commit ke Git.

---

## 4. Git & Workflow Guidelines

### 4.1 Branching Strategy
* `main` / `master`: Production-ready code.
* `staging` / `develop`: Integration & testing branch.
* `feature/<nama-fitur>`: Branch pengerjaan fitur baru.
* `bugfix/<nama-issue>` / `hotfix/<nama-issue>`: Branch perbaikan masalah.

### 4.2 Commit Message Standard (Conventional Commits)
Gunakan format standar berikut:
* `feat: tambah fitur login dengan Google`
* `fix: perbaiki kalkulasi total harga pada checkout`
* `docs: perbarui dokumentasi setup Golang`
* `refactor: optimasi query database pada user repository`
* `test: tambah unit test untuk usecase authentication`

### 4.3 Code Review & Pull Request (PR)
* Setiap PR minimal harus mendapatkan **1 approval** dari kawan tim (*peer review*) sebelum merge.
* Seluruh tes otomatis (CI/CD) dan linter wajib berhasil (*pass*) sebelum PR di-merge.