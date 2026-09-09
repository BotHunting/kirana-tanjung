import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE6EBF2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1769FF), width: 1.5),
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
      'https://script.google.com/macros/s/AKfycbwfvy96z3RLxI3fcFZZP0OGe9H7dtbQP7dUc-B_jdXJgzXYRPuOSzJRTnBkXgrCDMIn/exec';
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
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        data['desain'] = List<dynamic>.from(decoded['desain'] ?? []);
        data['percetakan'] = List<dynamic>.from(decoded['percetakan'] ?? []);
        data['biroJasa'] = List<dynamic>.from(decoded['biroJasa'] ?? []);
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
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.plusJakartaSans(
              fontSize: 10, fontWeight: FontWeight.w700),
        ),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda'),
          const NavigationDestination(
              icon: Icon(Icons.language_outlined),
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
        return _WebPage(items: data['desain']!);
      case 2:
        return _PrintPage(items: data['percetakan']!);
      case 3:
        return _JasaPage(items: data['biroJasa']!);
      case 4:
        return _AdminPage(
          name: userName ?? 'Admin',
          desain: data['desain']!,
          percetakan: data['percetakan']!,
          biroJasa: data['biroJasa']!,
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
                child: _StatTile(
                    value: '${desain.length}',
                    label: 'Project',
                    icon: Icons.language,
                    color: const Color(0xFF1769FF))),
            const SizedBox(width: 10),
            Expanded(
                child: _StatTile(
                    value: '${percetakan.length}',
                    label: 'Produk',
                    icon: Icons.print,
                    color: const Color(0xFF6556D9))),
            const SizedBox(width: 10),
            Expanded(
                child: _StatTile(
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
            title: 'Web Design & System',
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
          const _EmptyState(message: 'Belum ada project yang ditampilkan.'),
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
        color: const Color(0xFF12213C),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
              color: Color(0x2412213C), blurRadius: 24, offset: Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30)),
            child: Text('CV. KIRANA TANJUNG PELAKAR',
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF9DBDFF),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2)),
          ),
          const SizedBox(height: 20),
          Text('Solusi digital & administrasi kendaraan.',
              style: GoogleFonts.plusJakartaSans(
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
              fontWeight: FontWeight.w700)));
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.value,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE7EBF2))),
          child: Row(children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15)),
                child: Icon(icon, color: color)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          color: Color(0xFF8993A4), fontSize: 11))
                ])),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB4BDCA))
          ])));
}

class _WebPage extends StatefulWidget {
  const _WebPage({required this.items});
  final List<dynamic> items;
  @override
  State<_WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<_WebPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) => _searches(item, query, ['nama', 'tag', 'deskripsi']))
        .toList();
    return _PageFrame(
        key: const ValueKey('web'),
        eyebrow: 'PORTFOLIO',
        title: 'Web Design & System',
        subtitle: 'Status project dan solusi digital yang kami kerjakan.',
        searchHint: 'Cari project atau deskripsi',
        onSearch: (value) => setState(() => query = value),
        child: filtered.isEmpty
            ? const _EmptyState(message: 'Project tidak ditemukan.')
            : Column(
                children:
                    filtered.map((item) => _ProjectCard(item: item)).toList()));
  }
}

class _PrintPage extends StatefulWidget {
  const _PrintPage({required this.items});
  final List<dynamic> items;
  @override
  State<_PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<_PrintPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) =>
            _value(item, 'status').toUpperCase() != 'DITOLAK' &&
            _searches(item, query, ['deskripsi', 'harga']))
        .toList();
    return _PageFrame(
        key: const ValueKey('print'),
        eyebrow: 'KATALOG LAYANAN',
        title: 'Percetakan',
        subtitle: 'Produk cetak untuk kebutuhan bisnis dan identitas Anda.',
        searchHint: 'Cari produk percetakan',
        onSearch: (value) => setState(() => query = value),
        child: filtered.isEmpty
            ? const _EmptyState(message: 'Produk tidak ditemukan.')
            : Column(
                children:
                    filtered.map((item) => _PrintCard(item: item)).toList()));
  }
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
        .where((item) => _searches(item, query,
            ['nama', 'nama_pemilik', 'nomor_kendaraan', 'no_uji', 'layanan']))
        .toList();
    return _PageFrame(
        key: const ValueKey('jasa'),
        eyebrow: 'STATUS LAYANAN',
        title: 'Biro Jasa Kendaraan',
        subtitle: 'Pantau proses KIR, SAMSAT, dan rekomendasi kendaraan.',
        searchHint: 'Cari nama atau nomor kendaraan',
        onSearch: (value) => setState(() => query = value),
        child: filtered.isEmpty
            ? const _EmptyState(message: 'Data layanan tidak ditemukan.')
            : Column(
                children: filtered
                    .map((item) => _JasaCard(
                        item: item, reveal: _matchesVehicle(item, query)))
                    .toList()));
  }
}

class _AdminPage extends StatelessWidget {
  const _AdminPage({
    required this.name,
    required this.desain,
    required this.percetakan,
    required this.biroJasa,
  });

  final String name;
  final List<dynamic> desain;
  final List<dynamic> percetakan;
  final List<dynamic> biroJasa;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ListView(
        key: const ValueKey('admin'),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        children: [
          Text('DASHBOARD ADMIN',
              style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF1769FF),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8)),
          const SizedBox(height: 7),
          Text('Halo, $name',
              style: const TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 27,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          const Text('Database Explorer',
              style: TextStyle(color: Color(0xFF8993A4), fontSize: 12)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: _StatTile(
                    value: '${desain.length}',
                    label: 'Desain',
                    icon: Icons.language,
                    color: const Color(0xFF1769FF))),
            const SizedBox(width: 10),
            Expanded(
                child: _StatTile(
                    value: '${percetakan.length}',
                    label: 'Cetak',
                    icon: Icons.print,
                    color: const Color(0xFF6556D9))),
            const SizedBox(width: 10),
            Expanded(
                child: _StatTile(
                    value: '${biroJasa.length}',
                    label: 'Jasa',
                    icon: Icons.directions_car,
                    color: const Color(0xFF0C9B77))),
          ]),
          const SizedBox(height: 26),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7EBF2))),
            child: const TabBar(tabs: [
              Tab(text: 'Desain'),
              Tab(text: 'Cetak'),
              Tab(text: 'Jasa')
            ]),
          ),
          SizedBox(
            height: 360,
            child: TabBarView(children: [
              _AdminDataList(
                  items: desain, titleKey: 'nama', statusKey: 'status'),
              _AdminDataList(
                  items: percetakan,
                  titleKey: 'deskripsi',
                  statusKey: 'status'),
              _AdminDataList(
                  items: biroJasa, titleKey: 'no_uji', statusKey: 'durasi'),
            ]),
          ),
        ],
      ),
    );
  }
}

class _AdminDataList extends StatelessWidget {
  const _AdminDataList(
      {required this.items, required this.titleKey, required this.statusKey});
  final List<dynamic> items;
  final String titleKey;
  final String statusKey;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState(message: 'Belum ada data.');
    return ListView.separated(
      padding: const EdgeInsets.only(top: 14),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7EBF2))),
          child: Row(children: [
            Expanded(
                child: Text(
                    titleKey == 'no_uji'
                        ? _jasaValue(item, 'nomor_kendaraan',
                            fallback: 'Tanpa nomor')
                        : _value(item, titleKey, fallback: 'Tanpa nama'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800))),
            _StatusChip(
                label: statusKey == 'durasi'
                    ? _jasaValue(item, 'durasi', fallback: 'ON PROCESS')
                    : _value(item, statusKey, fallback: 'ON PROCESS'),
                color: const Color(0xFF1769FF)),
          ]),
        );
      },
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame(
      {super.key,
      required this.eyebrow,
      required this.title,
      required this.subtitle,
      required this.searchHint,
      required this.onSearch,
      required this.child});
  final String eyebrow;
  final String title;
  final String subtitle;
  final String searchHint;
  final ValueChanged<String> onSearch;
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 30), children: [
        Text(eyebrow,
            style: const TextStyle(
                color: Color(0xFF1769FF),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8)),
        const SizedBox(height: 7),
        Text(title,
            style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 27,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        Text(subtitle,
            style: const TextStyle(
                color: Color(0xFF8993A4), fontSize: 12, height: 1.5)),
        const SizedBox(height: 20),
        TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(vertical: 17))),
        const SizedBox(height: 18),
        child
      ]);
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.item});
  final dynamic item;
  @override
  Widget build(BuildContext context) {
    final status = _value(item, 'status', fallback: 'ON PROCESS');
    return _SurfaceCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const _IconBadge(icon: Icons.language, color: Color(0xFF1769FF)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(_value(item, 'nama', fallback: 'Project tanpa nama'),
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14))),
        _StatusChip(
            label: status,
            color: status.toUpperCase() == 'SELESAI'
                ? const Color(0xFF0C9B77)
                : const Color(0xFF1769FF))
      ]),
      const SizedBox(height: 13),
      Text(_value(item, 'deskripsi'),
          style: const TextStyle(
              color: Color(0xFF8993A4), fontSize: 11, height: 1.5)),
      if (_value(item, 'tag').isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(_value(item, 'tag'),
            style: const TextStyle(
                color: Color(0xFF1769FF),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1))
      ]
    ]));
  }
}

class _PrintCard extends StatelessWidget {
  const _PrintCard({required this.item});
  final dynamic item;
  @override
  Widget build(BuildContext context) {
    final phone =
        _normalisePhone(_value(item, 'whatsapp', fallback: '6281290320438'));
    return _SurfaceCard(
        child: Row(children: [
      const _IconBadge(icon: Icons.print, color: Color(0xFF6556D9)),
      const SizedBox(width: 13),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_value(item, 'deskripsi', fallback: 'Produk cetak'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        Text(_formatPrice(_value(item, 'harga')),
            style: const TextStyle(
                color: Color(0xFF6556D9),
                fontWeight: FontWeight.w800,
                fontSize: 14))
      ])),
      IconButton.filled(
          onPressed: () => _openWhatsApp(phone,
              'Halo, saya tertarik dengan layanan percetakan: ${_value(item, 'deskripsi')}'),
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18))
    ]));
  }
}

class _JasaCard extends StatelessWidget {
  const _JasaCard({required this.item, required this.reveal});
  final dynamic item;
  final bool reveal;
  @override
  Widget build(BuildContext context) {
    final expiry = _jasaValue(item, 'aktif');
    final status = _serviceStatus(expiry, _jasaValue(item, 'durasi'));
    final phone = _normalisePhone(_firstValue(
        item, ['whatsapp', 'no_whatsapp', 'wa'],
        fallback: '6281290320438'));
    final name = _jasaValue(item, 'nama');
    final vehicle = _jasaValue(item, 'nomor_kendaraan');
    return _SurfaceCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const _IconBadge(icon: Icons.directions_car, color: Color(0xFF0C9B77)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(
                '${_jasaValue(item, 'layanan', fallback: 'LAYANAN')}  •  ${reveal ? vehicle : _mask(vehicle)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13))),
        _StatusChip(label: status.label, color: status.color)
      ]),
      const SizedBox(height: 15),
      _InfoLine(label: 'Pemilik', value: reveal ? name : _mask(name)),
      _InfoLine(
          label: 'Kendaraan',
          value: '${_jasaValue(item, 'merek')} / ${_jasaValue(item, 'type')}'),
      _InfoLine(
          label: 'Proses',
          value: _jasaValue(item, 'durasi', fallback: 'ON PROCESS')),
      if (expiry.isNotEmpty)
        _InfoLine(label: 'Masa aktif', value: _formatDate(expiry)),
      const SizedBox(height: 12),
      Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
              onPressed: () => _openWhatsApp(phone,
                  'Halo, saya ingin bertanya mengenai status layanan ${_jasaValue(item, 'layanan')} untuk kendaraan $vehicle atas nama $name.'),
              icon: const Icon(Icons.chat_outlined, size: 16),
              label: const Text('Tanya via WhatsApp')))
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

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: color, size: 20));
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
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

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
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
      final response = await http
          .post(Uri.parse(widget.apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'action': 'login',
                'username': usernameController.text.trim(),
                'password': passwordController.text
              }))
          .timeout(const Duration(seconds: 20));
      final result = jsonDecode(response.body) as Map<String, dynamic>;
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
                labelText: 'Username', prefixIcon: Icon(Icons.person_outline))),
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

bool _searches(dynamic item, String query, List<String> keys) {
  if (query.trim().isEmpty) return true;
  final text = keys.map((key) => _value(item, key)).join(' ').toLowerCase();
  return text.contains(query.trim().toLowerCase());
}

String _value(dynamic item, String key, {String fallback = ''}) {
  if (item is Map &&
      item[key] != null &&
      item[key].toString().trim().isNotEmpty) {
    return item[key].toString();
  }
  return fallback;
}

String _firstValue(dynamic item, List<String> keys, {String fallback = ''}) {
  for (final key in keys) {
    final value = _value(item, key);
    if (value.isNotEmpty) return value;
  }
  return fallback;
}

String _jasaValue(dynamic item, String key, {String fallback = ''}) {
  final aliases = <String, List<String>>{
    'nama': ['nama', 'nama_pemilik', 'nama_konsumen'],
    'nomor_kendaraan': ['nomor_kendaraan', 'no_uji', 'nomor_uji'],
    'layanan': ['layanan', 'jenis_layanan'],
    'merek': ['merek', 'merk'],
    'type': ['type', 'tipe'],
    'durasi': ['durasi', 'status', 'progres'],
    'aktif': ['aktif', 'masa_aktif', 'tanggal_aktif', 'tgl_aktif'],
  };
  return _firstValue(item, aliases[key] ?? [key], fallback: fallback);
}

bool _matchesVehicle(dynamic item, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  return normalizedQuery.isNotEmpty &&
      normalizedQuery == _jasaValue(item, 'nomor_kendaraan').toLowerCase();
}

String _mask(String value) {
  if (value.length < 4) return value.isEmpty ? '-' : value;
  return '${value.substring(0, 2)}***${value.substring(value.length - 1)}';
}

String _formatPrice(String value) {
  if (value.isEmpty) return '-';
  final number = int.tryParse(value.replaceAll(RegExp(r'\D'), ''));
  return number == null || number == 0
      ? value
      : 'Rp ${NumberFormat('#,###', 'id_ID').format(number)}';
}

String _formatDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? value : DateFormat('dd MMM yyyy', 'id_ID').format(date);
}

String _normalisePhone(String value) {
  var phone = value.replaceAll(RegExp(r'\D'), '');
  if (phone.startsWith('0')) phone = '62${phone.substring(1)}';
  if (phone.startsWith('8')) phone = '62$phone';
  return phone;
}

Future<void> _openWhatsApp(String phone, String message) async {
  if (phone.isEmpty) return;
  final uri =
      Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
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
