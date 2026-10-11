import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'config.dart';
import 'main.dart' show appValue;

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({
    super.key,
    required this.desain,
    required this.percetakan,
    required this.boutique,
    required this.biroJasa,
  });

  final List<dynamic> desain;
  final List<dynamic> percetakan;
  final List<dynamic> boutique;
  final List<dynamic> biroJasa;

  @override
  Widget build(BuildContext context) {
    final statusData = _calculateStatusDistribution();
    final revenueData = _calculateRevenueEstimation();
    final stnkData = _calculateSTNKExpiry();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildSummaryCards(),
        const SizedBox(height: 24),
        _buildStatusChart(statusData),
        const SizedBox(height: 24),
        _buildRevenueChart(revenueData),
        const SizedBox(height: 24),
        _buildSTNKChart(stnkData),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ANALYTICS DASHBOARD',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1769FF),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Overview Statistik Layanan',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF172033),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            value: '${desain.length}',
            label: 'Total Desain',
            icon: Icons.language,
            color: const Color(0xFF1769FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '${percetakan.length}',
            label: 'Total Percetakan',
            icon: Icons.print,
            color: const Color(0xFF6556D9),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '${boutique.length}',
            label: 'Total Boutique',
            icon: Icons.shopping_bag_outlined,
            color: const Color(0xFFBE185D),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '${biroJasa.length}',
            label: 'Total Biro Jasa',
            icon: Icons.directions_car,
            color: const Color(0xFF0C9B77),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChart(Map<String, int> statusData) {
    return _ChartCard(
      title: 'Distribusi Status',
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: statusData.entries.map((entry) {
              final colors = {
                'SELESAI': const Color(0xFF0C9B77),
                'AKTIF': const Color(0xFF0C9B77),
                'ON PROCESS': const Color(0xFF1769FF),
                'DITOLAK': const Color(0xFFE5484D),
                'DIARSIPKAN': const Color(0xFF64748B),
              };
              return PieChartSectionData(
                value: entry.value.toDouble(),
                title: '${entry.key}\n${entry.value}',
                color: colors[entry.key] ?? const Color(0xFF64748B),
                radius: 50,
                titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart(Map<String, double> revenueData) {
    return _ChartCard(
      title: 'Estimasi Revenue',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: revenueData.values.isEmpty
                ? 1000000
                : revenueData.values.reduce((a, b) => a > b ? a : b) * 1.2,
            barGroups: revenueData.entries.map((entry) {
              final colors = {
                'Percetakan': const Color(0xFF6556D9),
                'Boutique': const Color(0xFFBE185D),
              };
              return BarChartGroupData(
                x: revenueData.keys.toList().indexOf(entry.key),
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: colors[entry.key] ?? const Color(0xFF64748B),
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= revenueData.keys.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        revenueData.keys.elementAt(index),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSTNKChart(Map<String, int> stnkData) {
    return _ChartCard(
      title: 'Timeline Masa Aktif STNK',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: stnkData.values.isEmpty
                ? 10
                : stnkData.values.reduce((a, b) => a > b ? a : b) * 1.2,
            barGroups: stnkData.entries.map((entry) {
              final colors = {
                'Expired': const Color(0xFFE5484D),
                'H-7': const Color(0xFFF59E0B),
                'H-30': const Color(0xFF16A34A),
                '30+ Hari': const Color(0xFF1769FF),
                'No Date': const Color(0xFF64748B),
              };
              return BarChartGroupData(
                x: stnkData.keys.toList().indexOf(entry.key),
                barRods: [
                  BarChartRodData(
                    toY: entry.value.toDouble(),
                    color: colors[entry.key] ?? const Color(0xFF64748B),
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= stnkData.keys.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        stnkData.keys.elementAt(index),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, int> _calculateStatusDistribution() {
    final Map<String, int> statusCount = {};

    for (final item in desain) {
      final status = appValue(item, 'status', fallback: 'ON PROCESS')
          .toUpperCase();
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    for (final item in percetakan) {
      final status = appValue(item, 'status', fallback: 'AKTIF').toUpperCase();
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    for (final item in boutique) {
      final status = appValue(item, 'status', fallback: 'AKTIF').toUpperCase();
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    for (final item in biroJasa) {
      final status = appValue(item, 'durasi', fallback: 'ON PROCESS')
          .toUpperCase();
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    return statusCount;
  }

  Map<String, double> _calculateRevenueEstimation() {
    double percetakanRevenue = 0;
    double boutiqueRevenue = 0;

    for (final item in percetakan) {
      final hargaStr = appValue(item, 'harga', fallback: '0');
      final harga = _parseCurrency(hargaStr);
      percetakanRevenue += harga;
    }

    for (final item in boutique) {
      final hargaStr = appValue(item, 'harga', fallback: '0');
      final harga = _parseCurrency(hargaStr);
      boutiqueRevenue += harga;
    }

    return {
      'Percetakan': percetakanRevenue,
      'Boutique': boutiqueRevenue,
    };
  }

  Map<String, int> _calculateSTNKExpiry() {
    int expired = 0;
    int h7 = 0;
    int h30 = 0;
    int h30plus = 0;
    int noDate = 0;

    for (final item in biroJasa) {
      final aktifStr = appValue(item, 'aktif', fallback: '');
      if (aktifStr.isEmpty) {
        noDate++;
        continue;
      }

      final expiry = AppConfig.getSisaHari(aktifStr);
      if (!expiry.isValid) {
        noDate++;
        continue;
      }

      if (expiry.isExpired) {
        expired++;
      } else if (expiry.sisa <= 7) {
        h7++;
      } else if (expiry.sisa <= 30) {
        h30++;
      } else {
        h30plus++;
      }
    }

    return {
      'Expired': expired,
      'H-7': h7,
      'H-30': h30,
      '30+ Hari': h30plus,
      'No Date': noDate,
    };
  }

  double _parseCurrency(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
