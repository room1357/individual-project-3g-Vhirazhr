import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';
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

  final List<String> _chartTypes = ['Diagram Pie', 'Diagram Batang'];

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
        // biarin dulu, nanti difilter dengan tahun di bawah
        break;
    }

    // ✅ kalau pilih Semua Waktu => filter berdasarkan tahun dropdown
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
      top: false,
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
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                "Statistik Keuangan",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: maroon,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Analisis pengeluaran Anda",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: darkText.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 20),
            _buildDashboardCards(
              totalAmount,
              filteredExpenses.length,
              averageAmount,
            ),

            const SizedBox(height: 20),

            // ✅ FILTER WAKTU (udah wrap, semua chip keliatan)
            _buildTimeFilterCard(),

            // ✅ FILTER TAHUN muncul saat Semua Waktu dipilih
            if (_selectedTimeFilter == 'Semua Waktu') ...[
              const SizedBox(height: 12),
              _buildYearFilter(),
            ],

            const SizedBox(height: 20),
            _buildChartSection(categoryTotals, totalAmount),

            const SizedBox(height: 20),
            _buildCategoryList(categoryTotals, totalAmount),

            if (filteredExpenses.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildLargeExpenses(filteredExpenses),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===================== UI COMPONENTS =====================

  Widget _buildDashboardCards(double total, int count, double average) {
    return Row(
      children: [
        Expanded(
          child: _buildDashboardCard(
            "Total Pengeluaran",
            "Rp ${total.toStringAsFixed(0)}",
            Icons.account_balance_wallet_rounded,
            maroon,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDashboardCard(
            "Rata-rata",
            "Rp ${average.toStringAsFixed(0)}",
            Icons.trending_up_rounded,
            roseDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDashboardCard(
            "Transaksi",
            "$count item",
            Icons.receipt_long_rounded,
            blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Icon(
                Icons.more_vert_rounded,
                color: darkText.withOpacity(0.3),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              color: darkText.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIX UTAMA: pakai Wrap biar chip terakhir "Semua Waktu" gak ketutup
  Widget _buildTimeFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Periode Analisis",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                ),
              ),
              Icon(
                Icons.calendar_month_rounded,
                color: maroon.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _timeFilters.map((filter) {
                  final selected = _selectedTimeFilter == filter;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            selected
                                ? LinearGradient(
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
                                  : maroon.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: white,
                              size: 14,
                            ),
                          if (selected) const SizedBox(width: 6),
                          Text(
                            filter,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? white : darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // ✅ Year dropdown beneran dibuat & dipakai
  Widget _buildYearFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: maroon.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
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

  Widget _buildChartSection(
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    if (categoryTotals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Distribusi Kategori",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: maroon,
                  ),
                ),
                Icon(
                  Icons.pie_chart_rounded,
                  color: maroon.withOpacity(0.7),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Belum ada data kategori",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: darkText.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Distribusi Kategori",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                ),
              ),
              Row(
                children: [
                  ..._chartTypes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final type = entry.value;
                    final selected = _selectedChartType == index;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedChartType = index),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? maroon.withOpacity(0.1) : null,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? maroon : maroon.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                                selected ? maroon : darkText.withOpacity(0.6),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child:
                _selectedChartType == 0
                    ? _buildPieChart(categoryTotals, totalAmount)
                    : _buildBarChart(categoryTotals),
          ),
          const SizedBox(height: 16),
          Text(
            "Total: Rp ${totalAmount.toStringAsFixed(0)}",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: maroon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    final categories = categoryTotals.entries.toList();
    final List<PieChartSectionData> sections = [];

    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    for (int i = 0; i < categories.length; i++) {
      final isTouched = i == _touchedIndex;
      final double fontSize = isTouched ? 16.0 : 14.0;
      final double radius = isTouched ? 80.0 : 70.0;

      final category = categories[i];

      final double percentage =
          totalAmount > 0 ? (category.value / totalAmount * 100) : 0.0;

      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildChartLegend(categories, colors)),
      ],
    );
  }

  Widget _buildChartLegend(
    List<MapEntry<String, double>> categories,
    List<Color> colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final color = colors[index % colors.length];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.key,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: darkText,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Rp ${category.value.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: darkText.withOpacity(0.7),
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
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= categories.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    categories[index].key,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: darkText,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    "Rp${value.toInt()}",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      color: darkText.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        barGroups:
            categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: category.value,
                    color: colors[index % colors.length],
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCategoryList(
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    if (categoryTotals.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt_rounded, color: maroon, size: 20),
              SizedBox(width: 8),
              Text(
                "Detail Kategori",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...categoryTotals.entries.map((entry) {
            final percentage =
                totalAmount > 0 ? (entry.value / totalAmount * 100) : 0.0;
            final color = _getCategoryColor(entry.key);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${percentage.toStringAsFixed(1)}% dari total",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: darkText.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rp ${entry.value.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: maroon,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 100,
                        height: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: color.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLargeExpenses(List<Expense> expenses) {
    final sorted = List<Expense>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.attach_money_rounded, color: maroon, size: 20),
              SizedBox(width: 8),
              Text(
                "Transaksi Terbesar",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sorted.take(5).map((expense) {
            final color = _getCategoryColor(expense.category);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: softSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: maroon.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              expense.formattedDate,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: darkText.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        expense.formattedAmount,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: maroon,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Rp ${expense.amount.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: darkText.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: pinkSoft.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 60,
                color: maroon.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum ada data statistik",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tambahkan pengeluaran untuk melihat analisis statistik",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: darkText.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to add expense
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Tambah Pengeluaran",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: white,
                ),
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.green;
      case 'utilitas':
        return Colors.blue;
      case 'hiburan':
        return Colors.pink;
      case 'pendidikan':
        return Colors.purple;
      case 'belanja':
        return Colors.red;
      case 'kesehatan':
        return Colors.teal;
      case 'lainnya':
        return Colors.grey;
      default:
        return Colors.deepPurple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'utilitas':
        return Icons.home;
      case 'hiburan':
        return Icons.movie;
      case 'pendidikan':
        return Icons.school;
      case 'belanja':
        return Icons.shopping_cart;
      case 'kesehatan':
        return Icons.medical_services;
      case 'lainnya':
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }
}
