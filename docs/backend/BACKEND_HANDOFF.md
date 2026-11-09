# Panenara Admin Panel — Handoff Backend

> Dokumen ini ditujukan untuk **developer backend** yang akan membangun REST API  
> untuk mendukung panel admin Flutter web platform agritech **Panenara**.

---

## Ringkasan

Panenara adalah platform agritech berbasis web yang menghubungkan **petani**, **pembeli komoditas**, dan **investor** melalui sistem lelang digital. Panel admin ini berfungsi sebagai pusat kendali operasional platform dengan dua level akses:

| Role | Tanggung Jawab |
|---|---|
| **Super Admin** | Manajemen admin, pengaturan sistem, laporan global, audit log |
| **Admin (Ops)** | Verifikasi petani, monitoring lelang & transaksi, penanganan pengaduan |

Panel dibangun menggunakan **Flutter Web** dan berkomunikasi sepenuhnya via REST API dengan autentikasi JWT Bearer token.

---

## Daftar Endpoint

### Auth
- [ ] `POST /auth/login`
- [ ] `POST /auth/refresh`
- [ ] `POST /auth/logout`
- [ ] `GET  /auth/me`

### Super Admin — Dashboard
- [ ] `GET /admin/dashboard/super`

### Super Admin — Manajemen Admin
- [ ] `GET    /admin/admins`
- [ ] `POST   /admin/admins`
- [ ] `PATCH  /admin/admins/{id}`
- [ ] `PATCH  /admin/admins/{id}/status`

### Super Admin — Manajemen Pengguna
- [ ] `GET   /admin/users`
- [ ] `GET   /admin/users/{id}`
- [ ] `PATCH /admin/users/{id}/status`

### Super Admin — Laporan
- [ ] `GET /admin/reports/summary`
- [ ] `GET /admin/reports/monthly-volume`
- [ ] `GET /admin/reports/top-commodities`
- [ ] `GET /admin/reports/export`

### Super Admin — Pengaturan & Log
- [ ] `GET /admin/settings`
- [ ] `PUT /admin/settings`
- [ ] `GET /admin/audit-logs`

### Admin (Ops) — Dashboard
- [ ] `GET /admin/dashboard/ops`

### Admin (Ops) — Verifikasi Petani
- [ ] `GET  /admin/farmer-verifications`
- [ ] `GET  /admin/farmer-verifications/{id}`
- [ ] `POST /admin/farmer-verifications/{id}/approve`
- [ ] `POST /admin/farmer-verifications/{id}/request-revision`
- [ ] `POST /admin/farmer-verifications/{id}/reject`

### Admin (Ops) — Transaksi
- [ ] `GET /admin/transactions`
- [ ] `GET /admin/transactions/{id}`

### Admin (Ops) — Lelang
- [ ] `GET /admin/auctions`
- [ ] `GET /admin/auctions/{id}`

### Admin (Ops) — Pengaduan
- [ ] `GET   /admin/complaints`
- [ ] `GET   /admin/complaints/{id}`
- [ ] `PATCH /admin/complaints/{id}`
- [ ] `POST  /admin/complaints/{id}/replies`

---

## Cara Menjalankan Flutter Web Panel

### Mode Mock (tanpa backend nyata)
```bash
flutter run -d chrome --dart-define=USE_MOCK=true
```
> Semua request akan dilayani oleh mock data lokal di Flutter. Gunakan ini untuk  
> pengembangan UI tanpa server.

### Mode Production / Staging (terhubung ke backend)
```bash
flutter run -d chrome --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.panenara.id/v1
```
> Ganti `API_BASE_URL` dengan URL server staging/production Anda.

---

## Seed Data

### Akun Super Admin

| Field | Nilai |
|---|---|
| Email | `bagas@panenara.id` |
| Password | `Admin123!` |
| Role | `super_admin` |

### Akun Admin Operasional

| Field | Nilai |
|---|---|
| Email | `rina@panenara.id` |
| Password | `Admin123!` |
| Role | `admin` |

### SQL INSERT

```sql
-- Langkah 1: Generate hash di aplikasi atau shell
-- node -e "const b=require('bcrypt'); b.hash('Admin123!',10).then(console.log)"
-- Contoh hasil: $2b$10$XxXxXxXxXxXxXxXxXxXxXeXxXxXxXxXxXxXxXxXxXxXxXxXxXxX

-- Super Admin
INSERT INTO users (id, name, email, password_hash, role, status)
VALUES (
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'Bagas Nugroho',
  'bagas@panenara.id',
  '<bcrypt_hash_Admin123!>',
  'super_admin',
  'active'
);
INSERT INTO admin_profiles (user_id, access_level)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'full');

-- Admin Ops
INSERT INTO users (id, name, email, password_hash, role, status)
VALUES (
  'b2c3d4e5-f6a7-8901-bcde-f12345678901',
  'Rina Lestari',
  'rina@panenara.id',
  '<bcrypt_hash_Admin123!>',
  'admin',
  'active'
);
INSERT INTO admin_profiles (user_id, access_level)
VALUES ('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'full');
```

> [!CAUTION]
> **Jangan** menyimpan password plaintext di database. Selalu gunakan `bcrypt` dengan cost ≥ 10.

---

## Contoh Request / Response

### 1. Login

**Request**
```http
POST /auth/login
Content-Type: application/json

{
  "email": "bagas@panenara.id",
  "password": "Admin123!"
}
```

**Response 200**
```json
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhMWIyYzNkNCIsInJvbGUiOiJzdXBlcl9hZG1pbiIsImV4cCI6MTcwMDAwMDkwMH0.sig",
    "refresh_token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhMWIyYzNkNCIsInR5cGUiOiJyZWZyZXNoIiwiZXhwIjoxNzAwNjA0ODAwfQ.sig",
    "user": {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "name": "Bagas Nugroho",
      "email": "bagas@panenara.id",
      "role": "super_admin"
    }
  }
}
```

**Response 401**
```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Email atau password salah.",
    "fields": {}
  }
}
```

---

### 2. GET /auth/me

**Request**
```http
GET /auth/me
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response 200**
```json
{
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "name": "Bagas Nugroho",
    "email": "bagas@panenara.id",
    "role": "super_admin"
  }
}
```

---

### 3. GET /admin/dashboard/super

**Request**
```http
GET /admin/dashboard/super
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response 200**
```json
{
  "data": {
    "total_users": 1240,
    "total_admins": 8,
    "total_transactions_this_month": 42,
    "volume_this_month_idr": 650000000,
    "active_auctions": 12,
    "open_complaints": 5,
    "pending_verifications": 18,
    "recent_audit_logs": [
      {
        "id": "d0e1f2a3-b4c5-6789-3456-890123456789",
        "actor_name": "Rina Lestari",
        "action": "APPROVE_FARMER_VERIFICATION",
        "module": "farmer_verification",
        "ip_address": "203.0.113.42",
        "meta": { "farmer_name": "Budi Santoso" },
        "created_at": "2025-04-10T10:05:00Z"
      }
    ]
  }
}
```

---

### 4. GET /admin/farmer-verifications

**Request**
```http
GET /admin/farmer-verifications?status=waiting&page=1&pageSize=20
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response 200**
```json
{
  "data": [
    {
      "id": "e5f6a7b8-c9d0-1234-ef01-345678901234",
      "user": {
        "id": "c3d4e5f6-a7b8-9012-cdef-123456789012",
        "name": "Budi Santoso",
        "email": "budi@example.com"
      },
      "verification_status": "waiting",
      "review_note": null,
      "reviewed_by": null,
      "reviewed_at": null,
      "documents": [
        { "id": "...", "type": "ktp",   "url": "https://cdn.panenara.id/docs/ktp_budi.jpg",   "created_at": "2025-01-05T07:30:00Z" },
        { "id": "...", "type": "selfie","url": "https://cdn.panenara.id/docs/selfie_budi.jpg","created_at": "2025-01-05T07:31:00Z" },
        { "id": "...", "type": "lahan", "url": "https://cdn.panenara.id/docs/lahan_budi.jpg", "created_at": "2025-01-05T07:32:00Z" }
      ],
      "created_at": "2025-01-05T07:00:00Z"
    }
  ],
  "meta": { "page": 1, "pageSize": 20, "total": 18, "totalPages": 1 }
}
```

---

### 5. POST /admin/farmer-verifications/{id}/approve

**Request**
```http
POST /admin/farmer-verifications/e5f6a7b8-c9d0-1234-ef01-345678901234/approve
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response 200**
```json
{
  "data": {
    "id": "e5f6a7b8-c9d0-1234-ef01-345678901234",
    "verification_status": "verified",
    "reviewed_by": {
      "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "name": "Rina Lestari"
    },
    "reviewed_at": "2025-04-10T10:05:00Z"
  }
}
```

---

### 6. GET /admin/complaints

**Request**
```http
GET /admin/complaints?status=open&priority=high&page=1&pageSize=20
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response 200**
```json
{
  "data": [
    {
      "id": "c9d0e1f2-a3b4-5678-2345-789012345678",
      "reporter": { "id": "...", "name": "Ahmad Fauzi", "role": "petani" },
      "category": "Pembayaran tidak diterima",
      "summary": "Pembayaran lelang belum masuk setelah 7 hari",
      "priority": "high",
      "status": "open",
      "assigned_to": null,
      "replies": [],
      "created_at": "2025-04-23T09:00:00Z",
      "updated_at": "2025-04-23T09:00:00Z"
    }
  ],
  "meta": { "page": 1, "pageSize": 20, "total": 5, "totalPages": 1 }
}
```

---

### 7. PATCH /admin/complaints/{id}

**Request**
```http
PATCH /admin/complaints/c9d0e1f2-a3b4-5678-2345-789012345678
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
Content-Type: application/json

{
  "status": "in_progress",
  "assigned_to": "b2c3d4e5-f6a7-8901-bcde-f12345678901"
}
```

**Response 200**
```json
{
  "data": {
    "id": "c9d0e1f2-a3b4-5678-2345-789012345678",
    "status": "in_progress",
    "assigned_to": {
      "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "name": "Rina Lestari"
    },
    "updated_at": "2025-05-01T11:00:00Z"
  }
}
```

---

## Urutan Pengerjaan yang Disarankan

Urutan berikut dirancang untuk memungkinkan tim Flutter segera melakukan integrasi end-to-end secepat mungkin:

| Prioritas | Modul | Alasan |
|:---------:|---|---|
| **1** | Auth (login, refresh, logout, me) | Semua endpoint lain bergantung pada token |
| **2** | Verifikasi petani | Fitur operasional utama, dibutuhkan demo awal |
| **3** | Lelang & Transaksi | Inti bisnis platform, monitoring volume |
| **4** | Pengaduan | Kritis untuk kepuasan pengguna |
| **5** | Laporan & Ekspor | Dapat di-mock dulu dengan data statis |
| **6** | Pengaturan sistem & Audit log | Fitur super admin, dikerjakan terakhir |

---

## Penyimpanan Token di Flutter Web

> [!IMPORTANT]
> `flutter_secure_storage` pada platform **web** menggunakan **`localStorage`** sebagai storage backend — bukan keychain/keystore yang aman. Data ini dapat diakses oleh JavaScript yang berjalan di halaman yang sama (rentan XSS).

**Rekomendasi mitigasi:**

1. **Access token**: Gunakan umur singkat **15 menit** dan simpan hanya di memori (Riverpod/state).
2. **Refresh token**: Kirim melalui **`httpOnly` cookie** (server set via `Set-Cookie`). Cookie ini tidak dapat diakses JS, sehingga lebih aman dari XSS.
3. **CSRF protection**: Jika menggunakan cookie, tambahkan header `X-Requested-With` atau implementasi CSRF token untuk endpoint mutasi.
4. **Content Security Policy**: Pasang header `Content-Security-Policy` ketat di server untuk membatasi script yang dapat dieksekusi.

```
# Contoh header Set-Cookie dari server:
Set-Cookie: refresh_token=<token>; HttpOnly; Secure; SameSite=Strict; Path=/auth/refresh; Max-Age=604800
```

---

## Aturan Wajib (Business Rules)

> [!IMPORTANT]
> Semua poin berikut **wajib** diimplementasikan di sisi server tanpa pengecualian.

1. **Audit log wajib**: Setiap aksi tulis (POST/PATCH/PUT/DELETE) yang dilakukan admin harus menghasilkan satu baris di tabel `audit_logs` secara atomik (dalam transaksi yang sama).

2. **Admin tidak boleh ubah role / settings / admin lain**: Admin dengan role `admin` (bukan `super_admin`) tidak boleh mengakses endpoint `/admin/admins`, `/admin/settings`, atau `/admin/audit-logs`. Validasi dilakukan **server-side**, bukan hanya di UI.

3. **Hashing password**: Semua password di-hash menggunakan **bcrypt dengan cost factor minimum 10**. Tidak ada plaintext password yang boleh tersimpan di database, log, atau response API.

4. **Role check server-side**: Setiap endpoint admin wajib memverifikasi role user dari JWT claim di server. Jangan hanya mengandalkan middleware/guard di layer routing.

5. **Validasi input**: Semua request body divalidasi ketat sebelum diproses. Return `422` dengan format `fields` jika ada field yang tidak valid.

6. **Soft delete / status flag**: Pengguna tidak dihapus secara permanen (`DELETE`). Gunakan field `status = 'suspended'` atau `'inactive'` sebagai gantinya.

7. **Idempotency aksi verifikasi**: Approve/reject petani yang sudah `verified` atau `rejected` harus mengembalikan `409 Conflict` — jangan proses ulang.

---

## Asumsi dan Hal yang Perlu Dikonfirmasi

1. **Notifikasi pengguna**: Apakah saat petani disetujui/ditolak, sistem otomatis mengirim notifikasi push/email? Jika ya, siapa yang mengelola template notifikasi?

2. **Upload dokumen**: Apakah dokumen petani di-upload langsung ke backend API atau ke cloud storage (S3/GCS) melalui presigned URL dari sisi Flutter? Jika presigned URL, endpoint mana yang generate-nya?

3. **Pagination lelang/transaksi**: Apakah endpoint lelang & transaksi perlu mendukung filter rentang tanggal (`from` / `to`)? Saat ini belum disertakan di spec.

4. **Role pengamat (pengamat)**: User dengan role `pengamat` tampaknya hanya read-only di aplikasi petani/pembeli. Apakah ada endpoint khusus untuk pengamat di panel admin?

5. **Ekspor laporan async**: Untuk ekspor data besar, apakah endpoint `/admin/reports/export` harus mengembalikan file langsung (synchronous) atau via job queue (async, dengan polling status)?

6. **Investasi**: Tabel `investments` sudah ada di schema DDL, namun tidak ada endpoint admin untuk mengelolanya di spec ini. Apakah modul investasi termasuk dalam scope sprint ini?

7. **Multi-tenancy / wilayah**: Apakah data perlu dipartisi per wilayah/provinsi? Ini akan berdampak pada query laporan dan index database.

8. **Rate limiting**: Apakah endpoint login perlu rate limiting per IP? Berapa threshold-nya sebelum akun dikunci sementara?

---

## Format Error Standar

Semua respons error menggunakan envelope berikut:

```json
{
  "error": {
    "code": "STRING_SNAKE_CASE",
    "message": "Pesan human-readable dalam Bahasa Indonesia.",
    "fields": {
      "nama_field": "Pesan error spesifik field ini."
    }
  }
}
```

| HTTP Status | Kode Error Umum | Kapan Digunakan |
|:-----------:|---|---|
| `400` | `BAD_REQUEST` | Request malformed atau tidak dapat diparse |
| `401` | `UNAUTHORIZED` | Token tidak ada, tidak valid, atau kedaluwarsa |
| `403` | `FORBIDDEN` | Token valid tapi role tidak mencukupi |
| `404` | `NOT_FOUND` | Resource dengan ID yang diminta tidak ditemukan |
| `409` | `CONFLICT` | Aksi tidak valid pada state resource saat ini |
| `422` | `VALIDATION_ERROR` | Field input tidak lolos validasi |
| `429` | `RATE_LIMITED` | Terlalu banyak request dalam waktu singkat |
| `500` | `INTERNAL_ERROR` | Error tak terduga di server (jangan bocorkan detail) |

> [!NOTE]
> Field `fields` hanya diisi pada error `422`. Untuk error lain, kembalikan `fields: {}` (objek kosong).  
> Jangan pernah mengembalikan stack trace atau pesan internal database di production.

---

*Dokumen ini dibuat otomatis berdasarkan desain HTML panel admin Panenara.*  
*Versi: 1.0.0 — Mei 2025*
