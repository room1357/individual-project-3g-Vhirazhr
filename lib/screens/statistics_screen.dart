import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_manager.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Expense> _allExpenses = [];
  String _selectedTimeFilter = 'Semua Waktu';
  String _selectedYear = DateTime.now().year.toString();

  final List<String> _timeFilters = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Tahun Ini',
    'Semua Waktu',
  ];

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

  // Generate tahun dari 2020 sampai sekarang
  List<String> get _availableYears {
    final currentYear = DateTime.now().year;
    final years = <String>[];
    for (int year = 2020; year <= currentYear; year++) {
      years.add(year.toString());
    }
    return years.reversed.toList(); // Terbaru dulu
  }

  // Filter expenses berdasarkan waktu DAN tahun
  List<Expense> _getFilteredExpenses() {
    final now = DateTime.now();
    List<Expense> filtered = _allExpenses;

    // Filter berdasarkan waktu
    switch (_selectedTimeFilter) {
      case 'Hari Ini':
        filtered =
            filtered
                .where(
                  (expense) =>
                      expense.date.year == now.year &&
                      expense.date.month == now.month &&
                      expense.date.day == now.day,
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
                  (expense) =>
                      expense.date.isAfter(startDate) &&
                      expense.date.isBefore(endDate),
                )
                .toList();
        break;

      case 'Bulan Ini':
        filtered =
            filtered
                .where(
                  (expense) =>
                      expense.date.year == now.year &&
                      expense.date.month == now.month,
                )
                .toList();
        break;

      case 'Tahun Ini':
        filtered =
            filtered.where((expense) => expense.date.year == now.year).toList();
        break;

      case 'Semua Waktu':
        // Tetap filter berdasarkan tahun yang dipilih
        break;
    }

    // Filter berdasarkan tahun (kecuali untuk Hari/Minggu/Bulan Ini)
    if (_selectedTimeFilter != 'Hari Ini' &&
        _selectedTimeFilter != 'Minggu Ini' &&
        _selectedTimeFilter != 'Bulan Ini') {
      filtered =
          filtered
              .where((expense) => expense.date.year.toString() == _selectedYear)
              .toList();
    }

    return filtered;
  }

  // Get kategori terpopuler untuk periode yang difilter
  Map<String, double> _getTopCategories(List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};
    for (final expense in expenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    // Sort by amount descending
    final sortedEntries =
        categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _getFilteredExpenses();
    final totalAmount = _calculateTotal(filteredExpenses);
    final averageAmount = _calculateAverage(filteredExpenses);
    final categoryTotals = _getTopCategories(filteredExpenses);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistik Pengeluaran'),
        backgroundColor: Colors.blue,
      ),
      body:
          _allExpenses.isEmpty
              ? _buildEmptyState()
              : _buildContent(
                filteredExpenses,
                totalAmount,
                averageAmount,
                categoryTotals,
              ),
    );
  }

  Widget _buildContent(
    List<Expense> filteredExpenses,
    double totalAmount,
    double averageAmount,
    Map<String, double> categoryTotals,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter Waktu
          _buildTimeFilter(),
          SizedBox(height: 16),

          // Filter Tahun (jika bukan hari/minggu/bulan ini)
          if (_selectedTimeFilter != 'Hari Ini' &&
              _selectedTimeFilter != 'Minggu Ini' &&
              _selectedTimeFilter != 'Bulan Ini')
            _buildYearFilter(),
          if (_selectedTimeFilter != 'Hari Ini' &&
              _selectedTimeFilter != 'Minggu Ini' &&
              _selectedTimeFilter != 'Bulan Ini')
            SizedBox(height: 16),

          // Summary
          _buildSummaryCards(
            totalAmount,
            filteredExpenses.length,
            averageAmount,
          ),
          SizedBox(height: 24),

          // Trend berdasarkan filter
          _buildTrendSection(filteredExpenses, categoryTotals),
          SizedBox(height: 24),

          // Breakdown Kategori
          _buildCategoryBreakdown(categoryTotals, totalAmount),
          SizedBox(height: 24),

          // Pengeluaran Terbesar
          _buildLargeExpenses(filteredExpenses),
        ],
      ),
    );
  }

  Widget _buildTimeFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            _timeFilters.map((filter) {
              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: _selectedTimeFilter == filter,
                  onSelected:
                      (selected) =>
                          setState(() => _selectedTimeFilter = filter),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildYearFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: _selectedYear,
        isExpanded: true,
        underline: SizedBox(),
        items:
            _availableYears.map((year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text('Tahun $year'),
              );
            }).toList(),
        onChanged: (newValue) => setState(() => _selectedYear = newValue!),
      ),
    );
  }

  Widget _buildSummaryCards(double total, int count, double average) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total',
          'Rp ${total.toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.blue,
        ),
        _buildStatCard(
          'Transaksi',
          '$count item',
          Icons.list_alt,
          Colors.green,
        ),
        _buildStatCard(
          'Rata-rata',
          'Rp ${average.toStringAsFixed(0)}',
          Icons.bar_chart,
          Colors.orange,
        ),
        _buildStatCard(
          'Kategori',
          '${_getTopCategories(_getFilteredExpenses()).length}',
          Icons.category,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildTrendSection(
    List<Expense> expenses,
    Map<String, double> topCategories,
  ) {
    final topCategory =
        topCategories.isNotEmpty ? topCategories.entries.first : null;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend $_selectedTimeFilter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            if (topCategory != null) ...[
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kategori Terpopuler:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${topCategory.key} - Rp ${topCategory.value.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            Text(
              'Total ${expenses.length} transaksi dengan ${topCategories.length} kategori berbeda',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    Map<String, double> categoryTotals,
    double totalAmount,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breakdown Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...categoryTotals.entries.map((entry) {
              final percentage =
                  totalAmount > 0 ? (entry.value / totalAmount * 100) : 0;
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      'Rp ${entry.value.toStringAsFixed(0)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeExpenses(List<Expense> expenses) {
    final largeExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengeluaran Terbesar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...largeExpenses
                .take(5)
                .map(
                  (expense) => Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getCategoryColor(expense.category),
                          child: Icon(
                            _getCategoryIcon(expense.category),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.title,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${expense.category} • ${expense.formattedDate}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          expense.formattedAmount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Belum ada data pengeluaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tambahkan pengeluaran untuk melihat statistik',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _calculateTotal(List<Expense> expenses) =>
      expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  double _calculateAverage(List<Expense> expenses) =>
      expenses.isEmpty ? 0 : _calculateTotal(expenses) / expenses.length;

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.green;
      case 'utilitas':
        return Colors.purple;
      case 'hiburan':
        return Colors.pink;
      case 'pendidikan':
        return Colors.blue;
      case 'belanja':
        return Colors.red;
      default:
        return Colors.grey;
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
      default:
        return Icons.attach_money;
    }
  }
}
