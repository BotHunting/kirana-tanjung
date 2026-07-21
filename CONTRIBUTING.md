# Panduan Berkontribusi

Terima kasih telah tertarik untuk berkontribusi pada proyek Sistem Informasi CV. Kirana Tanjung Pelakar! Setiap kontribusi, sekecil apapun, sangat kami hargai.

## Daftar Isi
- [Cara Berkontribusi](#cara-berkontribusi)
- [Panduan Setup Pengembangan](#panduan-setup-pengembangan)
- [Proses Pull Request](#proses-pull-request)
- [Gaya Penulisan Kode](#gaya-penulisan-kode)

## Cara Berkontribusi

### 🐞 Melaporkan Bug
- Jika Anda menemukan bug, silakan buat **[Issue baru](https://github.com/BotHunting/kirana-tanjung/issues/new)**.
- Jelaskan bug tersebut secara detail, termasuk langkah-langkah untuk mereproduksinya.
- Untuk kerentanan keamanan, silakan ikuti [Kebijakan Keamanan](https://github.com/BotHunting/kirana-tanjung/blob/main/SECURITY.md) kami.

### ✨ Menyarankan Fitur Baru
- Jika Anda memiliki ide untuk fitur baru atau perbaikan, silakan buat **[Issue baru](https://github.com/BotHunting/kirana-tanjung/issues/new)** untuk mendiskusikannya.
- Jelaskan ide Anda sejelas mungkin, termasuk potensi manfaatnya bagi pengguna.

## Panduan Setup Pengembangan

Sistem ini memiliki arsitektur yang unik (Vercel + Google Apps Script + Capacitor). Berikut adalah langkah-langkah untuk melakukan setup di lingkungan lokal Anda.

### Prasyarat
- Akun Google
- [Node.js](https://nodejs.org/)
- (Opsional, tapi direkomendasikan) [clasp](https://github.com/google/clasp) - CLI untuk Google Apps Script

### 1. Backend (Google Apps Script)
1.  **Buat Google Sheet:** Buat Google Sheet baru sebagai database Anda.
2.  **Siapkan Sheet:** Buat 4 sheet dengan nama dan header yang sesuai dengan [skema database di README](https://github.com/BotHunting/kirana-tanjung#%EF%B8%8F-5-skema-database-google-sheets).
3.  **Buka Apps Script:** Dari Google Sheet, buka `Extensions > Apps Script`.
4.  **Salin Kode:** Salin seluruh konten dari `script/Code.js` di repositori ini ke dalam file `Code.gs` di editor Apps Script.
5.  **Buat File HTML:** Di dalam editor Apps Script, buat file-file HTML yang diperlukan (seperti `index.html`, `dashboard.html`, dll.). Kode untuk file-file ini tidak ada di repositori, jadi Anda mungkin perlu membuatnya berdasarkan logika di `Code.gs`.
6.  **Deploy:** Deploy proyek Apps Script sebagai **Web app**. Pastikan `Who has access` diatur ke `Anyone`. Salin URL Web App yang Anda dapatkan.

### 2. Frontend (Vercel Wrapper)
1.  **Clone Repositori:** `git clone https://github.com/BotHunting/kirana-tanjung.git`
2.  **Update URL:** Buka file `index.html` di root direktori dan ganti URL `src` pada `<iframe>` dengan URL Web App yang Anda dapatkan dari langkah sebelumnya.

### 3. Mobile (Capacitor - Opsional)
Jika Anda ingin mengerjakan versi Android:
1.  **Install Dependensi:** `npm install`
2.  **Sinkronkan Proyek:** `npx cap sync android`
3.  **Buka di Android Studio:** `npx cap open android`

## Proses Pull Request

1.  **Fork** repositori ini.
2.  Buat branch baru untuk fitur Anda (`git checkout -b fitur/nama-fitur-keren`).
3.  Lakukan perubahan dan **commit** (`git commit -m 'Menambahkan fitur keren'`).
4.  **Push** ke branch Anda (`git push origin fitur/nama-fitur-keren`).
5.  Buka **Pull Request** ke branch `main` dari repositori ini.
6.  Pastikan untuk menjelaskan perubahan Anda secara jelas di deskripsi Pull Request.

## Gaya Penulisan Kode

- **JavaScript (Google Apps Script):** Gunakan gaya penulisan yang konsisten. Tambahkan komentar untuk logika yang kompleks.
- **HTML:** Gunakan tag HTML semantik.
- **Commit Messages:** Tulis pesan commit yang jelas dan deskriptif.

Sekali lagi, terima kasih atas kontribusi Anda!