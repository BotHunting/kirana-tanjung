import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config.dart';

class ModalKuasaViewer extends StatelessWidget {
  const ModalKuasaViewer({super.key, required this.item});
  final Map<String, dynamic> item;

  String _safeVal(List<String> keys) {
    for (final key in keys) {
      final v = item[key];
      if (v != null) {
        final str = v.toString().trim();
        if (str.isNotEmpty) return str;
      }
    }
    return '-';
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
                IconButton(
                  tooltip: 'Cetak Dokumen',
                  icon: const Icon(Icons.print, color: Color(0xFF1769FF)),
                  onPressed: () {
                    // Panggil fungsi cetak dokumen
                  },
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
                      Center(
                        child: Text(
                          'SURAT TUGAS PENGURUSAN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Yang bertanda tangan di bawah ini memberikan tugas pengurusan kendaraan kepada staff resmi dengan rincian identitas kendaraan sebagai berikut:',
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
                        'Demikian Surat Tugas ini dibuat dengan sebenarnya untuk dipergunakan dalam proses pengujian berkala kendaraan bermotor sebagaimana mestinya.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            Text(
                              'Gresik, 11 September 2026',
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
                              'NIK. 9203015308670001',
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
