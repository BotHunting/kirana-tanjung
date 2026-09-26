import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  static String appVersion = '1.0.3';

  static const String updateApiUrl =
      'https://api.github.com/repos/BotHunting/kirana-tanjung/releases/latest';

  static const String databaseUrl =
      'https://script.google.com/macros/s/AKfycbzwJz5NMOBnkuT_LaQD82845M7hoWA7EiuezNEWUQ35Hibn-WF2UXv2HCFyh5GvOh03/exec';

  // Daftar Kontak WhatsApp Resmi Per Kategori
  static const String waDesainSistem = '6281290320438'; // Desain & Web System
  static const String waPercetakan = '6281233223830'; // Layanan Percetakan
  static const String waBoutique = '6281938929455'; // Boutique & Konveksi
  static const String waBiroJasa = '6281290320438'; // Biro Jasa Transportasi

  // Helper Pembuat Link WA
  static Uri getWaUrl(String targetNumber, String message) {
    final encodedText = Uri.encodeComponent(message);
    return Uri.parse('https://wa.me/$targetNumber?text=$encodedText');
  }

  static const String materaiUrl =
      'https://raw.githubusercontent.com/BotHunting/kirana-tanjung/refs/heads/main/www/materai.png';

  static const String logoUrl =
      'https://raw.githubusercontent.com/BotHunting/kirana-tanjung/refs/heads/main/www/Kirana.png';

  // Data Base64 Tanda Tangan
  static const String signatureBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAGQAAAAyCAYAAACqJ6iOAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH5QgKDA4Zix5WFAAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUOdlbmQAAAAASUVORK5CYII=';

  // Data Base64 Stempel (Placeholder)
  static const String stampBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH5QgKDA8dJz9F4AAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUOdlbmQAAAAASUVORK5CYII=';

  static Future<void> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (_) {}
  }

  // Helper Menghitung Sisa Hari Masa Aktif
  static ({int sisa, bool isExpired, bool isWarning, bool isValid}) getSisaHari(
      String? tanggalStr) {
    if (tanggalStr == null || tanggalStr.trim().isEmpty) {
      return (sisa: 999, isExpired: false, isWarning: false, isValid: false);
    }
    try {
      String sanitizedStr = tanggalStr.trim();

      // Map nama bulan lokal/singkat ke format angka ISO
      final bulanMap = {
        'jan': '01',
        'feb': '02',
        'mar': '03',
        'apr': '04',
        'mei': '05',
        'jun': '06',
        'jul': '07',
        'agu': '08',
        'sep': '09',
        'okt': '10',
        'nov': '11',
        'des': '12'
      };

      final parts = sanitizedStr.split(' ');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final bulanLower = parts[1].toLowerCase();
        final month = bulanMap[bulanLower] ??
            bulanMap[bulanLower.substring(0, 3)] ??
            '01';
        final year = parts[2];
        sanitizedStr = '$year-$month-$day';
      }

      final targetDate = DateTime.parse(sanitizedStr);
      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, now.day);
      final sisa = targetDate.difference(currentDate).inDays;
      return (
        sisa: sisa,
        isExpired: sisa <= 0,
        isWarning: sisa > 0 && sisa <= 30,
        isValid: true,
      );
    } catch (_) {
      return (sisa: 999, isExpired: false, isWarning: false, isValid: false);
    }
  }
}
