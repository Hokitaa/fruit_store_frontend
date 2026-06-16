# 🍎 Fruit Store — Backend & Flutter App

Aplikasi manajemen stok buah dengan REST API berbasis PHP/MySQL dan WebSocket real-time menggunakan Ratchet. Frontend dibangun dengan Flutter.

---

## 📋 Daftar Isi

- [Prasyarat](#prasyarat)
- [Struktur Proyek](#struktur-proyek)
- [Instalasi Backend](#instalasi-backend)
- [Menjalankan Backend](#menjalankan-backend)
- [Instalasi & Menjalankan Flutter](#instalasi--menjalankan-flutter)
- [Dokumentasi API (OpenAPI)](#dokumentasi-api-openapi)
- [Endpoint Ringkasan](#endpoint-ringkasan)

---

## ✅ Prasyarat

Pastikan semua tools berikut sudah terinstal di komputer kamu:

| Tools | Versi Minimum | Keterangan |
|---|---|---|
| PHP | 8.0+ | Dengan ekstensi `pdo`, `pdo_mysql` aktif |
| MySQL / MariaDB | 5.7+ / 10.3+ | Database server |
| Composer | 2.x | Dependency manager PHP |
| Apache / Nginx | — | Web server (XAMPP/Laragon/manual) |
| Flutter SDK | 3.x | Framework mobile |
| Android Studio / Xcode | — | Untuk emulator atau device |

---

## 📁 Struktur Proyek

```
fruit_store_backend/
├── db.php                  # Koneksi database (root)
├── fruit_api/
│   └── db.php              # Koneksi database (dengan charset utf8mb4)
├── api_get_fruits.php      # GET  — Ambil semua data buah
├── api_add_fruit.php       # POST — Tambah buah baru
├── api_update.php          # POST — Update data buah
├── api_delete.php          # POST — Hapus buah
├── notification_server.php # WebSocket server (Ratchet, port 8080)
├── composer.json           # Dependency: cboden/ratchet
└── vendor/                 # Library hasil composer install
```

---

## 🛠️ Instalasi Backend

### 1. Clone / Salin Proyek

Letakkan folder `fruit_store_backend` di dalam direktori web server kamu:

```bash
# Contoh untuk XAMPP (Windows/Mac)
C:/xampp/htdocs/fruit_store_backend/

# Contoh untuk Laragon
C:/laragon/www/fruit_store_backend/

# Contoh untuk Linux
/var/www/html/fruit_store_backend/
```

### 2. Buat Database

Buka **phpMyAdmin** atau terminal MySQL, lalu jalankan SQL berikut:

```sql
CREATE DATABASE fruit_store_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE fruit_store_db;

CREATE TABLE stok_buah (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nama_buah VARCHAR(100) NOT NULL,
  harga     DECIMAL(10, 2) NOT NULL DEFAULT 0
);
```

### 3. Konfigurasi Koneksi Database

Edit file `db.php` (dan `fruit_api/db.php`) sesuai kredensial MySQL kamu:

```php
$host = 'localhost';
$db   = 'fruit_store_db';
$user = 'root';       // ← ganti dengan username MySQL kamu
$pass = '';           // ← ganti dengan password MySQL kamu
```

### 4. Install Dependencies PHP (Ratchet)

Buka terminal di dalam folder `fruit_store_backend`, lalu jalankan:

```bash
composer install
```

Perintah ini akan mengunduh library **Ratchet** (WebSocket server) ke folder `vendor/`.

> **Catatan:** Jika `composer` belum terinstal, unduh dari [https://getcomposer.org](https://getcomposer.org).

---

## ▶️ Menjalankan Backend

Backend terdiri dari dua komponen yang harus dijalankan **bersamaan**:

### Komponen 1 — Web Server (REST API)

Pastikan **Apache/Nginx sudah aktif** (misalnya melalui XAMPP Control Panel).

Akses API melalui browser untuk tes:

```
http://localhost/fruit_store_backend/api_get_fruits.php
```

Jika berhasil, kamu akan mendapatkan response JSON berisi daftar buah.

### Komponen 2 — WebSocket Server (Real-time Notification)

Buka terminal baru di folder `fruit_store_backend`, lalu jalankan:

```bash
php notification_server.php
```

Output yang muncul jika berhasil:

```
Server BERHASIL berjalan di 0.0.0.0:8080!
Tekan Ctrl + C untuk mematikan server.
```

> ⚠️ **Penting:** Pastikan port `8080` tidak dipakai aplikasi lain. WebSocket server ini **harus tetap berjalan** selama aplikasi Flutter digunakan.

---

## 📱 Instalasi & Menjalankan Flutter

### 1. Buka Proyek Flutter

```bash
cd flutter_fruit_store   # sesuaikan dengan nama folder Flutter kamu
flutter pub get
```

### 2. Konfigurasi URL API

Di dalam kode Flutter, cari file konfigurasi atau konstanta API (biasanya `lib/constants.dart` atau langsung di service file), lalu sesuaikan URL:

```dart
// Untuk emulator Android (localhost di host machine)
const String baseUrl = 'http://10.0.2.2/fruit_store_backend';
const String wsUrl   = 'ws://10.0.2.2:8080';

// Untuk device fisik (gunakan IP lokal komputer kamu)
const String baseUrl = 'http://192.168.x.x/fruit_store_backend';
const String wsUrl   = 'ws://192.168.x.x:8080';
```

> Cek IP komputer kamu dengan perintah `ipconfig` (Windows) atau `ifconfig` / `ip a` (Linux/Mac).

### 3. Jalankan Aplikasi Flutter

```bash
# Pilih device yang tersedia
flutter devices

# Jalankan di emulator atau device
flutter run

# Atau build APK untuk Android
flutter build apk --release
```

---

## 📖 Dokumentasi API (OpenAPI)

Dokumentasi interaktif dalam format **OpenAPI 3.0** tersedia untuk di-import ke tools seperti **Swagger UI**, **Postman**, atau **Insomnia**.

### 🔗 Cara Membuka Dokumentasi

**Opsi A — Swagger Editor Online (Langsung di browser):**

1. Buka [https://editor.swagger.io](https://editor.swagger.io)
2. Hapus konten default yang ada
3. Paste spesifikasi OpenAPI di bawah ini
4. Dokumentasi interaktif akan langsung tampil

**Opsi B — Import ke Postman:**

1. Buka Postman → klik **Import**
2. Pilih tab **Raw text** → paste spesifikasi OpenAPI di bawah
3. Klik **Continue** → **Import**

**Opsi C — Import ke Insomnia:**

1. Buka Insomnia → **Create** → **Import from Clipboard**
2. Paste spesifikasi OpenAPI di bawah

---

### 📄 Spesifikasi OpenAPI 3.0

```yaml
openapi: 3.0.3
info:
  title: Fruit Store API
  description: REST API untuk manajemen stok buah. WebSocket tersedia di ws://localhost:8080 untuk notifikasi real-time.
  version: 1.0.0

servers:
  - url: http://localhost/fruit_store_backend
    description: Local Development Server

paths:
  /api_get_fruits.php:
    get:
      summary: Ambil semua data buah
      description: Mengembalikan seluruh data stok buah dari database.
      responses:
        '200':
          description: Daftar buah berhasil diambil
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Buah'
              example:
                - id: 1
                  nama_buah: "Apel"
                  harga: "15000.00"
                - id: 2
                  nama_buah: "Mangga"
                  harga: "20000.00"

  /api_add_fruit.php:
    post:
      summary: Tambah buah baru
      description: Menambahkan data buah baru ke dalam stok.
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              required:
                - nama_buah
                - harga
              properties:
                nama_buah:
                  type: string
                  description: Nama buah
                  example: "Apel"
                harga:
                  type: number
                  description: Harga buah
                  example: 15000
      responses:
        '200':
          description: Buah berhasil ditambahkan
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/StatusResponse'
              example:
                status: "success"
        '200x':
          description: Gagal — nama buah kosong
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              example:
                status: "error"
                message: "Nama kosong"

  /api_update.php:
    post:
      summary: Update data buah
      description: Memperbarui nama dan harga buah berdasarkan ID.
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              required:
                - id
                - nama_buah
                - harga
              properties:
                id:
                  type: integer
                  description: ID buah yang akan diupdate
                  example: 1
                nama_buah:
                  type: string
                  description: Nama buah baru
                  example: "Apel Fuji"
                harga:
                  type: number
                  description: Harga baru
                  example: 18000
      responses:
        '200':
          description: Buah berhasil diupdate
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/StatusResponse'
              example:
                status: "success"

  /api_delete.php:
    post:
      summary: Hapus buah
      description: Menghapus data buah dari stok berdasarkan ID.
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              required:
                - id
              properties:
                id:
                  type: integer
                  description: ID buah yang akan dihapus
                  example: 1
      responses:
        '200':
          description: Buah berhasil dihapus (response kosong)

components:
  schemas:
    Buah:
      type: object
      properties:
        id:
          type: integer
          example: 1
        nama_buah:
          type: string
          example: "Apel"
        harga:
          type: string
          example: "15000.00"

    StatusResponse:
      type: object
      properties:
        status:
          type: string
          example: "success"

    ErrorResponse:
      type: object
      properties:
        status:
          type: string
          example: "error"
        message:
          type: string
          example: "Nama kosong"
```

---

## 📡 Endpoint Ringkasan

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api_get_fruits.php` | Ambil semua data buah |
| `POST` | `/api_add_fruit.php` | Tambah buah baru |
| `POST` | `/api_update.php` | Update data buah |
| `POST` | `/api_delete.php` | Hapus buah |
| `WS` | `ws://localhost:8080` | WebSocket real-time notification |

### Parameter POST

**`api_add_fruit.php`**
```
nama_buah  string   (wajib) Nama buah
harga      number   (wajib) Harga buah
```

**`api_update.php`**
```
id         integer  (wajib) ID buah
nama_buah  string   (wajib) Nama buah baru
harga      number   (wajib) Harga baru
```

**`api_delete.php`**
```
id         integer  (wajib) ID buah yang dihapus
```

---

## 🔌 WebSocket — Cara Kerja

Server WebSocket berjalan di port `8080` menggunakan library **Ratchet**. Saat ada perubahan data (tambah/update/hapus), Flutter mengirim pesan ke WebSocket server, dan server akan **meneruskan pesan tersebut ke semua client** yang sedang terhubung — sehingga semua perangkat yang membuka aplikasi mendapatkan notifikasi secara real-time.

```
Flutter App  →  POST ke REST API  →  MySQL
     ↓
Flutter App  →  Kirim pesan ke WS Server (port 8080)
                     ↓
              Broadcast ke semua client
                     ↓
         Semua Flutter App menerima update
```

---

## ❓ Troubleshooting

**Koneksi database gagal**
→ Pastikan MySQL aktif dan kredensial di `db.php` sudah benar.

**`composer install` gagal**
→ Pastikan Composer dan PHP sudah ada di PATH. Jalankan `php -v` dan `composer -V` untuk cek.

**Port 8080 sudah dipakai**
→ Cari proses yang menggunakan port tersebut: `netstat -ano | findstr :8080` (Windows) atau `lsof -i :8080` (Linux/Mac), lalu hentikan prosesnya.

**Emulator Android tidak bisa akses API**
→ Gunakan IP `10.0.2.2` sebagai pengganti `localhost` di dalam kode Flutter.

**Flutter tidak bisa koneksi ke device fisik**
→ Pastikan HP dan komputer berada di jaringan WiFi yang sama, lalu gunakan IP lokal komputer (bukan `localhost`).
