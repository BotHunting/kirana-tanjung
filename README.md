# CV. KIRANA TANJUNG PELAKAR - Product Requirement Document (PRD)

**Versi Final v14.0**

---

## Metadata Dokumen

| Atribut               | Keterangan                                                              |
| --------------------- | ----------------------------------------------------------------------- |
| **Nama Produk:**      | Sistem Informasi Manajemen Terpadu & Portal Publik                      |
| **Pemilik Dokumen:**  | Achmad Faris Zubaidi (Lead Developer & Systems Analyst)                   |
| **Status Dokumen:**   | Production Ready / Approved                                             |
| **Lingkungan Hosting:**| Vercel (Frontend Global) & Google Apps Script (Backend)                 |
| **Versi Basis Data:** | v14.0 (Rinci: Sinkronisasi Endpoint Write-Operation & Keamanan)           |

---

## 1. Pendahuluan & Latar Belakang Operasional

### 1.1. Masalah dan Kebutuhan Bisnis
Sebagai perusahaan yang bergerak di bidang multi-layanan (Desain Web, Percetakan, dan Biro Jasa Administrasi Kendaraan), CV. KIRANA TANJUNG PELAKAR membutuhkan efisiensi pencatatan data yang terpusat. Sistem terdahulu yang mengandalkan tautan *Web App* bawaan Google Apps Script yang panjang memicu kendala transparansi di mata konsumen dan kerentanan keamanan akses multi-login pada peramban klien.

### 1.2. Tujuan Sistem
- **Abstraksi & Masking URL:** Menyembunyikan tautan backend Google yang rumit di balik domain profesional Vercel secara permanen.
- **Otomatisasi Customer Service:** Memotong rantai birokrasi tanya-jawab status berkas dengan mengintegrasikan sistem pelacakan langsung ke API WhatsApp.
- **Infrastruktur Bebas Biaya Berkelanjutan:** Memanfaatkan ekosistem *serverless API* gratis namun berkinerja tinggi untuk operasional skala UMKM.

## 2. Arsitektur Sistem & Skenario Decoupling
Sistem ini dibangun dengan arsitektur *Decoupled Jamstack* untuk menghindari batasan *Same-Origin Policy* (SOP) dan kegagalan kompilasi Just-In-Time (JIT) pada V8 Engine Google Chrome modern.
1.  **Database Layer:** Google Sheets (Sebagai DBMS berbasis kolom terpusat).
2.  **Backend / API Layer:** Google Apps Script (GAS) dengan fungsi penanganan data melalui mekanisme `doGet(e)` untuk operasi *Read* dan `doPost(e)` untuk operasi *Write* berbasis REST API murni untuk menyuplai berkas teks berformat JSON.
3.  **Frontend Layer:** Aplikasi web responsif berbasis HTML5, utilitas CSS Tailwind CSS, dan pustaka ikon terintegrasi FontAwesome.
4.  **Deployment & Hosting:** Diterbitkan secara optimal melalui platform cloud **Vercel** guna menjamin reliabilitas pemuatan halaman.

## 3. Spesifikasi Kebutuhan Fungsional

### 3.1. Portal Publik (Client-Side Rendering)
- **FR-PUB-001 (Sticky Global Navigation):** Komponen menu atas wajib mengunci posisi koordinat Y=0 (*fixed top*) menggunakan efek *backdrop blur* transparansi tinggi (`backdrop-filter: blur(12px)`). Menu wajib memetakan jangkar *scroll* halus ke tiga jangkar identitas: `#web`, `#print`, dan `#jasa`.
- **FR-PUB-002 (Portofolio Desain Web Dinamis):** Merender data objek dari array `publicDesain`. Jika properti berkas gambar kosong, sistem wajib menyediakan tautan gambar *fallback* otomatis dari repositori Unsplash gratis beresolusi minimal 800x480 piksel.
- **FR-PUB-003 (Katalog Digital Percetakan):** Menyusun grid layout responsif (1 kolom pada perangkat seluler, 3 kolom pada layar desktop) untuk menampilkan informasi dari array `publicPercetakan`. Nilai harga wajib diformat secara elegan dengan imbuhan kata "Mulai".
- **FR-PUB-004 (Tabel Manifest Status Pelacakan Biro Jasa):** Menampilkan matriks data berkas aktif. Kolom unit wajib menggabungkan string `merek` dan `type` secara presisi.
- **FR-PUB-005 (Integrasi API WhatsApp Dinamis):** Tombol aksi WhatsApp pada modul Biro Jasa wajib menyusun draf pesan terenkripsi penuh menggunakan `encodeURIComponent()` dengan format berikut:
  > *Halo admin CV. KIRANA TANJUNG, saya ingin menanyakan **Status Layanan Biro Jasa** berikut:*
  >
  > *Layanan: **[Nama Layanan]***
  > *Atas Nama: **[Nama Konsumen]***
  > *Kendaraan: **[Merek] [Type]***
  > *Nomor Polisi: **[Nomor Kendaraan]***
  > *Status Saat Ini: **[Durasi/Status]***
  >
  > *Mohon informasinya. Terima kasih!*
- **FR-PUB-006 (Error Handling & Fallback UI):** Apabila pemanggilan data API Google Apps Script mengalami *timeout* atau gagal memuat data ke Vercel, halaman publik wajib menampilkan pesan eror *fallback* yang ramah berupa: `"Gagal memuat data dari database. Silakan coba lagi."` dan menyembunyikan elemen tabel yang kosong.

### 3.2. Modul Pengelola Internal (Backend Engine & Operations)
- **FR-ADM-001 (Otentikasi API `checkLogin`):** Fungsi wajib memproses pencocokan linier string dari form Login Vercel menuju baris data pada sheet `Users` via instruksi `doPost`. Respon sukses wajib menyertakan enkripsi status sesi sementara pada *frontend client*.
- **FR-ADM-002 (Sinkronisasi Endpoint Operasi Penulisan `doPost`):** Ekosistem API pada Apps Script wajib mengekspos rute parameter aksi (`action=insert` dan `action=update`) guna menerima payload JSON terstruktur dari Vercel, lalu meneruskannya secara aman ke fungsi internal `addDataToSheet` atau `updateDataInSheet`.
- **FR-ADM-003 (Pencatatan Entri Baru `addDataToSheet`):** Logika penulisan data wajib menangkap objek waktu lokal server secara presisi untuk kolom *Timestamp*. Ditambahkan validasi pencegahan duplikasi data: sistem wajib mengecek apakah `nomor_kendaraan` yang diinput sudah ada pada antrean berkas aktif di sheet Biro Jasa untuk menghindari redundansi.
- **FR-ADM-004 (Modifikasi Data Eksisting `updateDataInSheet`):** Logika wajib menerima parameter numerik indeks baris (`rowIndex`) dan menembak jangkauan koordinat cell menggunakan `.getRange()` untuk memperbarui nilai kolom tanpa menimpa data *Timestamp* awal.

## 4. Kamus Data Sistem (Database Schema v14.0)

### 4.1. Tabel: Desain
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| timestamp | Date / Time | Waktu input otomatis oleh sistem. |
| nama | String | Nama identitas proyek pembuatan aplikasi/situs web. |
| deskripsi | Text | Uraian lengkap mengenai cakupan teknologi proyek. |
| linkgambar | String (URL) | Alamat berkas visualisasi proyek portofolio. |
| tag | String | Kategori teknologi penanda (contoh: WEB, UI/UX). |
| whatsapp | String (Numeric) | Nomor kontak admin pengurus pesanan desainer. |
| status | String | Pengendali logika visibilitas data publik (Aktif/Arsip). |

### 4.2. Tabel: Percetakan
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| timestamp | Date / Time | Waktu penambahan baris data. |
| deskripsi | String | Nama komoditas produk cetak (contoh: Banner MMT). |
| harga | String / Numeric | Batasan tarif minimal layanan cetak. |
| ikon | String | Kelas penamaan ikon FontAwesome (contoh: `fa-print`). |
| whatsapp | String (Numeric) | Nomor WhatsApp tujuan pemesanan cetak. |
| status | String | Indikator ketersediaan operasional layanan. |

### 4.3. Tabel: Biro Jasa
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| timestamp | Date / Time | Waktu transaksi pengerjaan berkas didaftarkan. |
| layanan | String | Jenis pengurusan dokumen (contoh: Perpanjangan STNK). |
| nama | String | Nama lengkap konsumen pemilik unit. |
| merek | String | Merek pabrikan asal unit kendaraan bermotor. |
| type | String | Tipe varian spesifik unit kendaraan bermotor. |
| nomor_kendaraan | String | Nomor registrasi polisi (Nopol) kendaraan. |
| deskripsi | Text | Catatan penjelas progres tambahan berkas. |
| durasi | String | Status pelacakan posisi berkas saat ini secara real-time. |
| whatsapp | String (Numeric) | Nomor kontak telepon pengurus/konsumen. |
| aktif | String / Boolean | Penanda status keaktifan proses pengurusan berkas. |
| foto_stnk | String (URL) | Tautan aset digital scan STNK. *Wajib diletakkan pada repositori terproteksi yang tidak diindeks publik oleh Google.* |

### 4.4. Tabel: Users (Tabel Pengaman)
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| username | String | ID unik otentikasi masuk dasbor pengelola. |
| password | String | Kata sandi rahasia pengaman akses admin. |
| nama | String | Nama lengkap identitas personel pengelola. |

## 5. Mitigasi Batasan Sistem & Kebijakan Privasi

### 5.1. Manajemen Batasan Kuota Google Sheets & GAS
- **Limit Eksekusi API:** Karena Google menetapkan batas kuota harian untuk pembacaan dan penulisan API Apps Script, sistem pada Vercel dilarang melakukan pemanggilan *looping API* yang tidak perlu. Pemanggilan data bersifat tunggal saat memuat halaman pertama kali (*On-Load Fetching*).
- **Rencana Pengarsipan Berkala:** Mengingat performa pembacaan baris Google Sheets melambat seiring bertambahnya volume data, baris transaksi Biro Jasa yang statusnya sudah dinyatakan selesai lebih dari 90 hari wajib dipindahkan ke berkas spreadsheet cadangan (*Cold Storage*) oleh admin secara berkala.

### 5.2. Perlindungan Privasi Data Pelanggan
Kolom `foto_stnk` menyimpan data kepemilikan unit yang bersifat sensitif. URL berkas digital wajib diunggah ke Google Drive korporat yang hak aksesnya dikunci khusus untuk admin penanggung jawab saja, dan struktur sub-folder penyimpanan disetel menggunakan opsi `noindex` untuk mencegah pemindaian aset gambar oleh robot perayap publik di internet.

## 6. Kebutuhan Non-Fungsional (Quality Attributes)

### 6.1. Aspek Keamanan Informasi (Security NFR)
- **Isolasi Token Proyek:** Berkas enkripsi lokal dari peranti *Command Line* Google Clasp (`.clasp.json`) wajib dimasukkan ke dalam aturan pemblokiran repositori berkas `.gitignore`.
- **Masking Transparansi Akun:** Sandi masuk pada `Sheet: Users` wajib disimpan dalam format aman atau teks tersembunyi, dan tidak boleh dimuat ke memori *local storage* browser klien setelah otentikasi berhasil ditutup.

### 6.2. Aspek Performa Website (Performance NFR)
- **Kecepatan Pemuatan Halaman:** Seluruh pemanggilan fungsi HTTP REST API wajib dijalankan secara asinkron memanfaatkan konstruksi perintah `async/await`. Waktu render pertama ditargetkan ≤ 1.8 detik pada koneksi internet seluler standar 4G.

---
*Dokumen Spesifikasi Kebutuhan Produk Resmi © 2026 CV. KIRANA TANJUNG PELAKAR. Seluruh hak cipta dilindungi undang-undang.*

