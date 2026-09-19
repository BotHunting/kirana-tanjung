import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({
    super.key,
    required this.name,
    required this.desain,
    required this.percetakan,
    required this.biroJasa,
    required this.currentVersion,
    required this.latestVersion,
    required this.changelog,
    required this.updateUrl,
    required this.onEdit,
    required this.onAdd,
    required this.onDelete,
    required this.onPrintKuasa,
  });

  final String name;
  final List<dynamic> desain;
  final List<dynamic> percetakan;
  final List<dynamic> biroJasa;
  final String currentVersion;
  final String? latestVersion;
  final String? changelog;
  final String? updateUrl;
  final void Function(String sheetName, dynamic item) onEdit;
  final void Function(String sheetName) onAdd;
  final void Function(String sheetName, dynamic item) onDelete;
  final void Function(dynamic item) onPrintKuasa;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  String query = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showChangelogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Pembaruan v${widget.latestVersion}',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catatan Perubahan:',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            Text(widget.changelog ?? 'Sistem optimalisasi performa.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: const Color(0xFF64748B), height: 1.5)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(widget.updateUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Update Sekarang'),
          ),
        ],
      ),
    );
  }

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
          Text('Halo, ${widget.name}',
              style: const TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 27,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Database Explorer (v${widget.currentVersion})',
                  style:
                      const TextStyle(color: Color(0xFF8993A4), fontSize: 12)),
              if (widget.updateUrl != null)
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1769FF),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _showChangelogDialog(context),
                    icon: const Icon(Icons.system_update_rounded, size: 14),
                    label: const Text('Update Tersedia',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => widget.onAdd('Desain'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Desain'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onAdd('Percetakan'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Cetak'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => widget.onAdd('Biro Jasa'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Biro Jasa'),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              hintText: 'Cari data di tab aktif...',
              prefixIcon: Icon(Icons.search_rounded),
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: StatTile(
                    value: '${widget.desain.length}',
                    label: 'Desain',
                    icon: Icons.language,
                    color: const Color(0xFF1769FF))),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    value: '${widget.percetakan.length}',
                    label: 'Cetak',
                    icon: Icons.print,
                    color: const Color(0xFF6556D9))),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    value: '${widget.biroJasa.length}',
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
              AdminDataList(
                  items: widget.desain,
                  titleKey: 'nama',
                  statusKey: 'status',
                  sheetName: 'Desain',
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                  onPrintKuasa: widget.onPrintKuasa,
                  query: query),
              AdminDataList(
                  items: widget.percetakan,
                  titleKey: 'deskripsi',
                  statusKey: 'status',
                  sheetName: 'Percetakan',
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                  onPrintKuasa: widget.onPrintKuasa,
                  query: query),
              AdminDataList(
                  items: widget.biroJasa,
                  titleKey: 'nomor_kendaraan',
                  statusKey: 'durasi',
                  sheetName: 'Biro Jasa',
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                  onPrintKuasa: widget.onPrintKuasa,
                  query: query),
            ]),
          ),
        ],
      ),
    );
  }
}

class AdminDataList extends StatelessWidget {
  const AdminDataList(
      {super.key,
      required this.items,
      required this.titleKey,
      required this.statusKey,
      required this.sheetName,
      required this.onEdit,
      required this.onDelete,
      required this.query,
      required this.onPrintKuasa});
  final List<dynamic> items;
  final String titleKey;
  final String statusKey;
  final String sheetName;
  final void Function(String sheetName, dynamic item) onEdit;
  final void Function(String sheetName, dynamic item) onDelete;
  final String query;
  final void Function(dynamic item) onPrintKuasa;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const EmptyState(message: 'Belum ada data.');
    final filteredItems = items.where((item) {
      final fields = sheetName == 'Desain'
          ? ['nama', 'deskripsi', 'tag', 'status']
          : sheetName == 'Percetakan'
              ? ['deskripsi', 'harga', 'status']
              : [
                  'layanan',
                  'nama',
                  'merek',
                  'type',
                  'nomor_kendaraan',
                  'deskripsi',
                  'durasi'
                ];
      return appSearches(item, query, fields);
    }).toList();

    if (sheetName == 'Biro Jasa') {
      filteredItems.sort((a, b) {
        final dateA = DateTime.tryParse(appValue(a, 'aktif'));
        final dateB = DateTime.tryParse(appValue(b, 'aktif'));
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });
    }

    if (filteredItems.isEmpty) {
      return const EmptyState(message: 'Data tidak ditemukan.');
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 14),
      itemCount: filteredItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final item = filteredItems[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7EBF2))),
          child: sheetName == 'Biro Jasa'
              ? AdminJasaRow(
                  item: item,
                  onEdit: () => onEdit(sheetName, item),
                  onDelete: () => onDelete(sheetName, item),
                  onPrintKuasa: () => onPrintKuasa(item),
                )
              : Row(children: [
                  if (sheetName == 'Percetakan') ...[
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: CatalogIcon(
                        value: appValue(item, 'ikon'),
                        status: appValue(item, statusKey),
                        size: 42,
                        enableZoom: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else if (sheetName == 'Desain') ...[
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: CatalogIcon(
                        value: appValue(item, 'linkgambar'),
                        status: appValue(item, statusKey),
                        size: 42,
                        enableZoom: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                      child: Text(
                          appValue(item, titleKey, fallback: 'Tanpa nama'),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, fontWeight: FontWeight.w800))),
                  StatusChip(
                      label: appValue(item, statusKey, fallback: 'ON PROCESS'),
                      color: const Color(0xFF1769FF)),
                  IconButton(
                      tooltip: 'Edit data',
                      onPressed: () => onEdit(sheetName, item),
                      icon: const Icon(Icons.edit_outlined, size: 19),
                      color: const Color(0xFF1769FF)),
                  IconButton(
                      tooltip: 'Hapus data',
                      onPressed: () => onDelete(sheetName, item),
                      icon: const Icon(Icons.delete_outline, size: 19),
                      color: const Color(0xFFE5484D)),
                ]),
        );
      },
    );
  }
}

class AdminJasaRow extends StatelessWidget {
  const AdminJasaRow(
      {super.key,
      required this.item,
      required this.onEdit,
      required this.onDelete,
      required this.onPrintKuasa});
  final dynamic item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPrintKuasa;

  @override
  Widget build(BuildContext context) {
    final phone = appNormalisePhone(appValue(item, 'whatsapp'));
    final message =
        'Halo ${appValue(item, 'nama')}, status layanan ${appValue(item, 'layanan')} untuk kendaraan ${appValue(item, 'nomor_kendaraan')}.';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const IconBadge(icon: Icons.directions_car, color: Color(0xFF0C9B77)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(
                '${appValue(item, 'layanan', fallback: 'LAYANAN')} • ${appValue(item, 'nomor_kendaraan', fallback: '-')}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800))),
        StatusChip(
            label: appValue(item, 'durasi', fallback: 'ON PROCESS'),
            color: const Color(0xFF1769FF)),
      ]),
      const SizedBox(height: 12),
      InfoLine(label: 'Nama', value: appValue(item, 'nama')),
      if (appValue(item, 'merek').isNotEmpty)
        InfoLine(
            label: 'Merk/Type',
            value: '${appValue(item, 'merek')} / ${appValue(item, 'type')}'),
      if (appValue(item, 'aktif').isNotEmpty)
        InfoLine(
            label: 'Masa Aktif', value: appFormatDate(appValue(item, 'aktif'))),
      Wrap(spacing: 4, children: [
        IconButton(
            tooltip: 'Edit data',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: const Color(0xFF1769FF)),
        IconButton(
            tooltip: 'Hapus data',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: const Color(0xFFF43F5E)),
        IconButton(
            tooltip: 'Cetak surat kuasa',
            onPressed: onPrintKuasa,
            icon: const Icon(Icons.description_outlined),
            color: const Color(0xFF6556D9)),
        if (appValue(item, 'foto_stnk').isNotEmpty)
          IconButton(
              tooltip: 'Lihat STNK',
              onPressed: () => appOpenUrl(appValue(item, 'foto_stnk')),
              icon: const Icon(Icons.image_outlined),
              color: const Color(0xFF0C9B77)),
        if (phone.isNotEmpty)
          IconButton(
              tooltip: 'WhatsApp',
              onPressed: () => appOpenWhatsApp(phone, message),
              icon: const Icon(Icons.chat_outlined),
              color: const Color(0xFF16A34A)),
      ]),
    ]);
  }
}

class EditDataSheet extends StatefulWidget {
  const EditDataSheet(
      {super.key,
      required this.sheetName,
      required this.item,
      required this.isNew,
      required this.onSave});

  final String sheetName;
  final dynamic item;
  final bool isNew;
  final Future<bool> Function(Map<String, String> values) onSave;

  @override
  State<EditDataSheet> createState() => _EditDataSheetState();
}

class _EditDataSheetState extends State<EditDataSheet> {
  late final Map<String, TextEditingController> controllers;
  late final Map<String, String> selections;
  bool saving = false;

  List<String> get fields {
    if (widget.sheetName == 'Desain') {
      return ['nama', 'deskripsi', 'linkgambar', 'tag', 'whatsapp', 'status'];
    }
    if (widget.sheetName == 'Percetakan') {
      return ['deskripsi', 'harga', 'ikon', 'whatsapp', 'status'];
    }
    return [
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
    ];
  }

  @override
  void initState() {
    super.initState();
    controllers = {
      for (final field in fields)
        field: TextEditingController(text: appValue(widget.item, field)),
    };
    selections = {
      if (widget.sheetName == 'Desain')
        'status': _choiceValue(appValue(widget.item, 'status'),
            ['ON PROCESS', 'SELESAI', 'DITOLAK'], 'ON PROCESS'),
      if (widget.sheetName == 'Percetakan')
        'status': _choiceValue(
            appValue(widget.item, 'status'), ['AKTIF', 'DIARSIPKAN'], 'AKTIF'),
      if (widget.sheetName == 'Biro Jasa')
        'layanan': _choiceValue(appValue(widget.item, 'layanan'),
            ['KIR', 'SAMSAT', 'REKOM'], 'KIR'),
      if (widget.sheetName == 'Biro Jasa')
        'durasi': _choiceValue(appValue(widget.item, 'durasi'),
            ['ON PROCESS', 'SELESAI', 'DITOLAK'], 'ON PROCESS'),
    };
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    setState(() => saving = true);
    final values = <String, String>{
      for (final field in fields) field: controllers[field]!.text.trim(),
    };
    values.addAll(selections);
    if (widget.sheetName == 'Percetakan' && values['status'] == 'AKTIF') {
      values['status'] = 'SELESAI';
    } else if (widget.sheetName == 'Percetakan' &&
        values['status'] == 'DIARSIPKAN') {
      values['status'] = 'DITOLAK';
    }
    final success = await widget.onSave(values);
    if (!mounted) return;
    if (success) Navigator.pop(context);
    setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(top: 70, bottom: bottomInset),
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFD8DEE8),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 18),
                Text('${widget.isNew ? 'Tambah' : 'Edit'} ${widget.sheetName}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                ...fields.map((field) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildField(field),
                    )),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: saving ? null : save,
                    icon: saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: Text(saving
                        ? 'Menyimpan...'
                        : widget.isNew
                            ? 'Simpan Data'
                            : 'Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String field) {
    final choices = _choicesFor(field);
    if (choices != null) {
      return DropdownButtonFormField<String>(
        initialValue: selections[field],
        decoration: InputDecoration(labelText: _labelFor(field)),
        items: choices
            .map((choice) =>
                DropdownMenuItem<String>(value: choice, child: Text(choice)))
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => selections[field] = value);
        },
      );
    }
    if (field == 'aktif') {
      return TextField(
        controller: controllers[field],
        readOnly: true,
        onTap: _pickActiveDate,
        decoration: InputDecoration(
          labelText: 'Masa Aktif',
          hintText: 'Pilih tanggal',
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          suffixIcon: IconButton(
              onPressed: _pickActiveDate,
              icon: const Icon(Icons.edit_calendar_outlined)),
        ),
      );
    }
    return TextField(
      controller: controllers[field],
      maxLines: field == 'deskripsi' ? 3 : 1,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(labelText: _labelFor(field)),
    );
  }

  List<String>? _choicesFor(String field) {
    if (widget.sheetName == 'Desain' && field == 'status') {
      return ['ON PROCESS', 'SELESAI', 'DITOLAK'];
    }
    if (widget.sheetName == 'Percetakan' && field == 'status') {
      return ['AKTIF', 'DIARSIPKAN'];
    }
    if (widget.sheetName == 'Biro Jasa' && field == 'layanan') {
      return ['KIR', 'SAMSAT', 'REKOM'];
    }
    if (widget.sheetName == 'Biro Jasa' && field == 'durasi') {
      return ['ON PROCESS', 'SELESAI', 'DITOLAK'];
    }
    return null;
  }

  Future<void> _pickActiveDate() async {
    final initial =
        DateTime.tryParse(controllers['aktif']!.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih masa aktif',
    );
    if (picked != null) {
      controllers['aktif']!.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  String _labelFor(String field) => field
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  String _choiceValue(String current, List<String> choices, String fallback) {
    final normalized = current.trim().toUpperCase();
    return choices.contains(normalized) ? normalized : fallback;
  }
}
