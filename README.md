# Sistem Informasi CV. KIRANA TANJUNG PELAKAR

<p align="center">
  <strong>Sistem Informasi Manajemen Terpadu & Portal Publik untuk CV. Kirana Tanjung Pelakar.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Frontend-Vercel-black?style=for-the-badge&logo=vercel" alt="Vercel">
  <img src="https://img.shields.io/badge/Backend-Google%20Apps%20Script-blue?style=for-the-badge&logo=google-apps-script" alt="Google Apps Script">
  <img src="https://img.shields.io/badge/Database-Google%20Sheets-green?style=for-the-badge&logo=google-sheets" alt="Google Sheets">
  <img src="https://img.shields.io/badge/UI-HTML5-orange?style=for-the-badge&logo=html5" alt="HTML5">
  <img src="https://img.shields.io/badge/UI-Tailwind%20CSS-blueviolet?style=for-the-badge&logo=tailwindcss" alt="Tailwind CSS">
  <img src="https://img.shields.io/badge/UI-Font%20Awesome-blue?style=for-the-badge&logo=fontawesome" alt="Font Awesome">
</p>

---

## 📜 Daftar Isi

- [1. Latar Belakang](#-1-latar-belakang)
- [2. Arsitektur Sistem](#-2-arsitektur-sistem)
- [3. Fitur Utama](#-3-fitur-utama)
- [4. Struktur Proyek & Keterangan File](#-4-struktur-proyek--keterangan-file)
- [5. Skema Database (Google Sheets)](#-5-skema-database-google-sheets)
- [6. Panduan Setup & Deployment](#-6-panduan-setup--deployment)
- [7. Aspek Keamanan & Performa](#-7-aspek-keamanan--performa)

---

## 🎯 1. Latar Belakang

CV. KIRANA TANJUNG PELAKAR adalah perusahaan multi-layanan yang bergerak di bidang Desain, Percetakan, dan Biro Jasa Administrasi Kendaraan. Sistem ini dibangun untuk mengatasi beberapa tantangan:

- **Sentralisasi Data:** Menggantikan pencatatan manual dengan database terpusat (Google Sheets) yang mudah dikelola.
- **Profesionalisme & Keamanan:** Menyembunyikan URL teknis Google Apps Script di balik domain kustom yang di-hosting di Vercel, memberikan tampilan yang lebih profesional dan aman bagi pelanggan.
- **Efisiensi Layanan:** Mengurangi interaksi manual dengan menyediakan portal publik di mana pelanggan dapat melacak status layanan (khususnya untuk biro jasa) secara mandiri.
- **Biaya Rendah:** Memanfaatkan platform *serverless* gratis seperti Vercel, Google Apps Script, dan Google Sheets untuk menekan biaya operasional.

## 🏗️ 2. Arsitektur Sistem

Proyek ini menggunakan arsitektur **Decoupled (Jamstack)** untuk memisahkan antara tampilan (frontend) dan logika (backend).

1.  **Database Layer (Google Sheets):** Berfungsi sebagai database utama. Setiap layanan (Desain, Percetakan, Biro Jasa) memiliki *sheet*-nya sendiri untuk menyimpan data.
2.  **Backend/API Layer (Google Apps Script):** Bertindak sebagai *serverless backend*. `Code.js` berisi semua logika untuk:
    -   Menyajikan halaman HTML dinamis ke pengguna.
    -   Menyediakan endpoint API untuk operasi `Create`, `Read`, `Update` (CRUD) data dari dan ke Google Sheets.
    -   Menangani otentikasi admin.
3.  **Frontend Layer (Vercel):** Sebuah file `index.html` statis yang di-hosting di Vercel. Tugas utamanya adalah menampilkan Google Apps Script Web App di dalam sebuah `<iframe>`. Teknik ini disebut *masking*, yang membuat aplikasi tampak berjalan di domain Vercel, bukan di domain `script.google.com`.

## ✨ 3. Fitur Utama

### Portal Publik
- **Navigasi Mudah:** Menu navigasi *sticky* yang memudahkan pengunjung untuk beralih antar-layanan.
- **Portofolio Dinamis:** Menampilkan portofolio proyek desain yang datanya diambil langsung dari Google Sheets.
- **Katalog Percetakan:** Grid responsif yang menampilkan daftar layanan percetakan beserta harganya.
- **Pelacakan Status Biro Jasa:** Tabel yang menampilkan status pengerjaan berkas administrasi kendaraan secara *real-time*.
- **Integrasi WhatsApp:** Tombol "Tanya Admin" yang secara otomatis membuat draf pesan WhatsApp berisi detail layanan yang ingin ditanyakan pelanggan.

### Dasbor Admin (Internal)
- **Otentikasi Aman:** Halaman login untuk memastikan hanya admin yang dapat mengakses dasbor pengelolaan data.
- **Manajemen Data (CRUD):** Admin dapat menambah, melihat, dan mengubah data untuk semua layanan langsung dari antarmuka web.
- **Sinkronisasi Real-time:** Setiap perubahan yang dibuat di dasbor akan langsung tersimpan di Google Sheets.

## 📂 4. Struktur Proyek & Keterangan File

```
.
├── script/
│   └── Code.js         # Logika utama backend (Google Apps Script)
├── .gitignore          # Mengabaikan file sensitif seperti .clasp.json
├── appsscript.json     # Manifest untuk proyek Google Apps Script (jika menggunakan Clasp)
├── index.html          # Halaman frontend utama yang di-hosting di Vercel
└── README.md           # File ini
```

- **`index.html`**: Ini adalah "kulit" atau *wrapper* dari aplikasi. File ini di-deploy ke Vercel dan tugasnya hanya satu: memuat aplikasi Google Apps Script dalam sebuah `<iframe>` agar menutupi seluruh layar. Ini memberikan URL yang bersih dan profesional.

- **`script/Code.js`**: "Otak" dari keseluruhan sistem. File ini berjalan di server Google.
  - `doGet()`: Fungsi yang dipanggil saat Web App diakses. Fungsi ini mengambil data dari Google Sheets, memasukkannya ke dalam template HTML, dan menyajikannya sebagai halaman web.
  - `checkLogin()`, `addDataToSheet()`, `updateDataInSheet()`, `getAllDataForDashboard()`: Fungsi-fungsi ini bertindak sebagai endpoint API. Mereka dipanggil dari sisi klien (JavaScript di dalam HTML) untuk melakukan otentikasi, menambah, dan memperbarui data.

- **File HTML di dalam Proyek Apps Script (Tidak terlihat di repo ini)**: Di dalam editor Google Apps Script, terdapat file-file HTML (misalnya `index.html`, `dashboard.html`, `styles.html`) yang digunakan oleh `Code.js` untuk membangun antarmuka pengguna.
  - `include(filename)`: Fungsi di `Code.js` yang memungkinkan penyusunan file-file HTML ini menjadi satu halaman utuh, mirip seperti komponen.

- **`appsscript.json`**: File manifest yang berisi konfigurasi proyek Apps Script, seperti izin (scopes) yang diperlukan untuk mengakses Google Sheets. Biasanya dikelola oleh `clasp`.

## ️ 5. Skema Database (Google Sheets)

Database sistem ini menggunakan Google Sheets. Berikut adalah struktur tabel (sheet) yang digunakan.

### 5.1. Sheet: `Desain`
| Nama Kolom | Keterangan |
| :--- | :--- |
| timestamp | Waktu input otomatis oleh sistem. |
| nama | Nama proyek aplikasi/situs web. |
| deskripsi | Uraian cakupan teknologi proyek. |
| linkgambar | URL gambar portofolio. |
| tag | Kategori teknologi (e.g., WEB, UI/UX). |
| whatsapp | Nomor kontak admin. |
| status | Visibilitas data (Aktif/Arsip). |

### 5.2. Sheet: `Percetakan`
| Nama Kolom | Keterangan |
| :--- | :--- |
| timestamp | Waktu penambahan data. |
| deskripsi | Nama produk cetak (e.g., Banner MMT). |
| harga | Tarif minimal layanan. |
| ikon | Kelas ikon FontAwesome (e.g., `fa-print`). |
| whatsapp | Nomor WhatsApp pemesanan. |
| status | Ketersediaan layanan. |

### 5.3. Sheet: `Biro Jasa`
| Nama Kolom | Keterangan |
| :--- | :--- |
| timestamp | Waktu pendaftaran berkas. |
| layanan | Jenis pengurusan (e.g., Perpanjangan STNK). |
| nama | Nama lengkap konsumen. |
| merek | Merek kendaraan. |
| type | Tipe/varian kendaraan. |
| nomor_kendaraan | Nomor polisi (Nopol) kendaraan. |
| deskripsi | Catatan progres tambahan. |
| durasi | Status pelacakan berkas saat ini. |
| whatsapp | Nomor kontak pengurus/konsumen. |
| aktif | Status keaktifan proses (Aktif/Selesai). |
| foto_stnk | URL scan STNK (disimpan di Google Drive terproteksi). |

### 5.4. Sheet: `Users`
| Nama Kolom | Keterangan |
| :--- | :--- |
| username | ID untuk login ke dasbor admin. |
| password | Kata sandi untuk login. |
| nama | Nama lengkap personel admin. |

## 🚀 6. Panduan Setup & Deployment

1.  **Google Sheets:**
    - Buat Google Sheet baru.
    - Buat 4 sheet dengan nama: `Desain`, `Percetakan`, `Biro Jasa`, dan `Users`.
    - Isi baris pertama (header) di setiap sheet sesuai dengan skema database di atas.

2.  **Google Apps Script (GAS):**
    - Buka Google Sheet Anda, lalu klik `Extensions > Apps Script`.
    - Salin semua isi dari `script/Code.js` ke dalam file `Code.gs` di editor GAS.
    - Buat file-file HTML yang diperlukan (misal: `index.html`, `dashboard.html`, dll.) di dalam editor GAS dan isi dengan kode frontend Anda.
    - Klik `Deploy > New deployment`.
    - Pilih tipe `Web app`.
    - Pada bagian `Who has access`, pilih `Anyone`.
    - Klik `Deploy`. Salin URL Web App yang diberikan.

3.  **Vercel (Frontend):**
    - Buka file `index.html` di repositori ini.
    - Ganti URL `src` pada tag `<iframe>` dengan URL Web App yang Anda dapatkan dari langkah GAS.
    - Deploy proyek ini ke Vercel. Anda bisa menghubungkan repositori GitHub Anda langsung ke Vercel untuk deployment otomatis.

## 🛡️ 7. Aspek Keamanan & Performa

- **Keamanan:**
  - Akses ke dasbor admin dilindungi oleh sistem login yang memvalidasi ke sheet `Users`.
  - Data sensitif seperti `foto_stnk` tidak diekspos secara publik. URL-nya harus mengarah ke file di Google Drive dengan akses terbatas.
  - File konfigurasi `clasp` (`.clasp.json`) yang berisi token otorisasi harus selalu ada di `.gitignore` dan tidak boleh di-commit ke repositori.

- **Performa:**
  - Pemanggilan data dari frontend ke backend GAS dilakukan secara asinkron untuk tidak memblokir render halaman.
  - Untuk menjaga performa Google Sheets, disarankan untuk mengarsipkan data lama (misalnya, transaksi biro jasa yang sudah selesai lebih dari 3 bulan) ke sheet atau file spreadsheet lain secara berkala.

---
*Dokumen Spesifikasi Kebutuhan Produk Resmi © 2026 CV. KIRANA TANJUNG PELAKAR. Seluruh hak cipta dilindungi undang-undang.*
