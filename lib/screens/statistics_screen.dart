import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/category_manager.dart';
import '../services/expense_manager.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // ===== THEME SAMA HOME =====
  static const Color pinkBg = Color(0xFFF8D7DA);
  static const Color pinkSoft = Color(0xFFF3B8C2);
  static const Color roseDark = Color(0xFFD87A87);
  static const Color maroon = Color(0xFF451A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D1B2E);
  static const Color softSurface = Color(0xFFFEF7F8);

  static const Color blueAccent = Color(0xFF4A6FA5);
  static const Color greenAccent = Color(0xFF5CB85C);
  static const Color yellowAccent = Color(0xFFFFD166);
  static const Color purpleAccent = Color(0xFF9D4EDD);

  List<Expense> _allExpenses = [];
  String _selectedTimeFilter = 'Minggu Ini';
  String _selectedYear = DateTime.now().year.toString();
  int _selectedChartType = 0; // 0: Pie, 1: Bar
  int _touchedIndex = -1;

  final List<String> _timeFilters = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Tahun Ini',
    'Semua Waktu',
  ];

  final List<String> _chartTypes = ['Pie', 'Batang'];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _allExpenses = ExpenseManager.expenses;
    });
  }

  List<String> get _availableYears {
    final currentYear = DateTime.now().year;
    final years = <String>[];
    for (int year = 2020; year <= currentYear; year++) {
      years.add(year.toString());
    }
    return years.reversed.toList();
  }

  List<Expense> _getFilteredExpenses() {
    final now = DateTime.now();
    List<Expense> filtered = _allExpenses;

    switch (_selectedTimeFilter) {
      case 'Hari Ini':
        filtered =
            filtered
                .where(
                  (e) =>
                      e.date.year == now.year &&
                      e.date.month == now.month &&
                      e.date.day == now.day,
                )
                .toList();
        break;

      case 'Minggu Ini':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startDate = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final endDate = DateTime(now.year, now.month, now.day + 1);
        filtered =
            filtered
                .where(
                  (e) => e.date.isAfter(startDate) && e.date.isBefore(endDate),
                )
                .toList();
        break;

      case 'Bulan Ini':
        filtered =
            filtered
                .where(
                  (e) => e.date.year == now.year && e.date.month == now.month,
                )
                .toList();
        break;

      case 'Tahun Ini':
        filtered = filtered.where((e) => e.date.year == now.year).toList();
        break;

      case 'Semua Waktu':
        break;
    }

    if (_selectedTimeFilter == 'Semua Waktu') {
      filtered =
          filtered
              .where((e) => e.date.year.toString() == _selectedYear)
              .toList();
    }

    return filtered;
  }

  Map<String, double> _getCategoryTotals(List<Expense> expenses) {
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals.update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount);
    }
    final sorted =
        totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  // ===== PERIODE LABEL =====
  String _getPeriodLabel() {
    final now = DateTime.now();

    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';

    switch (_selectedTimeFilter) {
      case 'Hari Ini':
        return fmt(now);

      case 'Minggu Ini':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startDate = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final endDate = DateTime(now.year, now.month, now.day);
        return '${fmt(startDate)} - ${fmt(endDate)}';

      case 'Bulan Ini':
        final startDate = DateTime(now.year, now.month, 1);
        final endDate = DateTime(now.year, now.month + 1, 0);
        return '${fmt(startDate)} - ${fmt(endDate)}';

      case 'Tahun Ini':
        return 'Tahun ${now.year}';

      case 'Semua Waktu':
        return 'Tahun $_selectedYear';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredExpenses();
    final total = _calculateTotal(filtered);
    final avg = _calculateAverage(filtered);
    final catTotals = _getCategoryTotals(filtered);

    return Scaffold(
      backgroundColor: pinkBg,
      body:
          _allExpenses.isEmpty
              ? _buildEmptyState()
              : _buildContent(filtered, total, avg, catTotals),
    );
  }

  Widget _buildContent(
    List<Expense> filteredExpenses,
    double totalAmount,
    double averageAmount,
    Map<String, double> categoryTotals,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          14,
          16,
          30 + MediaQuery.of(context).padding.bottom + 90,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(totalAmount, filteredExpenses.length),
            const SizedBox(height: 14),
            _buildTimeFilterPills(),
            if (_selectedTimeFilter == 'Semua Waktu') ...[
              const SizedBox(height: 10),
              _buildYearFilter(),
            ],
            const SizedBox(height: 16),
            _buildChartSection(categoryTotals, totalAmount),
            const SizedBox(height: 14),
            _buildDashboardGrid(
              totalAmount,
              filteredExpenses.length,
              averageAmount,
              categoryTotals.length,
            ),

            const SizedBox(height: 16),
            _buildCategoryList(categoryTotals, totalAmount),

            if (filteredExpenses.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildLargeExpenses(filteredExpenses),
            ],
          ],
        ),
      ),
    );
  }

  // ===================== HEADER =====================
  Widget _buildHeader(double totalAmount, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [maroon, roseDark.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.insights_rounded, color: white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Statistik Keuangan",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    color: white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Analisis pengeluaran kamu",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _chipInfo(
                      icon: Icons.event_rounded,
                      text: _getPeriodLabel(),
                    ),
                    const SizedBox(width: 6),
                    _chipInfo(
                      icon: Icons.receipt_long_rounded,
                      text: "$count transaksi",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipInfo({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: white, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: white,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== DASHBOARD (KECIL) =====================
  Widget _buildDashboardGrid(
    double total,
    int count,
    double average,
    int categoryCount,
  ) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.6, // lebih kecil/pendek
      ),
      children: [
        _dashCard(
          title: "Total",
          value: "Rp ${total.toStringAsFixed(0)}",
          icon: Icons.account_balance_wallet_rounded,
          color: maroon,
        ),
        _dashCard(
          title: "Rata-rata",
          value: "Rp ${average.toStringAsFixed(0)}",
          icon: Icons.trending_up_rounded,
          color: roseDark,
        ),
        _dashCard(
          title: "Transaksi",
          value: "$count item",
          icon: Icons.receipt_long_rounded,
          color: blueAccent,
        ),
        _dashCard(
          title: "Kategori",
          value: "$categoryCount jenis",
          icon: Icons.category_rounded,
          color: purpleAccent,
        ),
      ],
    );
  }

  Widget _dashCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: maroon.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 10.5,
                    color: darkText.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== FILTER WAKTU (HORIZONTAL) =====================
  Widget _buildTimeFilterPills() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: maroon, size: 18),
              SizedBox(width: 6),
              Text(
                "Periode Analisis",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 40,
            child: ScrollConfiguration(
              behavior: const _NoGlowScrollBehavior(),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  right: 8,
                ), // biar ujung nggak ketutup
                itemCount: _timeFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final filter = _timeFilters[i];
                  final selected = _selectedTimeFilter == filter;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            selected
                                ? const LinearGradient(
                                  colors: [maroon, roseDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : null,
                        color: selected ? null : softSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              selected
                                  ? Colors.transparent
                                  : maroon.withOpacity(0.12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w600,
                            color: selected ? white : darkText,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== YEAR FILTER =====================
  Widget _buildYearFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: maroon.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _selectedYear,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: maroon.withOpacity(0.8),
        ),
        items:
            _availableYears.map((year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text(
                  'Tahun $year',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
              );
            }).toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() => _selectedYear = v);
        },
      ),
    );
  }

  // ===================== CHART SECTION =====================
  Widget _buildChartSection(
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded, color: maroon, size: 18),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  "Distribusi Kategori",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: maroon,
                  ),
                ),
              ),
              _chartTab(0),
              const SizedBox(width: 6),
              _chartTab(1),
            ],
          ),
          const SizedBox(height: 12),

          if (categoryTotals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "Belum ada data kategori",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: darkText.withOpacity(0.7),
                ),
              ),
            )
          else
            SizedBox(
              height: 240,
              child:
                  _selectedChartType == 0
                      ? _buildPieChart(categoryTotals, totalAmount)
                      : _buildBarChart(categoryTotals),
            ),

          const SizedBox(height: 6),
          Text(
            "Total: Rp ${totalAmount.toStringAsFixed(0)}",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
              color: maroon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartTab(int index) {
    final selected = _selectedChartType == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? maroon.withOpacity(0.12) : softSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? maroon : maroon.withOpacity(0.10),
          ),
        ),
        child: Text(
          _chartTypes[index],
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? maroon : darkText.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    final categories = categoryTotals.entries.toList();

    final List<PieChartSectionData> sections = [];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final isTouched = i == _touchedIndex;

      final double percentage =
          totalAmount > 0 ? (category.value / totalAmount * 100) : 0.0;

      final Color color = _getCategoryColor(category.key);

      sections.add(
        PieChartSectionData(
          color: color,
          value: percentage,
          radius: isTouched ? 52 : 46, // 🔥 KECILKAN
          title: percentage >= 10 ? '${percentage.toStringAsFixed(1)}%' : '',
          titleStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: AspectRatio(
            // 🔥 PENTING
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response?.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              response!.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 36, // 🔥 KECILKAN
                    sections: sections,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: darkText.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      "Rp ${totalAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: maroon,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: _buildChartLegend(categories)),
      ],
    );
  }

  Widget _buildChartLegend(List<MapEntry<String, double>> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          categories.map((entry) {
            final color = _getCategoryColor(entry.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildBarChart(Map<String, double> categoryTotals) {
    final categories = categoryTotals.entries.toList();
    final maxValue = categoryTotals.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AspectRatio(
        aspectRatio: 1.2, // 🔥 KUNCI: stabil & tidak kepotong
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue * 1.3,
            barTouchData: BarTouchData(enabled: true),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine:
                  (value) =>
                      FlLine(color: maroon.withOpacity(0.07), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),

            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              // 🔥 KIRI (NOMINAL)
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 46, // 🔥 PENTING
                  interval: maxValue / 4,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      "Rp${value.toInt()}",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        color: darkText.withOpacity(0.6),
                      ),
                    );
                  },
                ),
              ),

              // 🔥 BAWAH (KATEGORI)
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= categories.length) {
                      return const SizedBox();
                    }

                    final label = categories[index].key;
                    final shortLabel =
                        label.length > 7 ? '${label.substring(0, 7)}…' : label;

                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        shortLabel,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),

            barGroups:
                categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;

                  final color = _getCategoryColor(category.key);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: category.value,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        color: color, // 🔥 SAMA DENGAN PIE
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  // ===================== CATEGORY LIST =====================
  Widget _buildCategoryList(
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    if (categoryTotals.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt_rounded, color: maroon, size: 18),
              SizedBox(width: 6),
              Text(
                "Detail Kategori",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...categoryTotals.entries.map((entry) {
            final percentage =
                totalAmount > 0 ? (entry.value / totalAmount * 100) : 0.0;
            final color = _getCategoryColor(entry.key);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: softSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: maroon.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(entry.key),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            minHeight: 6,
                            value: percentage / 100,
                            backgroundColor: color.withOpacity(0.12),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${percentage.toStringAsFixed(1)}% dari total",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.5,
                            color: darkText.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Rp ${entry.value.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: maroon,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===================== LARGE EXPENSES =====================
  Widget _buildLargeExpenses(List<Expense> expenses) {
    final sorted = List<Expense>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_rounded, color: maroon, size: 18),
              SizedBox(width: 6),
              Text(
                "Transaksi Terbesar",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sorted.take(5).map((expense) {
            final color = _getCategoryColor(expense.category);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: softSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: maroon.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.8,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                expense.category,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              expense.formattedDate,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10.5,
                                color: darkText.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Rp ${expense.amount.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.8,
                      fontWeight: FontWeight.w800,
                      color: maroon,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===================== EMPTY STATE =====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    pinkSoft.withOpacity(0.7),
                    roseDark.withOpacity(0.9),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                size: 58,
                color: white,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Belum ada data statistik",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Tambahkan pengeluaran untuk melihat analisis statistik.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                color: darkText.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== HELPERS =====================
  double _calculateTotal(List<Expense> expenses) =>
      expenses.fold(0.0, (sum, e) => sum + e.amount);

  double _calculateAverage(List<Expense> expenses) =>
      expenses.isEmpty ? 0 : _calculateTotal(expenses) / expenses.length;

  Color _getCategoryColor(String categoryName) {
    final cat =
        CategoryManager.categories
            .where((c) => c.name == categoryName)
            .toList();

    return cat.isNotEmpty ? cat.first.color : Colors.grey;
  }

  IconData _getCategoryIcon(String categoryName) {
    final cat =
        CategoryManager.categories
            .where((c) => c.name == categoryName)
            .toList();

    return cat.isNotEmpty ? cat.first.icon : Icons.attach_money;
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
