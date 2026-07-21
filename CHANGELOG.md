# Changelog CV. Kirana Tanjung Pelakar

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-07-25 (Dokumentasi & Frontend)
### Added
- `CONTRIBUTING.md` untuk memberikan panduan kontribusi yang jelas.

### Changed
- `README.md` diubah total dari format PRD menjadi dokumentasi proyek standar.
- `SECURITY.md` diperbarui dengan kebijakan yang jelas dan proses pelaporan kerentanan.
- Tag Open Graph di `index.html` diperbarui untuk pratinjau media sosial yang lebih baik.

## [1.1.0] - 2026-07-21 (Integrasi Mobile)
### Added
- Integrasi Capacitor JS untuk kompilasi APK Android.
- Penambahan logika auto-expiry untuk perpanjangan KIR & Samsat.

## [1.0.0] - 2026-07-01 - 2026-07-20 (Rilis Awal & Iterasi)

### Added
- Penambahan kolom `merek` dan `type` pada layanan Biro Jasa untuk detail kendaraan yang lebih baik.
- Penambahan fitur status perpanjangan untuk layanan terkait.
- Implementasi `clasp` untuk sinkronisasi otomatis dari VS Code ke Google Apps Script.

### Changed
- **Refactor Arsitektur**: Mengubah sistem dari Web App standar menjadi arsitektur API JSON untuk mendukung *masking* URL melalui Vercel.
- Memperbarui tabel layanan jasa untuk menampilkan status "On Process".
- Memperbarui template pesan otomatis untuk integrasi WhatsApp.
- Dasbor admin diperbarui untuk fungsionalitas yang lebih baik.

### Fixed
- Perbaikan berbagai bug pada tampilan tabel di portal publik dan dasbor admin.
- Perbaikan fungsi tombol gambar dan tautan untuk foto STNK.

## [Pre-release] - 2026-04-19 - 2026-04-27 (Inisiasi Proyek)
### Added
- Inisiasi proyek dan struktur dasar oleh `Nobita Nobi`.
- Pengembangan awal antarmuka pengguna dan logika backend.

---
*Catatan: Versi dan tanggal di atas adalah rangkuman dari histori versi di Google Apps Script.*