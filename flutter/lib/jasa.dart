import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';

class BiroJasaView extends StatelessWidget {
  const BiroJasaView({
    super.key,
    required this.items,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onShowKuasa,
  });

  final List<Map<String, dynamic>> items;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final void Function(Map<String, dynamic> item) onShowKuasa;

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) {
      final nama = (item['nama'] ?? '').toString().toLowerCase();
      final nomorUji = (item['nomor_kendaraan'] ?? '').toString().toLowerCase();
      final merk =
          (item['merek'] ?? item['type'] ?? '').toString().toLowerCase();
      final q = searchQuery.toLowerCase().trim();
      return nama.contains(q) || nomorUji.contains(q) || merk.contains(q);
    }).toList();

    filteredItems.sort((a, b) {
      final dateA = DateTime.tryParse(a['aktif']?.toString() ?? '-');
      final dateB = DateTime.tryParse(b['aktif']?.toString() ?? '-');
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateA.compareTo(dateB);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUS BERKAS & LAYANAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1769FF),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Biro Jasa Transportasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pantau progres pengurusan KIR, SAMSAT, dan Rekomendasi.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari nama pemilik, no. uji, atau merk...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada data biro jasa ditemukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final nama = (item['nama'] ?? 'Tanpa Nama').toString();
                        final nomorUji =
                            (item['nomor_kendaraan'] ?? '-').toString();
                        final merk =
                            '${item['merek'] ?? '-'} / ${item['type'] ?? '-'}';
                        final masaAktifStr =
                            (item['aktif'] ?? item['tanggal'] ?? '').toString();
                        final statusPengurusan =
                            (item['durasi'] ?? 'ON PROCESS').toString();
                        final isSelesai = statusPengurusan.contains('SELESAI');

                        final expiry = AppConfig.getSisaHari(masaAktifStr);
                        final sisaHari = expiry.sisa;

                        String labelH = '';
                        if (sisaHari < 0) {
                          labelH = 'Lewat ${sisaHari.abs()} hr';
                        } else if (sisaHari == 0) {
                          labelH = 'Jatuh Tempo Hari Ini';
                        } else if (sisaHari <= 30) {
                          labelH = 'Sisa $sisaHari hr';
                        }

                        final bool perluWarning =
                            expiry.isValid && sisaHari <= 30;
                        final Color bannerBg = sisaHari <= 0
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFFEF3C7);
                        final Color bannerText = sisaHari <= 0
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF92400E);
                        final Color bannerBorder = sisaHari <= 0
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFFCD34D);
                        final hpPemilik = (item['whatsapp'] ?? '').toString();

                        final layanan =
                            (item['layanan'] ?? '').toString().toUpperCase();
                        final IconData jasaIcon = layanan == 'KIR'
                            ? Icons.local_shipping_outlined
                            : layanan == 'SAMSAT'
                                ? Icons.credit_card_outlined
                                : layanan == 'REKOM'
                                    ? Icons.verified_outlined
                                    : Icons.directions_car_outlined;
                        final Color jasaColor = layanan == 'KIR'
                            ? const Color(0xFF6556D9)
                            : layanan == 'SAMSAT'
                                ? const Color(0xFF1769FF)
                                : layanan == 'REKOM'
                                    ? const Color(0xFF0C9B77)
                                    : const Color(0xFF64748B);

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: jasaColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      jasaIcon,
                                      color: jasaColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(nama,
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    const Color(0xFF0F172A))),
                                        Text('No. Uji: $nomorUji',
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    const Color(0xFF1769FF))),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelesai
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFDBEAFE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(statusPengurusan,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isSelesai
                                                ? const Color(0xFF15803D)
                                                : const Color(0xFF1D4ED8))),
                                  ),
                                ],
                              ),
                              if (perluWarning) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: bannerBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: bannerBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        sisaHari <= 0
                                            ? Icons.error_outline_rounded
                                            : Icons.access_time_rounded,
                                        size: 15,
                                        color: bannerText,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          sisaHari <= 0
                                              ? 'KEDALUWARSA ($labelH)'
                                              : 'MENDEKATI JATUH TEMPO ($labelH)',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: bannerText,
                                          ),
                                        ),
                                      ),
                                      if (hpPemilik.isNotEmpty)
                                        GestureDetector(
                                          onTap: () async {
                                            final text = Uri.encodeComponent(
                                              'Halo Bapak/Ibu $nama,\n\n'
                                              'Menginfokan bahwa masa berlaku $layanan untuk kendaraan *${item['nomor_kendaraan']}* akan jatuh tempo pada *$masaAktifStr* ($sisaHari hari lagi).\n\n'
                                              'Segera perpanjang di CV. Kirana Tanjung Pelakar agar tetap aman. Terima kasih!',
                                            );
                                            final waUrl = Uri.parse(
                                                'https://wa.me/${hpPemilik.replaceAll(RegExp(r'\D'), '')}?text=$text');
                                            if (await canLaunchUrl(waUrl)) {
                                              await launchUrl(waUrl,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            }
                                          },
                                          child: const Icon(Icons.send_rounded,
                                              size: 16,
                                              color: Color(0xFF16A34A)),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              const Divider(
                                  height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Merk / Type: $merk',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: const Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text('Masa Aktif: $masaAktifStr',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: const Color(0xFF64748B))),
                                    ],
                                  ),
                                  IconButton(
                                    tooltip: 'Cetak Surat Kuasa',
                                    onPressed: () => onShowKuasa(item),
                                    icon: const Icon(Icons.description_outlined,
                                        color: Color(0xFF1769FF)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
