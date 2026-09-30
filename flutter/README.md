# Natala Studio

## Natala Studio Management Dashboard (by Kirana Tanjung)

Aplikasi Flutter teroptimasi untuk manajemen data dan layanan Natala Studio (anak perusahaan CV. Kirana Tanjung Pelakar).

---

### Versi Aplikasi: `1.1.2`

### Fitur Utama:

-   **Auto Update & Popup Notification**:
    -   Mekanisme deteksi versi otomatis dari GitHub Releases (`BotHunting/kirana-tanjung`).
    -   Notifikasi pop-up interaktif untuk pembaruan aplikasi (APK & PWA).
    -   Pengunduhan APK in-app dan *force refresh* Service Worker untuk PWA.
-   **Optimasi Performa**:
    -   Pembatasan cache gambar (`cached_network_image`) untuk mengurangi penggunaan memori.
    -   Offloading parsing JSON ke *isolate* (`compute`) untuk mencegah *UI jank*.
-   **Konsistensi UI/UX**:
    -   Penggunaan `web/favicon.png` sebagai ikon aplikasi di seluruh platform (Android, iOS, Web) dan komponen UI.
    -   Penyelarasan API warna (`withValues` vs `withOpacity`) untuk kompatibilitas SDK Flutter terbaru.
-   **Manajemen Data**:
    -   Integrasi dengan Google Sheets sebagai backend data (melalui Google Apps Script).
    -   Fungsionalitas CRUD (Create, Read, Update, Delete) untuk data desain, percetakan, dan biro jasa.
    -   Fitur pencarian dan filter data yang responsif.
-   **Cetak Dokumen**:
    -   Generasi dan pratinjau PDF Surat Kuasa untuk layanan biro jasa.
    -   Fungsionalitas cetak langsung melalui `printing` package.

---

### Catatan Perubahan (v1.1.2):
- **Re-Branding Natala Studio (by Kirana Tanjung)**: Penyelarasan identitas visual dan operasional anak perusahaan pada antarmuka utama, app bar, header, dan template notifikasi WhatsApp pengingat jatuh tempo KIR/SAMSAT. Legalitas korporat tetap terikat pada CV. Kirana Tanjung Pelakar.
- **Refaktor Root Widget & Multiplatform Title**: Pembaruan kelas aplikasi menjadi `NatalaStudioApp`, konfigurasi `android:label` pada `AndroidManifest.xml`, metadata `web/manifest.json`, `<title>` di `web/index.html`, serta judul jendela desktop di `windows/runner/main.cpp`.
- **Otomasi Penamaan Build Biner**: Sinkronisasi skrip kompilasi `build_apks.sh` dan `build_apks.ps1` untuk mengekspor artefak APK dengan prefix `Natala-Studio-Kentang`, `Natala-Studio-Medium`, dan `Natala-Studio-Super-Universal`.
- **Pembersihan Encoding Ganda (Bugfix)**: Menghapus `Uri.encodeComponent` redundan pada pemanggilan WhatsApp di `dashboard.dart` demi kestabilan pesan pada runtime web/browser.
- **Audit Target SDK (2026)**: Peningkatan build Android ke target API level 36 (Android 16) demi kepatuhan regulasi Google Play Store terbaru tahun 2026.
- **Penyempurnaan Helper**: Optimalisasi parser format Rupiah dinamis serta pemetaan nama bulan lokal terpusat di `AppConfig`.
- **Integrasi PWA & Web**: Sinkronisasi asset `web/favicon.png` sebagai ikon global aplikasi.

### Catatan Perubahan (v1.1.1):
- **Mekanisme Secret Login**: Menghilangkan tombol login visual, beralih ke pemicu 3x klik logo untuk membuka gerbang login.
- **Katalog Boutique & Konveksi**: Implementasi reaktivitas state dan UI list dinamis bebas crash menggunakan batasan tinggi gambar absolut (180px).
- **Fix UI Overflow**: Restrukturisasi tombol CRUD admin menjadi Grid 2x2, serta penyesuaian rasio aspek StatTile Dashboard beranda.
- **Format Rupiah Dinamis**: Helper mata uang pintar terpusat di `AppConfig` untuk standardisasi format nominal data numerik dari Google Sheets.
- **Refaktor & Clean Code**: Penghapusan total file redundant `lib/item.dart` dan penggabungan logika form penyeleksi status/kategori ke dalam `lib/dashboard.dart`.

---

### Panduan Teknis & Build:

-   **Optimasi Dependensi**:
    -   Pembersihan dependensi tidak terpakai (`webview_flutter`, `web`) untuk reduksi ukuran biner.
    -   Otomatisasi pembersihan impor menggunakan `dart fix --apply`.
-   **Konfigurasi Build Android**:
    -   **SDK Version**: `minSdkVersion 21`, `targetSdkVersion 36`, `compileSdkVersion 36` (Kepatuhan Google Play 2026).
    -   **Toolchain Fix**: Penghapusan *hardcoded* `ndkVersion` untuk fleksibilitas compiler.
    -   **JDK Compatibility**: Direkomendasikan menggunakan JDK 17 (JetBrains Runtime) untuk menghindari *restricted method warnings* pada Gradle 8.1.
-   **Export Produksi**:
    ```bash
    # Membersihkan cache korup
    flutter clean
    
    # Build APK terpisah per arsitektur (ARMv7, ARMv8, x86_64)
    flutter build apk --release --split-per-abi
    ```
-   **Keamanan & Ukuran**:
    -   Implementasi R8/ProGuard (`minifyEnabled true`) untuk *code shrinking* dan *obfuscation*.

---
