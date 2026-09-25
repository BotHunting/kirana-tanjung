import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';

class KonveksiView extends StatefulWidget {
  const KonveksiView({super.key});

  @override
  State<KonveksiView> createState() => _KonveksiViewState();
}

class _KonveksiViewState extends State<KonveksiView> {
  List<dynamic> _katalogKonveksi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBoutiqueData();
  }

  Future<void> _fetchBoutiqueData() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.databaseUrl}?action=Boutique'));
      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (resData['status'] == 'success') {
          setState(() {
            _katalogKonveksi = resData['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _kirimPesanWA(Map<String, dynamic> item) async {
    final text = Uri.encodeComponent(
      'Halo Kak, saya ingin konsultasi order Konveksi/Boutique:\n\n'
      '• *Produk*: ${item['judul']}\n'
      '• *Kategori*: ${item['kategori']}\n'
      '• *Harga*: ${item['harga']}\n\n'
      'Bisa info detail bahan dan alur pemesanannya?',
    );
    final waUrl = Uri.parse('https://wa.me/6281290320438?text=$text');
    if (await canLaunchUrl(waUrl)) {
      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_katalogKonveksi.isEmpty) {
      return Center(
        child: Text('Belum ada data produk Boutique & Konveksi',
            style: GoogleFonts.plusJakartaSans()),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBoutiqueData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _katalogKonveksi.length,
        itemBuilder: (context, index) {
          final item = _katalogKonveksi[index];
          final isBoutique = (item['kategori'] ?? '')
              .toString()
              .toLowerCase()
              .contains('boutique');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isBoutique
                            ? const Color(0xFFFCE7F3)
                            : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['kategori'] ?? 'Konveksi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isBoutique
                              ? const Color(0xFFBE185D)
                              : const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item['min_order'] != null)
                      Text(
                        'Min: ${item['min_order']}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 10, color: const Color(0xFF64748B)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['judul'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  item['deskripsi'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['harga'] ?? '',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1769FF),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon:
                          const Icon(Icons.chat, size: 14, color: Colors.white),
                      label: Text(
                        'Konsultasi WA',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _kirimPesanWA(item),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
