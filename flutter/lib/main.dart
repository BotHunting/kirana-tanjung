import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Required for compute()
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart'; // Added for efficient image loading
import 'package:url_launcher/url_launcher.dart';
import 'kuasa.dart';
import 'design.dart';
import 'percetakan.dart';
import 'dashboard.dart';

void main() => runApp(const KiranaTanjungApp());

class KiranaTanjungApp extends StatelessWidget {
  const KiranaTanjungApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1769FF),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE6EBF2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF1769FF), width: 2),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kirana Tanjung',
      theme: theme,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const apiUrl =
      'https://script.google.com/macros/s/AKfycbzwJz5NMOBnkuT_LaQD82845M7hoWA7EiuezNEWUQ35Hibn-WF2UXv2HCFyh5GvOh03/exec';
  static const blue = Color(0xFF1769FF);
  static const ink = Color(0xFF172033);

  final data = <String, List<dynamic>>{
    'desain': [],
    'percetakan': [],
    'biroJasa': [],
  };
  int selectedIndex = 0;
  bool loading = true;
  String? errorMessage;
  bool loggedIn = false;
  String? userName;
  String _webSearchQuery = '';
  String _searchCetakQuery = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final response = await http
          .get(Uri.parse('$apiUrl?action=getData'))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw Exception('Server mengembalikan status ${response.statusCode}.');
      }
      // Offload both parsing and normalization to the background isolate
      final processedData = await compute(_parseAndNormalize, response.body);
      if (!mounted) return;
      setState(() {
        data['desain'] = processedData['desain']!;
        data['percetakan'] = processedData['percetakan']!;
        data['biroJasa'] = processedData['biroJasa']!;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = 'Data belum dapat dimuat. Periksa koneksi internet.';
      });
    }
  }

  Future<void> openLogin() async {
    final result = await Navigator.of(context).push<LoginResult>(
      MaterialPageRoute(builder: (_) => const LoginPage(apiUrl: apiUrl)),
    );
    if (result == null || !mounted) return;
    setState(() {
      loggedIn = true;
      userName = result.name;
      selectedIndex = 4;
    });
    _showMessage('Selamat datang, ${result.name}');
  }

  Future<bool> _sendData(
      String action, String sheetName, Map<String, String> values,
      {int? rowIndex}) async {
    try {
      final parameters = <String, String>{
        'action': action,
        'sheetName': sheetName,
        ...values,
      };
      if (rowIndex != null) parameters['rowIndex'] = '$rowIndex';
      final response = await http
          .get(Uri.parse(apiUrl).replace(queryParameters: parameters))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw Exception('Server mengembalikan status ${response.statusCode}.');
      }
      final result = await compute(_parseJson, response.body);
      if (result['success'] == true) {
        await fetchData();
        _showMessage(result['message']?.toString() ?? 'Data diperbarui.');
        return true;
      }
      _showMessage(result['message']?.toString() ?? 'Data gagal diperbarui.');
    } catch (_) {
      _showMessage('Gagal memperbarui data. Periksa koneksi internet.');
    }
    return false;
  }

  Future<bool> updateData(
      String sheetName, int rowIndex, Map<String, String> values) {
    return _sendData('updateData', sheetName, values, rowIndex: rowIndex);
  }

  Future<bool> addData(String sheetName, Map<String, String> values) {
    return _sendData('addData', sheetName, values);
  }

  Future<bool> deleteData(String sheetName, int rowIndex) {
    return _sendData('deleteData', sheetName, {}, rowIndex: rowIndex);
  }

  void logout() {
    setState(() {
      loggedIn = false;
      userName = null;
      selectedIndex = 0;
    });
    _showMessage('Anda sudah keluar dari dashboard.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? _ErrorState(message: errorMessage!, onRetry: fetchData)
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildSelectedPage(),
                  ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: blue.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600);
        }),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda'),
          const NavigationDestination(
              icon: Icon(Icons.public_outlined),
              selectedIcon: Icon(Icons.language),
              label: 'Web Design'),
          const NavigationDestination(
              icon: Icon(Icons.print_outlined),
              selectedIcon: Icon(Icons.print),
              label: 'Percetakan'),
          const NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car),
              label: 'Biro Jasa'),
          if (loggedIn)
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F9FC),
      surfaceTintColor: Colors.transparent,
      titleSpacing: 20,
      title: GestureDetector(
        onTap: () => setState(() => selectedIndex = 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.hub_outlined, color: Colors.white, size: 21),
            ),
            const SizedBox(width: 10),
            Text('KIRANA',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, color: ink, fontSize: 16)),
            Text(' TANJUNG',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, color: blue, fontSize: 16)),
          ],
        ),
      ),
      actions: [
        IconButton(
            tooltip: 'Perbarui data',
            onPressed: loading ? null : fetchData,
            icon: const Icon(Icons.refresh_rounded)),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: IconButton.filledTonal(
            tooltip: loggedIn ? 'Keluar' : 'Login admin',
            onPressed: loggedIn ? logout : openLogin,
            icon: Icon(
                loggedIn ? Icons.logout_rounded : Icons.lock_outline_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedPage() {
    switch (selectedIndex) {
      case 1:
        return WebDesignView(
          items: data['desain']!.cast<Map<String, dynamic>>(),
          searchQuery: _webSearchQuery,
          onSearchChanged: (val) => setState(() => _webSearchQuery = val),
          catalogIconBuilder: (val) => CatalogIcon(value: val),
        );
      case 2:
        return PercetakanView(
          items: data['percetakan']!.cast<Map<String, dynamic>>(),
          searchQuery: _searchCetakQuery,
          onSearchChanged: (val) => setState(() => _searchCetakQuery = val),
          catalogIconBuilder: (val) => CatalogIcon(value: val),
          onChatPressed: (item) {
            final phone = appNormalisePhone(
                appValue(item, 'whatsapp', fallback: '6281290320438'));
            final desc = appValue(item, 'deskripsi', fallback: 'Produk cetak');
            appOpenWhatsApp(
                phone, 'Halo, saya tertarik dengan layanan percetakan: $desc');
          },
        );
      case 3:
        return _JasaPage(items: data['biroJasa']!);
      case 4:
        return AdminPage(
          name: userName ?? 'Admin',
          desain: data['desain']!,
          percetakan: data['percetakan']!,
          biroJasa: data['biroJasa']!,
          onEdit: (sheetName, item) => _showEditSheet(sheetName, item),
          onAdd: _showAddSheet,
          onDelete: _confirmDelete,
          onPrintKuasa: _showKuasaPreview,
        );
      default:
        return _HomePage(
          desain: data['desain']!,
          percetakan: data['percetakan']!,
          biroJasa: data['biroJasa']!,
          onNavigate: (index) => setState(() => selectedIndex = index),
          userName: userName,
        );
    }
  }

  Future<void> _showEditSheet(String sheetName, dynamic item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditDataSheet(
        sheetName: sheetName,
        item: item,
        isNew: false,
        onSave: (values) => updateData(
          sheetName,
          int.tryParse(appValue(item, 'row_index')) ?? 0,
          values,
        ),
      ),
    );
  }

  Future<void> _showAddSheet(String sheetName) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditDataSheet(
        sheetName: sheetName,
        item: const <String, String>{},
        isNew: true,
        onSave: (values) => addData(sheetName, values),
      ),
    );
  }

  Future<void> _confirmDelete(String sheetName, dynamic item) async {
    final title = sheetName == 'Biro Jasa'
        ? appValue(item, 'nomor_kendaraan', fallback: 'data ini')
        : appValue(item, sheetName == 'Desain' ? 'nama' : 'deskripsi',
            fallback: 'data ini');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text('Data "$title" akan dihapus permanen dari Spreadsheet.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await deleteData(sheetName, int.tryParse(appValue(item, 'row_index')) ?? 0);
    }
  }

  Future<void> _showKuasaPreview(dynamic item) async {
    final name = appValue(item, 'nama', fallback: '-');
    final number = appValue(item, 'nomor_kendaraan', fallback: '-');
    final vehicle =
        '${appValue(item, 'merek', fallback: '-')} / ${appValue(item, 'type', fallback: '-')}';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Surat Kuasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pratinjau data kendaraan',
                style: TextStyle(color: Color(0xFF8993A4), fontSize: 12)),
            const SizedBox(height: 16),
            InfoLine(label: 'Nama', value: name),
            InfoLine(label: 'Nomor Uji', value: number),
            InfoLine(label: 'Merk / Type', value: vehicle),
            InfoLine(
                label: 'Tanggal',
                value: appFormatDate(DateTime.now().toIso8601String())),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup')),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context); // Tutup modal ringkasan
              showDialog(
                context: context,
                builder: (context) =>
                    ModalKuasaViewer(item: item as Map<String, dynamic>),
              );
            },
            icon: const Icon(Icons.print_outlined),
            label: const Text('Buka untuk Cetak'),
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage(
      {required this.desain,
      required this.percetakan,
      required this.biroJasa,
      required this.onNavigate,
      this.userName});

  final List<dynamic> desain;
  final List<dynamic> percetakan;
  final List<dynamic> biroJasa;
  final ValueChanged<int> onNavigate;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        if (userName != null) _WelcomeBanner(name: userName!),
        _HeroPanel(onExplore: () => onNavigate(1)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
                child: StatTile(
                    value: '${desain.length}',
                    label: 'Project',
                    icon: Icons.language,
                    color: const Color(0xFF1769FF))),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    value: '${percetakan.length}',
                    label: 'Produk',
                    icon: Icons.print,
                    color: const Color(0xFF6556D9))),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    value: '${biroJasa.length}',
                    label: 'Berkas',
                    icon: Icons.directions_car,
                    color: const Color(0xFF0C9B77))),
          ],
        ),
        const SizedBox(height: 32),
        const _SectionHeading(
            eyebrow: 'KIRANA TANJUNG', title: 'Solusi untuk kebutuhan Anda'),
        const SizedBox(height: 14),
        _ServiceTile(
            icon: Icons.language,
            color: const Color(0xFF1769FF),
            title: 'Digital Solution',
            description: 'Sistem digital yang rapi untuk operasional bisnis.',
            onTap: () => onNavigate(1)),
        _ServiceTile(
            icon: Icons.print,
            color: const Color(0xFF6556D9),
            title: 'Percetakan',
            description: 'Kebutuhan cetak untuk identitas bisnis Anda.',
            onTap: () => onNavigate(2)),
        _ServiceTile(
            icon: Icons.description_outlined,
            color: const Color(0xFF0C9B77),
            title: 'Biro Jasa Kendaraan',
            description: 'Pengurusan KIR, SAMSAT, dan rekomendasi.',
            onTap: () => onNavigate(3)),
        const SizedBox(height: 22),
        const _SectionHeading(
            eyebrow: 'FEATURED SHOWCASE', title: 'Karya pilihan kami'),
        const SizedBox(height: 14),
        ...desain.take(3).map((item) => _ProjectCard(item: item)),
        if (desain.isEmpty)
          const EmptyState(message: 'Belum ada project yang ditampilkan.'),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF12213C), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1769FF).withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30)),
            child: Text('CV. KIRANA TANJUNG PELAKAR',
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF60A5FA),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2)),
          ),
          const SizedBox(height: 24),
          Text('Solusi digital & administrasi kendaraan.',
              style: GoogleFonts.plusJakartaSans(
                  letterSpacing: -0.5,
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
              'Transformasi bisnis, sistem, dan dokumen kendaraan dalam satu layanan.',
              style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFB8C3D6), fontSize: 12, height: 1.6)),
          const SizedBox(height: 22),
          FilledButton.icon(
              onPressed: onExplore,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Lihat layanan')),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text('Halo, $name',
          style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w800)));
}

class StatTile extends StatelessWidget {
  const StatTile(
      {super.key,
      required this.value,
      required this.label,
      required this.icon,
      required this.color});
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7EBF2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033))),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF8993A4),
                fontWeight: FontWeight.w600))
      ]));
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.eyebrow, required this.title});
  final String eyebrow;
  final String title;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow,
            style: const TextStyle(
                color: Color(0xFF1769FF),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8)),
        const SizedBox(height: 6),
        Text(title,
            style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 22,
                fontWeight: FontWeight.w800))
      ]);
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile(
      {required this.icon,
      required this.color,
      required this.title,
      required this.description,
      required this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE7EBF2))),
          child: Row(children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.05), blurRadius: 10)
                    ],
                    borderRadius: BorderRadius.circular(18)),
                child: Icon(icon, color: color)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: const Color(0xFF172033))),
                  const SizedBox(height: 4),
                  Text(description,
                      style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF8993A4), fontSize: 11))
                ])),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB4BDCA))
          ])));
}

class _JasaPage extends StatefulWidget {
  const _JasaPage({required this.items});
  final List<dynamic> items;
  @override
  State<_JasaPage> createState() => _JasaPageState();
}

class _JasaPageState extends State<_JasaPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) =>
            appSearches(item, query, ['nama', 'nomor_kendaraan', 'layanan']))
        .toList();
    return _PageFrame(
      key: const ValueKey('jasa'),
      eyebrow: 'STATUS LAYANAN',
      title: 'Biro Jasa Kendaraan',
      subtitle: 'Pantau proses KIR, SAMSAT, dan rekomendasi kendaraan.',
      searchHint: 'Cari nama atau nomor kendaraan',
      onSearch: (value) => setState(() => query = value),
      itemCount: filtered.isEmpty ? 1 : filtered.length, // Handle empty state
      itemBuilder: (context, index) {
        return filtered.isEmpty
            ? const EmptyState(message: 'Data layanan tidak ditemukan.')
            : _JasaCard(item: filtered[index]);
      },
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame(
      {super.key, // Changed to accept itemCount and itemBuilder
      required this.eyebrow,
      required this.title,
      required this.subtitle,
      required this.searchHint,
      required this.onSearch,
      required this.itemCount,
      required this.itemBuilder});
  final String eyebrow;
  final String title;
  final String subtitle;
  final String searchHint;
  final ValueChanged<String> onSearch;
  final int itemCount; // New
  final IndexedWidgetBuilder itemBuilder; // New

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Text(eyebrow,
                style: const TextStyle(
                    color: Color(0xFF1769FF),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 7)),
          SliverToBoxAdapter(
            child: Text(title,
                style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 27,
                    fontWeight: FontWeight.w800)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 7)),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          SliverToBoxAdapter(
            child: Text(subtitle,
                style: const TextStyle(
                    color: Color(0xFF8993A4), fontSize: 12, height: 1.5)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          SliverToBoxAdapter(
            child: TextField(
                onChanged: onSearch,
                decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search_rounded, size: 22),
                    contentPadding: const EdgeInsets.symmetric(vertical: 17))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final status = appValue(item, 'status', fallback: 'ON PROCESS');
    return _SurfaceCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const IconBadge(icon: Icons.language, color: Color(0xFF1769FF)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(appValue(item, 'nama', fallback: 'Project tanpa nama'),
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ),
        StatusChip(
            label: status,
            color: status.toUpperCase() == 'SELESAI'
                ? const Color(0xFF0C9B77)
                : const Color(0xFF1769FF)),
      ]),
      const SizedBox(height: 13),
      Text(appValue(item, 'deskripsi'),
          style: const TextStyle(
              color: Color(0xFF8993A4), fontSize: 11, height: 1.5)),
      if (appValue(item, 'tag').isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(appValue(item, 'tag'),
            style: const TextStyle(
                color: Color(0xFF1769FF),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
      ],
    ]));
  }
}

class CatalogIcon extends StatelessWidget {
  const CatalogIcon({
    super.key,
    required this.value,
    this.status,
    this.enableZoom = false,
    this.size = 52.0, // Parameter ukuran yang fleksibel
  });

  final String value;
  final String? status;
  final bool enableZoom;
  final double size;

  @override
  Widget build(BuildContext context) {
    // 1. Rewrite URL using helper for Google Drive optimization
    String url = _formatImageUrl(value);
    if (url.isEmpty) {
      return IconBadge(
          icon: Icons.help_outline, color: Colors.grey, size: size);
    }

    // 2. Fix protocol-relative URLs (e.g. //example.com)
    if (url.startsWith('//')) url = 'https:$url';

    // Browser-like headers to bypass User-Agent blocking from servers like WordPress
    const requestHeaders = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept':
          'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
    };

    // Broad detection for URLs, Data URIs, and common image/media extensions
    final isImage = RegExp(
      r'(^https?://)|' // Network protocols
      r'(^data:image/)|' // Base64 images
      r'(\.(png|jpe?g|gif|webp|bmp|svg|webm|heic|avif)(\?.*)?$)', // Common extensions with optional query params
      caseSensitive: false,
    ).hasMatch(url);

    Color borderColor = Colors.transparent;
    if (status != null) {
      final s = status!.toUpperCase();
      if (s == 'SELESAI' || s == 'AKTIF') {
        borderColor = const Color(0xFF0C9B77);
      }
      if (s == 'ON PROCESS') {
        borderColor = const Color(0xFF1769FF);
      }
      if (s == 'DITOLAK' || s == 'DIARSIPKAN') {
        borderColor = const Color(0xFFE5484D);
      }
    }

    Widget content;
    if (isImage && url.startsWith('http')) {
      // Bypass CachedNetworkImage on Web to avoid CORS XHR blocks
      if (kIsWeb) {
        content = GestureDetector(
          onTap: enableZoom ? () => _showZoomDialog(context, url) : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              headers: requestHeaders,
              errorBuilder: (context, error, stackTrace) => IconBadge(
                  icon: Icons.broken_image_outlined,
                  color: const Color(0xFF6556D9),
                  size: size * 0.4),
            ),
          ),
        );
      } else {
        content = GestureDetector(
          onTap: enableZoom ? () => _showZoomDialog(context, url) : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              memCacheWidth: (size * 3).toInt(), // Optimasi memori dinamis
              httpHeaders: requestHeaders,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              errorWidget: (context, url, error) => IconBadge(
                  icon: Icons.broken_image_outlined,
                  color: const Color(0xFF6556D9),
                  size: size),
            ),
          ),
        );
      }
    } else {
      final iconName = url.toLowerCase().replaceFirst(RegExp(r'^fa-'), '');
      content = _IconBadge(
          icon: _fontAwesomeIcon(iconName),
          color: const Color(0xFF6556D9),
          size: size);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      padding: const EdgeInsets.all(2),
      child: content,
    );
  }

  void _showZoomDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              clipBehavior: Clip.none,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            IconButton.filled(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

/// Utility to convert Google Drive URLs to reliable thumbnail endpoints
String _formatImageUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';
  final regExp = RegExp(r'(?:id=|\/d\/|\/file\/d\/)([\w-]+)');
  final match = regExp.firstMatch(trimmed);
  if (match != null) {
    // Using sz=w500 for optimized quality and bypass CORS/Direct load issues
    return 'https://drive.google.com/thumbnail?id=${match.group(1)}&sz=w500';
  }
  return trimmed;
}

IconData _fontAwesomeIcon(String value) {
  switch (value) {
    case 'print':
      return Icons.print;
    case 'image':
      return Icons.image_outlined;
    case 'tag':
      return Icons.sell_outlined;
    case 'file-pdf':
      return Icons.picture_as_pdf_outlined;
    case 'id-card':
      return Icons.badge_outlined;
    case 'book':
      return Icons.menu_book_outlined;
    case 'camera':
      return Icons.camera_alt_outlined;
    case 'shopping-cart':
      return Icons.shopping_cart_outlined;
    case 'star':
      return Icons.star_border_rounded;
    case 'heart':
      return Icons.favorite_border_rounded;
    case 'user':
      return Icons.person_outline_rounded;
    case 'envelope':
      return Icons.mail_outline_rounded;
    case 'map-marker':
      return Icons.location_on_outlined;
    default:
      return Icons.local_offer_outlined;
  }
}

class _JasaCard extends StatelessWidget {
  const _JasaCard({required this.item});
  final dynamic item;
  @override
  Widget build(BuildContext context) {
    final vehicle = appValue(item, 'nomor_kendaraan');
    final status =
        _serviceStatus(appValue(item, 'aktif'), appValue(item, 'durasi'));
    return _SurfaceCard(
        child: Row(children: [
      const IconBadge(icon: Icons.directions_car, color: Color(0xFF0C9B77)),
      const SizedBox(width: 12),
      Expanded(
          child: Text(
              '${appValue(item, 'layanan', fallback: 'LAYANAN')}  •  ${_mask(vehicle)}',
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
      StatusChip(label: status.label, color: status.color)
    ]));
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE7EBF2))),
      child: child);
}

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.size = 42.0});
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(size * 0.33)),
      child: Icon(icon, color: color, size: size * 0.48));
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w800)));
}

class InfoLine extends StatelessWidget {
  const InfoLine({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 72,
            child: Text(label,
                style:
                    const TextStyle(color: Color(0xFF99A2B1), fontSize: 10))),
        Expanded(
            child: Text(value.isEmpty ? '-' : value,
                style: const TextStyle(
                    color: Color(0xFF495466),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)))
      ]));
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Center(
          child: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8993A4), fontSize: 12))));
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded,
                size: 42, color: Color(0xFF8993A4)),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF667085))),
            const SizedBox(height: 18),
            OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'))
          ])));
}

class LoginResult {
  const LoginResult({required this.name});
  final String name;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.apiUrl});
  final String apiUrl;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool submitting = false;
  String? error;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      setState(() => error = 'Username dan password wajib diisi.');
      return;
    }
    setState(() {
      submitting = true;
      error = null;
    });
    try {
      final loginUri = Uri.parse(widget.apiUrl).replace(queryParameters: {
        'action': 'login',
        'username': usernameController.text.trim(),
        'password': passwordController.text,
      });
      final response =
          await http.get(loginUri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw Exception('Server mengembalikan status ${response.statusCode}.');
      }
      final result = await compute(_parseJson, response.body);
      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.pop(
            context,
            LoginResult(
                name: (result['nama'] ?? usernameController.text).toString()));
      } else {
        setState(() {
          submitting = false;
          error = (result['message'] ?? 'Login ditolak.').toString();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          submitting = false;
          error = 'Login gagal. Periksa koneksi internet.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Login Admin')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 30),
        Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.lock_outline_rounded,
                color: Color(0xFF1769FF), size: 30)),
        const SizedBox(height: 22),
        const Text('Portal Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Kelola data project, percetakan, dan biro jasa.',
            style: TextStyle(color: Color(0xFF8993A4), fontSize: 13)),
        const SizedBox(height: 30),
        TextField(
            controller: usernameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
                labelText: 'Username', prefixIcon: Icon(Icons.person_outline_rounded))),
        const SizedBox(height: 14),
        TextField(
            controller: passwordController,
            obscureText: true,
            onSubmitted: (_) => submit(),
            decoration: const InputDecoration(
                labelText: 'Password', prefixIcon: Icon(Icons.key_outlined))),
        if (error != null)
          Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12))),
        const SizedBox(height: 22),
        FilledButton(
            onPressed: submitting ? null : submit,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Masuk ke Dashboard')))
      ]));
}

bool appSearches(dynamic item, String query, List<String> keys) {
  if (query.trim().isEmpty) return true;
  final text = keys.map((key) => appValue(item, key)).join(' ').toLowerCase();
  return text.contains(query.trim().toLowerCase());
}

String appValue(dynamic item, String key, {String fallback = ''}) {
  if (item is Map &&
      item[key] != null &&
      item[key].toString().trim().isNotEmpty) {
    return item[key].toString();
  }
  return fallback;
}

List<dynamic> _normaliseRows(dynamic rawRows, List<String> fields) {
  if (rawRows is! List) return <dynamic>[];
  return rawRows.whereType<Map>().map((row) {
    return <String, dynamic>{
      'row_index': row['row_index']?.toString() ?? '',
      for (final field in fields) field: row[field]?.toString() ?? '',
    };
  }).toList();
}

String _mask(String value) {
  if (value.length < 4) return value.isEmpty ? '-' : value;
  return '${value.substring(0, 2)}***${value.substring(value.length - 1)}';
}

String appFormatDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String appNormalisePhone(String value) {
  var phone = value.replaceAll(RegExp(r'\D'), '');
  if (phone.startsWith('0')) phone = '62${phone.substring(1)}';
  if (phone.startsWith('8')) phone = '62$phone';
  return phone;
}

Future<void> appOpenWhatsApp(String phone, String message) async {
  if (phone.isEmpty) return;
  final uri =
      Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> appOpenUrl(String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

({String label, Color color}) _serviceStatus(String expiry, String progress) {
  final date = DateTime.tryParse(expiry);
  if (date == null) {
    return (
      label: progress.isEmpty ? '-' : progress,
      color: const Color(0xFF1769FF)
    );
  }
  final days = date.difference(DateTime.now()).inDays;
  if (days < 0) return (label: 'EXPIRED', color: const Color(0xFFE5484D));
  if (days <= 30) return (label: 'H-$days', color: const Color(0xFFE59B20));
  return (label: 'AKTIF', color: const Color(0xFF0C9B77));
}

/// Top-level function for background JSON parsing using Isolates via compute()
Map<String, dynamic> _parseJson(String text) {
  return jsonDecode(text) as Map<String, dynamic>;
}

/// Comprehensive isolate processing: decodes AND normalizes to keep UI thread idle
Map<String, List<dynamic>> _parseAndNormalize(String text) {
  final decoded = jsonDecode(text) as Map<String, dynamic>;
  return {
    'desain': _normaliseRows(decoded['desain'], const [
      'timestamp',
      'nama',
      'deskripsi',
      'linkgambar',
      'tag',
      'whatsapp',
      'status',
    ]),
    'percetakan': _normaliseRows(decoded['percetakan'], const [
      'timestamp',
      'deskripsi',
      'harga',
      'ikon',
      'whatsapp',
      'status',
    ]),
    'biroJasa': _normaliseRows(decoded['biroJasa'], const [
      'timestamp',
      'layanan',
      'nama',
      'merek',
      'type',
      'nomor_kendaraan',
      'deskripsi',
      'durasi',
      'whatsapp',
      'aktif',
      'foto_stnk',
    ]),
  };
}
