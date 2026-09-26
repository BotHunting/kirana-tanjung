import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config.dart';

class WebDesignView extends StatelessWidget {
  const WebDesignView({
    super.key,
    required this.items,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.catalogIconBuilder,
  });

  final List<Map<String, dynamic>> items;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final Widget Function(String value) catalogIconBuilder;

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) {
      final title =
          (item['judul'] ?? item['nama'] ?? '').toString().toLowerCase();
      final desc = (item['deskripsi'] ?? '').toString().toLowerCase();
      final q = searchQuery.toLowerCase().trim();
      return title.contains(q) || desc.contains(q);
    }).toList();

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
                    'KATALOG LAYANAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1769FF),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Web Design & System',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solusi pembuatan website dan aplikasi terpadu.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari layanan web design...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: _buildCustomOutlineBorder(),
                      enabledBorder: _buildCustomOutlineBorder(),
                      focusedBorder: _buildCustomOutlineBorder(isActive: true),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada data ditemukan',
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
                        final title =
                            (item['judul'] ?? item['nama'] ?? 'Tanpa Nama')
                                .toString();
                        final desc = (item['deskripsi'] ?? '-').toString();
                        final harga = (item['harga'] ?? '-').toString();
                        final iconValue =
                            (item['linkgambar'] ?? item['ikon'] ?? '')
                                .toString();

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x05000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: catalogIconBuilder(iconValue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      desc,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppConfig.formatCurrency(harga),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1769FF),
                                      ),
                                    ),
                                  ],
                                ),
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

  OutlineInputBorder _buildCustomOutlineBorder({bool isActive = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(
        color: isActive ? const Color(0xFF1769FF) : const Color(0xFFE2E8F0),
        width: isActive ? 1.6 : 1.0,
      ),
    );
  }
}
