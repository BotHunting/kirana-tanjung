import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class ModalKuasaViewer extends StatefulWidget {
  const ModalKuasaViewer({
    super.key,
    required this.item,
    required this.penerimaNama,
    required this.penerimaNik,
    required this.penerimaAlamat,
  });
  final Map<String, dynamic> item;
  final String penerimaNama;
  final String penerimaNik;
  final String penerimaAlamat;

  @override
  State<ModalKuasaViewer> createState() => _ModalKuasaViewerState();
}

class _ModalKuasaViewerState extends State<ModalKuasaViewer> {
  bool _isPrinting = false;

  Future<pw.MemoryImage?> _fetchNetworkImage(String url) async {
    if (url.trim().isEmpty) return null;
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (e) {
      debugPrint('Gagal memuat gambar dari network ($url): $e');
    }
    return null;
  }

  String _safeVal(List<String> keys) {
    for (final key in keys) {
      final v = widget.item[key];
      if (v != null) {
        final str = v.toString().trim();
        if (str.isNotEmpty) return str;
      }
    }
    return '-';
  }

  String _currentFormattedDate() {
    final now = DateTime.now();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _handlePrint(String nama, String nomor, String kendaraan) async {
    setState(() => _isPrinting = true);
    try {
      final fontRegular = await PdfGoogleFonts.plusJakartaSansRegular();
      final fontBold = await PdfGoogleFonts.plusJakartaSansBold();
      final logoImage = await _fetchNetworkImage(AppConfig.logoUrl);
      final materaiImage = await _fetchNetworkImage(AppConfig.materaiUrl);

      pw.TableRow pwRow(String label, String value,
          {bool isBoldValue = false}) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(label,
                  style: pw.TextStyle(font: fontRegular, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(': ',
                  style: pw.TextStyle(font: fontRegular, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(value,
                  style: pw.TextStyle(
                      font: isBoldValue ? fontBold : fontRegular,
                      fontSize: 10)),
            ),
          ],
        );
      }

      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Image(logoImage, width: 50, height: 50)
                    else
                      pw.SizedBox(width: 50, height: 50),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('CV. KIRANA TANJUNG PELAKAR',
                            style: pw.TextStyle(font: fontBold, fontSize: 13)),
                        pw.Text(
                            'Konsultan Teknologi Informasi & Layanan Transportasi Terpadu',
                            style:
                                pw.TextStyle(font: fontRegular, fontSize: 8.5)),
                        pw.Text(
                            'Alamat: Jl. Ky Syahlan 1 No. 7, Ds. Manyarejo, Kec. Manyar, Kab. Gresik',
                            style:
                                pw.TextStyle(font: fontRegular, fontSize: 7.5)),
                        pw.Text(
                            'Telepon: 081290320438 | Email: bot.hunting101@gmail.com | Website: https://kirana-tanjung.vercel.app/',
                            style:
                                pw.TextStyle(font: fontRegular, fontSize: 7.5)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 1.5, color: PdfColors.black),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text('SURAT KUASA',
                      style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 13,
                          decoration: pw.TextDecoration.underline)),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Yang bertanda tangan di bawah ini:',
                    style: pw.TextStyle(font: fontRegular, fontSize: 9.5)),
                pw.SizedBox(height: 4),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(110),
                    1: const pw.FixedColumnWidth(10),
                    2: const pw.FlexColumnWidth(),
                  },
                  children: [
                    pwRow('Nama', 'ADI JUNAIDI', isBoldValue: true),
                    pwRow('Jabatan', 'DIREKTUR'),
                    pwRow('Instansi/Perusahaan', 'CV. KIRANA TANJUNG PELAKAR'),
                    pwRow('NPWP', '31.585.382.0-603.000'),
                    pwRow('Alamat Kantor',
                        'Jl. Ky Syahlan 1 No. 7, Ds. Manyarejo, Kec. Manyar, Kab. Gresik'),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                    'Dalam hal ini bertindak untuk dan atas nama CV. KIRANA TANJUNG PELAKAR.',
                    style: pw.TextStyle(font: fontRegular, fontSize: 9.5)),
                pw.SizedBox(height: 8),
                pw.Text('Dengan ini memberikan tugas kepada:',
                    style: pw.TextStyle(font: fontRegular, fontSize: 9.5)),
                pw.SizedBox(height: 4),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(110),
                    1: const pw.FixedColumnWidth(10),
                    2: const pw.FlexColumnWidth(),
                  },
                  children: [
                    pwRow('Nama', widget.penerimaNama, isBoldValue: true),
                    pwRow('NIK', widget.penerimaNik),
                    pwRow('Jabatan', 'Staff Administrasi'),
                    pwRow('Alamat Kantor', widget.penerimaAlamat),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Untuk melakukan pengurusan seluruh administrasi dan dokumen kendaraan bermotor terhadap unit dengan identitas sebagai berikut:',
                  style: pw.TextStyle(
                      font: fontRegular, fontSize: 9.5, lineSpacing: 1.3),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(90),
                      1: const pw.FixedColumnWidth(10),
                      2: const pw.FlexColumnWidth(),
                    },
                    children: [
                      pwRow('Nama Pemilik', nama, isBoldValue: true),
                      pwRow('Nomor Uji', nomor),
                      pwRow('Merk / Type', kendaraan),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Petugas yang namanya tersebut di atas berwenang penuh untuk melakukan seluruh rangkaian pengurusan administrasi kendaraan bermotor, meliputi penandatanganan berkas pendaftaran, proses pemeriksaan/cek fisik/pengujian, pembayaran pajak/retribusi/PNBP, serta pengambilan dokumen/bukti resmi hasil pengurusan di lingkungan Kantor Dinas Perhubungan, SAMSAT, maupun instansi terkait. Demikian Surat Tugas ini dibuat dengan sebenarnya untuk dipergunakan sebagaimana mestinya.',
                  style: pw.TextStyle(
                      font: fontRegular, fontSize: 8.5, lineSpacing: 1.3),
                  textAlign: pw.TextAlign.justify,
                ),
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 200,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Gresik, ${_currentFormattedDate()}',
                            style:
                                pw.TextStyle(font: fontRegular, fontSize: 10)),
                        pw.SizedBox(height: 2),
                        pw.Text('Hormat kami,',
                            style: pw.TextStyle(font: fontBold, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        if (materaiImage != null)
                          pw.Image(materaiImage, width: 60, height: 60)
                        else
                          pw.SizedBox(width: 60, height: 60),
                        pw.SizedBox(height: 4),
                        pw.Text('ADI JUNAIDI',
                            style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 11,
                                decoration: pw.TextDecoration.underline)),
                        pw.Text('Direktur',
                            style:
                                pw.TextStyle(font: fontRegular, fontSize: 8.5)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Surat_Tugas_${nomor.replaceAll(' ', '_')}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mencetak dokumen PDF: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final namaPemilik = _safeVal(['nama', 'pemilik']);
    final nomorUji =
        _safeVal(['nomor_kendaraan', 'nomor_uji', 'nomer_uji', 'id']);

    final merek = _safeVal(['merek', 'merk']);
    final type = _safeVal(['type']);
    final merkType = (merek != '-' && type != '-')
        ? '$merek / $type'
        : (merek != '-' ? merek : type);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.88,
          child: Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              title: Text(
                'Surat Kuasa (A4)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                _isPrinting
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF1769FF)),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Cetak Dokumen',
                        icon: const Icon(Icons.print, color: Color(0xFF1769FF)),
                        onPressed: () =>
                            _handlePrint(namaPemilik, nomorUji, merkType),
                      ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'CV. KIRANA TANJUNG PELAKAR',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Konsultan Teknologi Informasi & Layanan Transportasi Terpadu',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              'Alamat: Jl. Ky Syahlan 1 No. 9, Ds. Manyarejo, Kec. Manyar, Kab. Gresik',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(
                                thickness: 1.5, color: Color(0xFF0F172A)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Yang bertanda tangan di bawah ini:',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: const Color(0xFF334155))),
                      const SizedBox(height: 4),
                      _buildRowDetail('Nama', 'ADI JUNAIDI', isBold: true),
                      _buildRowDetail('Jabatan', 'DIREKTUR'),
                      _buildRowDetail(
                          'Perusahaan', 'CV. KIRANA TANJUNG PELAKAR'),
                      _buildRowDetail('NPWP', '31.585.382.0-603.000'),
                      _buildRowDetail('Alamat Kantor',
                          'Jl. Ky Syahlan 1 No. 7, Ds. Manyarejo, Kec. Manyar, Kab. Gresik'),
                      const SizedBox(height: 8),
                      Text(
                          'Dalam hal ini bertindak untuk dan atas nama CV. KIRANA TANJUNG PELAKAR.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: const Color(0xFF334155))),
                      const SizedBox(height: 12),
                      Text('Dengan ini memberikan tugas kepada:',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: const Color(0xFF334155))),
                      const SizedBox(height: 4),
                      _buildRowDetail('Nama', widget.penerimaNama,
                          isBold: true),
                      _buildRowDetail('NIK', widget.penerimaNik),
                      _buildRowDetail('Jabatan', 'Staff Administrasi'),
                      _buildRowDetail('Alamat Kantor', widget.penerimaAlamat),
                      const SizedBox(height: 16),
                      Text(
                        'Untuk melakukan pengurusan seluruh administrasi dan dokumen kendaraan bermotor terhadap unit dengan identitas sebagai berikut:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildRowDetail('Nama Pemilik', namaPemilik,
                                isBold: true),
                            const SizedBox(height: 8),
                            _buildRowDetail('Nomor Uji', nomorUji),
                            const SizedBox(height: 8),
                            _buildRowDetail('Merk / Type', merkType),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Petugas yang namanya tersebut di atas berwenang penuh untuk melakukan seluruh rangkaian pengurusan administrasi kendaraan bermotor, meliputi penandatanganan berkas pendaftaran, proses pemeriksaan/cek fisik/pengujian, pembayaran pajak/retribusi/PNBP, serta pengambilan dokumen/bukti resmi hasil pengurusan di lingkungan Kantor Dinas Perhubungan, SAMSAT, maupun instansi terkait. Demikian Surat Tugas ini dibuat dengan sebenarnya untuk dipergunakan sebagaimana mestinya.',
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            Text(
                              'Gresik, ${_currentFormattedDate()}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hormat kami,',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // E-Materai dari URL
                            CachedNetworkImage(
                              imageUrl: AppConfig.materaiUrl,
                              width: 80,
                              height: 80,
                              memCacheWidth:
                                  160, // Decode sesuai ukuran display
                              memCacheHeight: 160,
                              fit: BoxFit.contain,
                              errorWidget: (_, __, ___) =>
                                  const SizedBox(width: 80, height: 80),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ADI JUNAIDI',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'DIREKTUR',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowDetail(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          ': ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
