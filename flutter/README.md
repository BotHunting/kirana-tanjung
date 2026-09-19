# kirana_tanjung

## Kirana Tanjung Management Dashboard

Aplikasi Flutter teroptimasi untuk manajemen data dan layanan CV. Kirana Tanjung Pelakar.

---

### Versi Aplikasi: `1.0.3`

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

### Panduan Teknis & Build:

-   **Optimasi Dependensi**:
    -   Pembersihan dependensi tidak terpakai (`webview_flutter`, `web`) untuk reduksi ukuran biner.
    -   Otomatisasi pembersihan impor menggunakan `dart fix --apply`.
-   **Konfigurasi Build Android**:
    -   **SDK Version**: `minSdkVersion 21`, `targetSdkVersion 34`, `compileSdkVersion 34`.
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
