import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CSVImportService {
  static List<List<dynamic>> parseCSV(String csvContent) {
    final rows = const CsvToListConverter().convert(csvContent);
    return rows;
  }

  static bool validateHeader(List<dynamic> header, String expectedHeader) {
    final headerList = header.map((e) => e.toString().trim()).toList();
    final expectedList = expectedHeader.split(',').map((e) => e.trim()).toList();
    
    if (headerList.length != expectedList.length) return false;
    
    for (int i = 0; i < expectedList.length; i++) {
      if (headerList[i].toLowerCase() != expectedList[i].toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  static Map<String, dynamic> validateCSV(String category, String csvContent) {
    try {
      final rows = parseCSV(csvContent);
      if (rows.isEmpty) {
        return {'valid': false, 'error': 'File CSV kosong.'};
      }

      final headers = {
        'Desain': 'Project,Tag,Deskripsi,Status,WhatsApp',
        'Percetakan': 'Produk,Harga,Min. Order,Ikon,Status,Keterangan,WhatsApp',
        'Boutique': 'Judul,Kategori,Deskripsi,Harga,Min. Order,Status,Gambar URL',
        'Biro Jasa': 'Layanan,Nama,Merek,Type,No. Kendaraan,Deskripsi,Progres,Masa Aktif,Status,STNK,WhatsApp,Username',
        'Users': 'Username,Password,Nama,NIK,Alamat,Role',
      };

      final expectedHeader = headers[category];
      if (expectedHeader == null) {
        return {'valid': false, 'error': 'Kategori tidak valid.'};
      }

      if (!validateHeader(rows[0], expectedHeader)) {
        return {
          'valid': false,
          'error': 'Header CSV tidak sesuai.\n\nExpected: $expectedHeader\n\nFound: ${rows[0].join(",")}'
        };
      }

      return {'valid': true, 'rowCount': '${rows.length - 1}'};
    } catch (e) {
      return {'valid': false, 'error': 'Gagal parsing CSV: $e'};
    }
  }

  static List<Map<String, String>> convertToMapList(
    String category,
    List<List<dynamic>> rows,
  ) {
    if (rows.isEmpty) return [];
    
    final headers = rows[0].map((e) => e.toString().trim()).toList();
    final dataRows = rows.skip(1);
    
    return dataRows.map((row) {
      final map = <String, String>{};
      for (int i = 0; i < headers.length && i < row.length; i++) {
        map[headers[i]] = row[i]?.toString() ?? '';
      }
      return map;
    }).toList();
  }
}

class CSVImportDialog extends StatefulWidget {
  const CSVImportDialog({
    super.key,
    required this.category,
    required this.onImport,
  });

  final String category;
  final Future<bool> Function(String category, List<Map<String, String>> data) onImport;

  @override
  State<CSVImportDialog> createState() => _CSVImportDialogState();
}

class _CSVImportDialogState extends State<CSVImportDialog> {
  String? _fileName;
  List<List<dynamic>>? _parsedData;
  bool _parsing = false;
  String? _error;
  bool _importing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      _fileName = file.name;
      _parsing = true;
      _error = null;
      _parsedData = null;
    });

    try {
      final csvContent = String.fromCharCodes(file.bytes!);
      final validation = CSVImportService.validateCSV(widget.category, csvContent);

      if (!mounted) return;

      if (validation['valid'] == true) {
        final parsed = CSVImportService.parseCSV(csvContent);
        setState(() {
          _parsedData = parsed;
          _parsing = false;
        });
      } else {
        setState(() {
          _error = validation['error']?.toString();
          _parsing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal membaca file: $e';
          _parsing = false;
        });
      }
    }
  }

  Future<void> _confirmImport() async {
    if (_parsedData == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.upload_file, color: Color(0xFF1769FF)),
            const SizedBox(width: 12),
            Text('Konfirmasi Import',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Text(
          'Anda akan mengimport ${_parsedData!.length - 1} data ke ${widget.category}.\n\nLanjutkan?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Import',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _importing = true);

    try {
      final dataMap = CSVImportService.convertToMapList(widget.category, _parsedData!);
      final success = await widget.onImport(widget.category, dataMap);

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
        } else {
          setState(() => _importing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import gagal.'),
              backgroundColor: Color(0xFFE5484D),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _importing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE5484D),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.upload_file, color: Color(0xFF1769FF)),
          const SizedBox(width: 12),
          Text('Import CSV - ${widget.category}',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_fileName != null) ...[
              Text('File: $_fileName',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B))),
              const SizedBox(height: 8),
            ],
            if (_parsing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              )
            else if (_parsedData != null) ...[
              Text(
                'Preview Data (${_parsedData!.length - 1} baris):',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListView.builder(
                  itemCount: _parsedData!.length.clamp(0, 6),
                  itemBuilder: (context, index) {
                    final row = _parsedData![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text(
                        row.join(', '),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
            ]
            else
              Text(
                'Pilih file CSV untuk import.\n\nTemplate header:\n${_getTemplateHeader()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _importing ? null : () => Navigator.pop(context),
          child: Text(_importing ? 'Mengimport...' : 'Batal',
              style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.bold)),
        ),
        if (!_importing)
          FilledButton.icon(
            onPressed: _parsedData != null ? _confirmImport : _pickFile,
            icon: Icon(_parsedData != null ? Icons.check : Icons.upload_file),
            label: Text(_parsedData != null ? 'Import' : 'Pilih File'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1769FF),
            ),
          ),
      ],
    );
  }

  String _getTemplateHeader() {
    final templates = {
      'Desain': 'Project,Tag,Deskripsi,Status,WhatsApp',
      'Percetakan': 'Produk,Harga,Min. Order,Ikon,Status,Keterangan,WhatsApp',
      'Boutique': 'Judul,Kategori,Deskripsi,Harga,Min. Order,Status,Gambar URL',
      'Biro Jasa': 'Layanan,Nama,Merek,Type,No. Kendaraan,Deskripsi,Progres,Masa Aktif,Status,STNK,WhatsApp,Username',
      'Users': 'Username,Password,Nama,NIK,Alamat,Role',
    };
    return templates[widget.category] ?? '';
  }
}
