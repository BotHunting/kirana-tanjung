# CV. Kirana Tanjung Pelakar / Natala Studio - Web Application

Aplikasi web berbasis Google Apps Script untuk manajemen layanan bisnis: Desain, Percetakan, Boutique, dan Biro Jasa.

## 📋 Table of Contents

- [Fitur Utama](#fitur-utama)
- [Phase 1 Features](#phase-1-features)
- [Role Management System](#role-management-system)
- [Struktur Sheet](#struktur-sheet)
- [Setup WhatsApp Business API](#setup-whatsapp-business-api)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

---

## 🚀 Getting Started

### Prerequisites

Sebelum memulai, pastikan Anda memiliki:
- Akun Google (Gmail)
- Akses ke Google Sheets
- Meta Business Account (untuk WhatsApp Business API)
- Node.js dan npm terinstall (untuk deployment)

### Langkah 1: Setup Google Sheet

1. **Buat Google Sheet baru**
   - Buka [Google Sheets](https://sheets.google.com)
   - Buat sheet baru dengan nama "Kirana Tanjung Database"

2. **Buat Sheet Tabs**
   Buat sheet tabs berikut dengan struktur yang sesuai:
   - `Users` - Data user dan role
   - `Desain` - Data layanan desain
   - `Percetakan` - Data produk percetakan
   - `Boutique` - Data produk boutique
   - `Biro Jasa` - Data layanan biro jasa (STNK, dll)

3. **Setup Header Sheet Users**
   - Baris 1 (Header): Username, Password, Nama, NIK, Alamat, Role
   - Tambahkan minimal 1 user admin:
     - Username: `admin`
     - Password: `password_anda` (akan dihash di backend)
     - Nama: `Administrator`
     - Role: `admin`

4. **Setup Header Sheet Biro Jasa**
   - Baris 1 (Header): Timestamp, Layanan, Nama, Merek, Type, No. Kendaraan, Deskripsi, Progres, WhatsApp, Masa Aktif, STNK, Username

5. **Setup Header Sheet Desain**
   - Baris 1 (Header): Timestamp, Project, Deskripsi, Link Gambar, Tag, WhatsApp, Status

6. **Setup Header Sheet Percetakan**
   - Baris 1 (Header): Timestamp, Produk, Harga, Ikon, WhatsApp, Status, Keterangan, Min. Order

7. **Setup Header Sheet Boutique**
   - Baris 1 (Header): Judul, Kategori, Deskripsi, Harga, Min. Order, Gambar URL, Status

### Langkah 2: Setup Google Apps Script Project

1. **Install Clasp CLI**
   ```bash
   npm install -g @google/clasp
   ```

2. **Login ke Google**
   ```bash
   clasp login
   ```
   - Browser akan terbuka
   - Login dengan akun Google Anda
   - Berikan izin akses

3. **Clone Project dari GitHub**
   ```bash
   git clone https://github.com/username/kirana-tanjung.git
   cd kirana-tanjung/script
   ```

4. **Setup Clasp Project**
   ```bash
   clasp create --title "Kirana Tanjung Web App" --type webapp
   ```
   - Pilih project type: "Web app"
   - Copy Script ID yang dihasilkan

5. **Update appsscript.json**
   Buka file `appsscript.json` dan update:
   ```json
   {
     "timeZone": "Asia/Jakarta",
     "exceptionLogging": "STACKDRIVER",
     "runtimeVersion": "V8",
     "webapp": {
       "executeAs": "USER_ACCESSING",
       "access": "DOMAIN"
     }
   }
   ```

### Langkah 3: Konfigurasi Google Sheet ID

1. **Dapatkan Sheet ID**
   - Buka Google Sheet yang Anda buat di Langkah 1
   - Sheet ID ada di URL: `https://docs.google.com/spreadsheets/d/SHEET_ID/edit`
   - Copy bagian `SHEET_ID`

2. **Update Code.js**
   Buka file `Code.js` dan update baris 1:
   ```javascript
   const SHEET_ID = 'YOUR_SHEET_ID_HERE'; // Ganti dengan Sheet ID Anda
   ```

### Langkah 4: Setup WhatsApp Business API (Opsional)

Jika ingin menggunakan fitur WhatsApp Broadcast:

1. Ikuti panduan lengkap di [Setup WhatsApp Business API](#setup-whatsapp-business-api)
2. Update credentials di `Code.js` baris 610-612:
   ```javascript
   const ACCESS_TOKEN = 'YOUR_ACCESS_TOKEN_HERE';
   const PHONE_NUMBER_ID = 'YOUR_PHONE_NUMBER_ID_HERE';
   const API_VERSION = 'v18.0';
   ```

### Langkah 5: Deploy Aplikasi

1. **Push Code ke Google Apps Script**
   ```bash
   npx clasp push
   ```

2. **Deploy sebagai Web App**
   ```bash
   npx clasp deploy
   ```

3. **Salin Deployment URL**
   - Copy URL web app yang dihasilkan
   - URL format: `https://script.google.com/macros/s/DEPLOYMENT_ID/exec`

### Langkah 6: Penggunaan Pertama

1. **Buka Aplikasi**
   - Buka deployment URL di browser
   - Klik logo 3x untuk membuka modal login

2. **Login sebagai Admin**
   - Username: `admin`
   - Password: `password_anda` (sesuai yang Anda set di sheet Users)

3. **Setup User Lain**
   - Setelah login, masuk ke tab "Users"
   - Tambahkan user baru dengan role:
     - `admin` - Akses penuh
     - `staff` - Akses terbatas (tidak bisa import/manage users)
     - `user` - Hanya view data sendiri di tab Biro Jasa

4. **Tambahkan Data**
   - Gunakan tab masing-masing layanan untuk menambahkan data
   - Atau gunakan fitur Import CSV untuk bulk import

### Quick Reference

| Task | Command |
|------|---------|
| Login Clasp | `clasp login` |
| Push Code | `npx clasp push` |
| Deploy | `npx clasp deploy` |
| Pull Code | `npx clasp pull` |
| Open Script Editor | `npx clasp open` |
| List Deployments | `npx clasp deployments` |

### Tips

- **Backup Data**: Selalu backup Google Sheet sebelum melakukan import data
- **Role Management**: Pastikan role di sheet Users diisi dengan benar (lowercase)
- **Username Consistency**: Kolom Username di sheet Biro Jasa harus sama dengan kolom Username di sheet Users
- **WhatsApp Test**: Tambahkan nomor Anda sebagai test number sebelum broadcast massal
- **Version Control**: Gunakan git untuk tracking perubahan code

---

## 🎯 Fitur Utama

### Fitur yang Sudah Ada
- ✅ Dark/Light mode toggle
- ✅ Responsive design dengan mobile menu
- ✅ Portfolio showcase 4 layanan (Web, Percetakan, Boutique, Biro Jasa)
- ✅ Tabel status project dan katalog produk
- ✅ Login sistem dengan authentication
- ✅ Dashboard admin untuk CRUD data
- ✅ Search/filter real-time
- ✅ Modal edit, preview produk, STNK, Surat Kuasa
- ✅ WhatsApp integration per layanan
- ✅ Auto-scroll katalog produk
- ✅ Data obfuscation untuk privacy
- ✅ Auto-refresh dashboard (5 menit)
- ✅ Secret login trigger (3x klik logo)

---

## 🚀 Phase 1 Features

### 1. Analytics Dashboard
- **Summary Cards**: Menampilkan total data per kategori (Desain, Percetakan, Boutique, Biro Jasa)
- **Status Distribution Chart**: Doughnut chart untuk distribusi status (Selesai, On Process, Aktif, Ditolak)
- **Revenue Estimation Chart**: Bar chart untuk estimasi revenue dari Percetakan dan Boutique
- **STNK Expiry Timeline Chart**: Bar chart untuk timeline masa aktif STNK (Expired, H-7, H-30, 30+ Hari, No Date)
- **Monthly Activity Chart**: Line chart untuk aktivitas bulanan
- **Refresh Button**: Untuk reload data analytics secara manual

### 2. Export Data
- Tombol **Export CSV** di setiap tab kategori
- Export otomatis dengan timestamp di nama file
- Format CSV yang sesuai dengan struktur data
- Validasi data sebelum export
- Password disembunyikan dengan `***` di export

### 3. Import Data
- Tombol **Import CSV** dengan modal upload
- Validasi file CSV (maksimal 5MB)
- Validasi header untuk memastikan format benar
- Parsing CSV yang robust (handle quotes, commas, newlines)
- Preview dan konfirmasi sebelum import
- Append data ke sheet yang sesuai
- **Only Admin**: Hanya role admin yang bisa import data

### 4. WA Broadcast Notification
- Tombol **Broadcast WA** untuk kirim pengingat massal
- Filter berdasarkan masa aktif STNK:
  - Expired (H-0)
  - H-7 (Kritis)
  - H-30 (Warning)
  - Tanpa Tanggal
- Preview penerima dengan kategori warna
- Template pesan dengan variabel dinamis:
  - `{nama}`, `{no_kendaraan}`, `{merek}`, `{type}`, `{layanan}`, `{masa_aktif}`
- Rate limit: maksimal 50 pesan per batch
- Konfirmasi sebelum kirim
- **Admin & Staff**: Role admin dan staff yang bisa broadcast

---

## 👥 Role Management System

### Role yang Tersedia

| Role | Analytics | Export | Import | Broadcast | Edit Data | Delete Data | Manage Users | View All Data |
|------|-----------|--------|--------|-----------|-----------|-------------|--------------|---------------|
| **Admin** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Staff** | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| **User** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ (hanya data sendiri) |

### Permissions Detail

#### Admin
- View Analytics Dashboard
- Export Data (semua kategori)
- Import Data (CSV)
- Broadcast WA
- Edit semua kategori (Desain, Percetakan, Boutique, Biro Jasa)
- Delete data
- Manage Users (ubah role user lain)
- View semua data (tidak difilter)

#### Staff
- View Analytics Dashboard
- Export Data (semua kategori)
- Import Data (tidak diizinkan)
- Broadcast WA
- Edit semua kategori
- Delete data (tidak diizinkan)
- Manage Users (tidak diizinkan)
- View semua data (tidak difilter)

#### User
- View Analytics Dashboard (tidak diizinkan)
- Export Data (tidak diizinkan)
- Import Data (tidak diizinkan)
- Broadcast WA (tidak diizinkan)
- Edit data (tidak diizinkan - read-only)
- Delete data (tidak diizinkan)
- Manage Users (tidak diizinkan)
- **Hanya view Biro Jasa tab**
- **Hanya view data sendiri** (difilter berdasarkan kolom Username di sheet Biro Jasa)

### UI Features

#### Role Badge
- Badge role muncul di samping nama user setelah login
- Warna badge:
  - **Admin**: Merah (`bg-red-100 text-red-700`)
  - **Staff**: Biru (`bg-blue-100 text-blue-700`)
  - **User**: Abu-abu (`bg-slate-100 text-slate-700`)

#### Tab Visibility
- **User**: Hanya tab **Biro Jasa** yang terlihat, tab lain disembunyikan
- **Admin & Staff**: Semua tab terlihat (Desain, Percetakan, Boutique, Biro Jasa, Users)
- **Auto-switch**: User otomatis diarahkan ke tab Biro Jasa setelah login

#### Users Tab (Admin Only)
- Tab "Users" hanya muncul untuk admin
- Tampilkan semua user dengan info lengkap
- Dropdown untuk mengubah role secara langsung
- Konfirmasi sebelum mengubah role
- Admin tidak bisa mengubah role sendiri

---

## 📊 Struktur Sheet

### Sheet Users

**Kolom:**
| A | B | C | D | E | F |
|---|---|---|---|---|---|
| **Username** | Password | Nama | NIK | Alamat | **Role** |

**Contoh Data:**
```
Username | Password | Nama           | NIK | Alamat           | Role
admin    | ***      | Administrator  | ... | ...              | admin
staff1   | ***      | Staff One      | ... | ...              | staff
staff2   | ***      | Staff Staff    | ... | ...              | staff
budi     | ***      | Budi Santoso   | ... | ...              | user
andi     | ***      | Andi Wijaya    | ... | ...              | user
```

**PENTING:**
- Kolom F (Role) harus diisi dengan `admin`, `staff`, atau `user` (lowercase)
- Jika kosong, default adalah `user`
- Username (Kolom A) digunakan untuk login dan filtering data

### Sheet Biro Jasa

**Kolom:**
| A | B | C | D | E | F | G | H | I | J | K | **L** |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Timestamp | Layanan | Nama | Merek | Type | No. Kendaraan | Deskripsi | Progres | WhatsApp | Masa Aktif | STNK | **Username** |

**Contoh Data:**
```
Timestamp | Layanan | Nama    | Merek | Type | No. Kendaraan | Deskripsi | Progres | WhatsApp | Masa Aktif | STNK | Username
...       | STNK    | Budi    | ...   | ...  | B 1234 ABC    | ...       | Proses  | 8123456789| 2024-12-31 | ...  | budi
...       | STNK    | Andi    | ...   | ...  | B 5678 XYZ    | ...       | Selesai | 8123456789| 2024-11-30 | ...  | andi
...       | STNK    | Citra   | ...   | ...  | B 9012 DEF    | ...       | Proses  | 8123456789| 2025-01-15 | ...  | citra
```

**PENTING:**
- Kolom L (Username) digunakan untuk filtering data per user
- User hanya melihat data di mana kolom Username = username login mereka
- Admin dan Staff melihat semua data (tidak difilter)
- Saat import CSV, kolom Username otomatis diisi dengan username yang sedang login

### Sheet Desain

**Kolom:**
| A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|
| Timestamp | Project | Deskripsi | Link Gambar | Tag | WhatsApp | Status |

### Sheet Percetakan

**Kolom:**
| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| Timestamp | Produk | Harga | Ikon | WhatsApp | Status | Keterangan | Min. Order |

### Sheet Boutique

**Kolom:**
| A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|
| Judul | Kategori | Deskripsi | Harga | Min. Order | Gambar URL | Status |

---

## 📱 Setup WhatsApp Business API

### Langkah 1: Setup Meta Business Suite
1. Buka [Meta Business Suite](https://business.facebook.com/)
2. Login dengan akun Facebook bisnis Anda
3. Buat atau pilih Business Account yang sudah ada

### Langkah 2: Setup WhatsApp Business App
1. Di Meta Business Suite, buka **Settings** → **Business Assets**
2. Klik **Apps** → **Add** → **Create a new app**
3. Pilih **Business** category
4. Beri nama app (misal: "Natala Studio WA")
5. Setelah app dibuat, buka app tersebut

### Langkah 3: Setup WhatsApp Product
1. Di app dashboard, cari **WhatsApp** di product list
2. Klik **Set up** pada WhatsApp
3. Pilih **Business account** (sudah ada atau buat baru)
4. Pilih **Phone number** yang akan digunakan untuk mengirim pesan
5. Masukkan dan verifikasi nomor WhatsApp bisnis Anda
6. Catat **Phone Number ID** (dari WhatsApp settings)

### Langkah 4: Generate Access Token
1. Di WhatsApp app settings, buka **API Setup**
2. Scroll ke bawah ke **Access Token** section
3. Klik **Generate new token**
4. Pilih permission minimal: `whatsapp_business_messaging`
5. Copy **Access Token** yang dihasilkan
6. ⚠️ **PENTING**: Simpan token ini dengan aman! Jangan bagikan ke publik.

### Langkah 5: Update Code.js
Buka file `Code.js` di baris 610-612, dan ganti dengan credentials Anda:

```javascript
const ACCESS_TOKEN = 'YOUR_ACCESS_TOKEN_HERE'; // Tempel access token Anda
const PHONE_NUMBER_ID = 'YOUR_PHONE_NUMBER_ID_HERE'; // Tempel Phone Number ID Anda
const API_VERSION = 'v18.0'; // Gunakan versi terbaru
```

### Langkah 6: Test Number
1. Di WhatsApp settings, tambahkan nomor Anda sebagai **Test Number**
2. Kirim pesan test melalui API endpoint untuk verifikasi
3. Pastikan nomor test bisa menerima pesan dari API

### Format Nomor WhatsApp
- Sheet: Format `8xxx` atau `08xxx`
- Backend: Otomatis dikonversi ke `628xxx`
- Contoh:
  - `81234567890` → `6281234567890`
  - `081234567890` → `6281234567890`
  - `6281234567890` → `6281234567890` (tidak berubah)

---

## 🚀 Deployment

### Persiapan
1. Pastikan Google Sheet sudah di-setup dengan struktur yang benar
2. Pastikan kolom Role di sheet Users sudah diisi
3. Pastikan kolom Username di sheet Biro Jasa sudah ada

### Deploy dengan Clasp

```bash
# Masuk ke direktori script
cd D:\Proyek\Github\kirana-tanjung\script

# Push changes ke Google Apps Script
npx clasp push

# Deploy
npx clasp deploy
```

### Output yang Diharapkan
```
Pushed 6 files at [timestamp].
└─ appsscript.json
└─ Code.js
└─ dashboard.html
└─ google534188cf26a92a25.html
└─ index.html
└─ kuasa.html

Deployed [DEPLOYMENT_ID] @[VERSION]
```

---

## 🔧 Troubleshooting

### 1. Admin/Staff Tidak Melihat Semua Data

**Masalah:** Admin atau staff hanya melihat data difilter seolah-olah role user.

**Solusi:**
- Pastikan kolom **Role (Kolom F)** di sheet Users diisi dengan benar:
  - `admin` (lowercase) untuk admin
  - `staff` (lowercase) untuk staff
  - `user` (lowercase) untuk user
- Pastikan tidak ada spasi sebelum atau sesudah role
- Logout dan login kembali

### 2. User Tidak Melihat Data Apapun

**Masalah:** User login tapi tidak melihat data di tab Biro Jasa.

**Solusi:**
- Pastikan kolom **Username (Kolom L)** di sheet Biro Jasa diisi dengan username user
- Pastikan username di sheet Biro Jasa sama persis dengan username di sheet Users (case-insensitive)
- Cek kolom Username di sheet Biro Jasa: harus berisi username, bukan nama lengkap

### 3. Role Badge Tidak Muncul

**Masalah:** Tidak ada badge role setelah login.

**Solusi:**
- Refresh halaman browser
- Logout dan login kembali
- Cek console browser (F12) untuk error JavaScript

### 4. Tab Tidak Muncul untuk User

**Masalah:** User masih melihat semua tab (Desain, Percetakan, Boutique).

**Solusi:**
- Pastikan role di sheet Users adalah `user` (lowercase)
- Refresh halaman
- Pastikan frontend sudah di-deploy dengan versi terbaru

### 5. WhatsApp Broadcast Tidak Mengirim

**Masalah:** Broadcast selesai tapi pesan tidak terkirim.

**Solusi:**
- Pastikan WhatsApp Business API sudah di-setup dengan benar
- Cek Access Token dan Phone Number ID di Code.js
- Pastikan nomor test sudah ditambahkan di WhatsApp settings
- Cek logs di Apps Script console (View → Logs)
- Rate limit: Tunggu 1 detik antar pesan

### 6. Import CSV Gagal

**Masalah:** Import CSV mengembalikan error.

**Solusi:**
- Pastikan file CSV dalam format yang benar
- Pastikan header CSV sesuai dengan template
- Pastikan role user adalah `admin` (hanya admin yang bisa import)
- Cek ukuran file (maksimal 5MB)
- Cek logs di Apps Script console untuk error detail

### 7. Export CSV Password Muncul Plain Text

**Masalah:** Password di export CSV tidak disembunyikan.

**Solusi:**
- Ini sudah di-fix. Password akan muncul sebagai `***` di export
- Pastikan frontend di-deploy dengan versi terbaru

---

## 🔒 Security Notes

### Backend Validation
- Semua operasi CRUD divalidasi di backend berdasarkan role
- Tidak bisa bypass dengan mengirim request langsung (misal: via Postman)
- Username dikirim bersama setiap request untuk validasi

### Frontend Security
- Tombol dan fitur dihide berdasarkan role (UX)
- Role badge menunjukkan role saat ini
- Tab dihide/show berdasarkan role

### Defense in Depth
1. **Layer 1**: Frontend permission (hide UI elements)
2. **Layer 2**: Backend permission validation (enforce security)
3. **Layer 3**: Error handling yang jelas dan ter-log

### Self-Role Protection
- Admin tidak bisa mengubah role sendiri
- Mencegah admin menghapus akses sendiri

### Audit Trail
- Kolom username di sheet Biro Jasa berfungsi sebagai audit trail
- Bisa diketahui siapa yang menambahkan data tersebut
- Memudahkan tracking data per user

---

## 📝 CSV Export/Import Templates

### Desain
```csv
Project,Tag,Deskripsi,Status,WhatsApp
```

### Percetakan
```csv
Produk,Harga,Min. Order,Ikon,Status,Keterangan,WhatsApp
```

### Boutique
```csv
Judul,Kategori,Deskripsi,Harga,Min. Order,Status,Gambar URL
```

### Biro Jasa
```csv
Layanan,Nama,Merek,Type,No. Kendaraan,Deskripsi,Progres,Masa Aktif,Status,STNK,WhatsApp,Username
```

### Users
```csv
Username,Password,Nama,NIK,Alamat,Role
```

---

## 🔄 Version History

### v1.0 - Initial Audit
- Audit fitur yang sudah ada
- Rekomendasi fitur tambahan

### v1.1 - Phase 1 Implementation
- Analytics Dashboard
- Export Data (CSV)
- Import Data (CSV)
- WA Broadcast Notification

### v1.2 - Role Management
- Role system (Admin, Staff, User)
- Backend validation
- Frontend permission enforcement
- Users tab untuk admin

### v1.3 - User-Specific Data Filtering
- Kolom Username di sheet Biro Jasa (Kolom L)
- Filtering data per user untuk role user
- Admin & Staff tetap view semua data
- Update backend untuk username-based filtering

### v1.4 - Bug Fixes
- Fix username vs nama confusion in backend calls
- Update all backend functions to use username parameter
- Fix session storage to include username
- Update getAllDataForDashboard to properly filter by role

### v1.5 - Critical Bug Fix (Username Parameter)
- **Bug**: Frontend mengirim `nama` (nama lengkap) ke backend, tapi backend mencari role berdasarkan `username` (kolom A di sheet Users)
- **Impact**: Semua user dianggap sebagai role default (`user`), menyebabkan admin/staff juga difilter data
- **Fix**:
  - Update `checkLogin()` backend untuk mengembalikan `username` di response
  - Update frontend session storage untuk menyimpan `username` dan `nama` secara terpisah
  - Update semua backend function calls untuk menggunakan `window.currentUserSession?.username`:
    - `getAllDataForDashboard(username)`
    - `updateDataInSheet(..., username)`
    - `addDataToSheet(..., username)`
    - `deleteDataFromSheet(..., username)`
    - `importDataFromCSV(..., username)`
    - `sendWABroadcast(..., username)`
    - `updateUserRole(..., requestUsername)`
- **Result**: Admin dan Staff sekarang benar-benar melihat semua data, User hanya melihat data sendiri (berdasarkan kolom Username di sheet Biro Jasa)

---

## 📞 Support

Untuk bantuan atau pertanyaan:
- Cek logs di Apps Script console (View → Logs)
- Cek console browser (F12) untuk error JavaScript
- Pastikan struktur sheet sesuai dokumentasi
- Pastikan role di sheet Users diisi dengan benar

---

**Generated with [Devin](https://devin.ai)**
