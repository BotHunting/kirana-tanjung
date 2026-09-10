import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'config.dart';

class ModalKuasaViewer extends StatelessWidget {
  const ModalKuasaViewer({super.key, required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Pratinjau & Cetak Surat Kuasa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: PdfPreview(
              build: (format) => generateSuratKuasaPdf(format, item),
              allowPrinting: true,
              allowSharing: true,
              canChangeOrientation: false,
              canChangePageFormat: false,
              initialPageFormat: PdfPageFormat.a4,
            ),
          ),
        ),
      ),
    );
  }
}

// Cache font di level memori untuk menghindari request berulang
pw.Font? _cachedFontRegular;
pw.Font? _cachedFontBold;

Future<Uint8List> generateSuratKuasaPdf(
    PdfPageFormat format, Map<String, dynamic> item) async {
  final pdf = pw.Document();

  // Load images from Config
  final pw.MemoryImage signatureImage =
      pw.MemoryImage(base64Decode(AppConfig.signatureBase64));
  final pw.MemoryImage stampImage =
      pw.MemoryImage(base64Decode(AppConfig.stampBase64));

  // Implementasi Font Caching
  if (_cachedFontRegular == null || _cachedFontBold == null) {
    try {
      _cachedFontRegular = await PdfGoogleFonts.plusJakartaSansRegular();
      _cachedFontBold = await PdfGoogleFonts.plusJakartaSansBold();
    } catch (_) {
      _cachedFontRegular = pw.Font.helvetica();
      _cachedFontBold = pw.Font.helveticaBold();
    }
  }

  // Memuat logo untuk Watermark (Gunakan URL placeholder atau logo Kirana)
  pw.ImageProvider? logoImage;
  try {
    // Mengambil thumbnail dari Google Drive ID logo jika tersedia,
    // atau fallback ke Icon jika gagal memuat.
    logoImage = await networkImage(
      AppConfig.logoUrl,
      headers: {'User-Agent': 'Mozilla/5.0'},
    );
  } catch (_) {
    logoImage = null;
  }

  String safeVal(String key) {
    final v = item[key];
    if (v == null) return '-';
    final str = v.toString().trim();
    return str.isEmpty ? '-' : str;
  }

  final namaPemilik = safeVal('nama');
  final nomorUji = safeVal('nomor_kendaraan');
  final merkType = '${safeVal('merek')} / ${safeVal('type')}';

  pdf.addPage(
    pw.Page(
      pageFormat: format,
      theme: pw.ThemeData.withFont(
        base: _cachedFontRegular!,
        bold: _cachedFontBold!,
      ),
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Penempatan Watermark
              if (logoImage != null)
                pw.Watermark(
                  child: pw.Opacity(
                    opacity: 0.05,
                    child: pw.Image(logoImage, width: 400),
                  ),
                ),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'CV. KIRANA TANJUNG PELAKAR',
                      style: const pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 16),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Konsultan Teknologi Informasi & Layanan Transportasi Terpadu',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Alamat: Jl. Ky Syahlan 1 No. 9, Ds. Manyarejo, Kec. Manyar, Kab. Gresik',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 1),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'SURAT TUGAS PENGURUSAN',
                  style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 13),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Informasi Kendaraan:',
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                columnWidths: const {
                  0: pw.FixedColumnWidth(100),
                  1: pw.FixedColumnWidth(15),
                  2: pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(children: [
                    pw.Text('Nama Pemilik'),
                    pw.Text(':'),
                    pw.Text(namaPemilik,
                        style:
                            const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Nomor Uji'),
                    pw.Text(':'),
                    pw.Text(nomorUji),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Merk / Type'),
                    pw.Text(':'),
                    pw.Text(merkType),
                  ]),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Demikian Surat Tugas ini dibuat dengan sebenarnya untuk dipergunakan sebagaimana mestinya.',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Gresik, 11 September 2026',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text('Hormat kami,',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 5),
                    pw.Stack(
                      alignment: pw.Alignment.center,
                      children: [
                        pw.Image(
                          signatureImage,
                          width: 80,
                          height: 40,
                          fit: pw.BoxFit.contain,
                        ),
                        pw.Positioned(
                          left: -10,
                          child: pw.Opacity(
                            opacity: 0.8,
                            child: pw.Image(
                              stampImage,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'ADI JUNAIDI',
                      style: const pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                    pw.Text('Direktur',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}
