import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  static String appVersion = '1.0.3';

  static const String updateApiUrl =
      'https://api.github.com/repos/BotHunting/kirana-tanjung/releases/latest';

  static const String databaseUrl =
      'https://script.google.com/macros/s/AKfycbzwJz5NMOBnkuT_LaQD82845M7hoWA7EiuezNEWUQ35Hibn-WF2UXv2HCFyh5GvOh03/exec';

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
      final targetDate = DateTime.parse(tanggalStr.trim());
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
