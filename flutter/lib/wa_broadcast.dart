import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';
import 'main.dart' show appValue, appNormalisePhone;

class WABroadcastPage extends StatefulWidget {
  const WABroadcastPage({
    super.key,
    required this.biroJasa,
    required this.username,
  });

  final List<dynamic> biroJasa;
  final String username;

  @override
  State<WABroadcastPage> createState() => _WABroadcastPageState();
}

class _WABroadcastPageState extends State<WABroadcastPage> {
  String _selectedFilter = 'H-30';
  final _messageController = TextEditingController(
    text:
        'Halo {nama},\n\nMenginfokan bahwa masa berlaku {layanan} untuk kendaraan *{no_kendaraan}* akan jatuh tempo pada *{masa_aktif}*.\n\nSegera perpanjang di Natala Studio (by Kirana Tanjung) agar tetap aman. Terima kasih!',
  );
  bool _sending = false;
  int _sentCount = 0;
  int _failedCount = 0;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredItems {
    switch (_selectedFilter) {
      case 'Expired':
        return widget.biroJasa.where((item) {
          final expiry = AppConfig.getSisaHari(appValue(item, 'aktif'));
          return expiry.isValid && expiry.isExpired;
        }).toList();
      case 'H-7':
        return widget.biroJasa.where((item) {
          final expiry = AppConfig.getSisaHari(appValue(item, 'aktif'));
          return expiry.isValid && expiry.sisa <= 7 && expiry.sisa > 0;
        }).toList();
      case 'H-30':
        return widget.biroJasa.where((item) {
          final expiry = AppConfig.getSisaHari(appValue(item, 'aktif'));
          return expiry.isValid && expiry.sisa <= 30 && expiry.sisa > 7;
        }).toList();
      case 'No Date':
        return widget.biroJasa.where((item) {
          final aktif = appValue(item, 'aktif', fallback: '');
          return aktif.isEmpty;
        }).toList();
      default:
        return widget.biroJasa;
    }
  }

  String _formatMessage(dynamic item) {
    final message = _messageController.text;
    return message
        .replaceAll('{nama}', appValue(item, 'nama', fallback: '-'))
        .replaceAll('{no_kendaraan}',
            appValue(item, 'nomor_kendaraan', fallback: '-'))
        .replaceAll('{merek}', appValue(item, 'merek', fallback: '-'))
        .replaceAll('{type}', appValue(item, 'type', fallback: '-'))
        .replaceAll('{layanan}', appValue(item, 'layanan', fallback: '-'))
        .replaceAll('{masa_aktif}', appValue(item, 'aktif', fallback: '-'));
  }

  Future<void> _sendBroadcast() async {
    final items = _filteredItems;
    if (items.isEmpty) {
      _showMessage('Tidak ada data untuk dikirim.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Color(0xFFF59E0B)),
            const SizedBox(width: 12),
            Text('Konfirmasi Broadcast',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Text(
          'Anda akan mengirim ${items.length} pesan WhatsApp.\n\nLanjutkan?',
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
            child: Text('Kirim',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _sending = true;
      _sentCount = 0;
      _failedCount = 0;
    });

    // Rate limit: max 50 messages per batch
    const batchSize = 50;
    final batches = (items.length / batchSize).ceil();

    for (int i = 0; i < batches; i++) {
      final start = i * batchSize;
      final end = (i + 1) * batchSize < items.length
          ? (i + 1) * batchSize
          : items.length;
      final batch = items.sublist(start, end);

      for (final item in batch) {
        try {
          final phone = appNormalisePhone(appValue(item, 'whatsapp'));
          if (phone.isEmpty) {
            _failedCount++;
            continue;
          }

          final message = _formatMessage(item);
          final uri = Uri.parse(
              'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

          final canLaunch = await canLaunchUrl(uri);
          if (canLaunch) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            _sentCount++;
            // Rate limit: tunggu 1 detik antar pesan
            await Future.delayed(const Duration(seconds: 1));
          } else {
            _failedCount++;
          }
        } catch (_) {
          _failedCount++;
        }
      }

      // Rate limit: tunggu 2 detik antar batch
      if (i < batches - 1) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    setState(() {
      _sending = false;
    });

    if (mounted) {
      _showMessage(
          'Broadcast selesai: $_sentCount terkirim, $_failedCount gagal.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

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
                    'WA BROADCAST',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1769FF),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kirim Pengingat Massal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kirim notifikasi WhatsApp untuk pengingat masa aktif STNK.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 20),
                  _buildMessageTemplate(),
                  const SizedBox(height: 20),
                  _buildRecipientList(filteredItems),
                  const SizedBox(height: 20),
                  _buildSendButton(filteredItems),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Penerima',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Expired',
                value: 'Expired',
                selected: _selectedFilter == 'Expired',
                color: const Color(0xFFE5484D),
                onTap: () => setState(() => _selectedFilter = 'Expired'),
              ),
              _FilterChip(
                label: 'H-7 (Kritis)',
                value: 'H-7',
                selected: _selectedFilter == 'H-7',
                color: const Color(0xFFF59E0B),
                onTap: () => setState(() => _selectedFilter = 'H-7'),
              ),
              _FilterChip(
                label: 'H-30 (Warning)',
                value: 'H-30',
                selected: _selectedFilter == 'H-30',
                color: const Color(0xFF16A34A),
                onTap: () => setState(() => _selectedFilter = 'H-30'),
              ),
              _FilterChip(
                label: 'No Date',
                value: 'No Date',
                selected: _selectedFilter == 'No Date',
                color: const Color(0xFF64748B),
                onTap: () => setState(() => _selectedFilter = 'No Date'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTemplate() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Template Pesan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Variabel tersedia: {nama}, {no_kendaraan}, {merek}, {type}, {layanan}, {masa_aktif}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Masukkan template pesan...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1769FF), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientList(List<dynamic> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Penerima (${items.length})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (_sending)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Tidak ada penerima untuk filter ini.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            ...items.take(10).map((item) => _RecipientCard(item: item)),
          if (items.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '... dan ${items.length - 10} lainnya',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSendButton(List<dynamic> items) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: items.isEmpty || _sending ? null : _sendBroadcast,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF16A34A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: _sending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded),
        label: Text(
          _sending ? 'Mengirim...' : 'Kirim Broadcast',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final nama = appValue(item, 'nama', fallback: '-');
    final noKendaraan = appValue(item, 'nomor_kendaraan', fallback: '-');
    final layanan = appValue(item, 'layanan', fallback: '-');
    final masaAktif = appValue(item, 'aktif', fallback: '-');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Color(0xFF64748B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '$layanan • $noKendaraan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            masaAktif,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFF1769FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
