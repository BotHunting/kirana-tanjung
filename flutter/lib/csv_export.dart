import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'main.dart' show appValue;

class CSVExportService {
  static Future<String> exportDesain(List<dynamic> items) async {
    final rows = <List<String>>[
      ['Project', 'Tag', 'Deskripsi', 'Status', 'WhatsApp'],
      ...items.map((item) => [
          appValue(item, 'nama'),
          appValue(item, 'tag'),
          appValue(item, 'deskripsi'),
          appValue(item, 'status'),
          appValue(item, 'whatsapp'),
        ]),
    ];
    return _generateCSV(rows);
  }

  static Future<String> exportPercetakan(List<dynamic> items) async {
    final rows = <List<String>>[
      ['Produk', 'Harga', 'Min. Order', 'Ikon', 'Status', 'Keterangan', 'WhatsApp'],
      ...items.map((item) => [
          appValue(item, 'deskripsi'),
          appValue(item, 'harga'),
          appValue(item, 'min_order'),
          appValue(item, 'ikon'),
          appValue(item, 'status'),
          appValue(item, 'keterangan'),
          appValue(item, 'whatsapp'),
        ]),
    ];
    return _generateCSV(rows);
  }

  static Future<String> exportBoutique(List<dynamic> items) async {
    final rows = <List<String>>[
      ['Judul', 'Kategori', 'Deskripsi', 'Harga', 'Min. Order', 'Status', 'Gambar URL'],
      ...items.map((item) => [
          appValue(item, 'judul'),
          appValue(item, 'kategori'),
          appValue(item, 'deskripsi'),
          appValue(item, 'harga'),
          appValue(item, 'min_order'),
          appValue(item, 'status'),
          appValue(item, 'gambar_url'),
        ]),
    ];
    return _generateCSV(rows);
  }

  static Future<String> exportBiroJasa(List<dynamic> items) async {
    final rows = <List<String>>[
      ['Layanan', 'Nama', 'Merek', 'Type', 'No. Kendaraan', 'Deskripsi', 'Progres', 'Masa Aktif', 'Status', 'STNK', 'WhatsApp', 'Username'],
      ...items.map((item) => [
          appValue(item, 'layanan'),
          appValue(item, 'nama'),
          appValue(item, 'merek'),
          appValue(item, 'type'),
          appValue(item, 'nomor_kendaraan'),
          appValue(item, 'deskripsi'),
          appValue(item, 'durasi'),
          appValue(item, 'aktif'),
          appValue(item, 'status'),
          appValue(item, 'foto_stnk'),
          appValue(item, 'whatsapp'),
          appValue(item, 'username'),
        ]),
    ];
    return _generateCSV(rows);
  }

  static Future<String> exportUsers(List<dynamic> items) async {
    final rows = <List<String>>[
      ['Username', 'Password', 'Nama', 'NIK', 'Alamat', 'Role'],
      ...items.map((item) => [
          appValue(item, 'username'),
          '***', // Password disembunyikan
          appValue(item, 'nama'),
          appValue(item, 'nik'),
          appValue(item, 'alamat'),
          appValue(item, 'role'),
        ]),
    ];
    return _generateCSV(rows);
  }

  static String _generateCSV(List<List<String>> rows) {
    return const ListToCsvConverter().convert(rows);
  }

  static Future<File> saveCSVToFile(String csvContent, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, filename);
    final file = File(path);
    await file.writeAsString(csvContent);
    return file;
  }
}
