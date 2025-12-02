import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/category_manager.dart';
import '../services/expense_manager.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  State<AdvancedExpenseListScreen> createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  // ===== THEME SAMA HOME =====
  static const Color pinkBg = Color(0xFFF8D7DA);
  static const Color pinkSoft = Color(0xFFF3B8C2);
  static const Color roseDark = Color(0xFFD87A87);
  static const Color maroon = Color(0xFF451A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D1B2E);
  static const Color patternBg = Color(0xFFFEF7F8);

  List<Expense> filteredExpenses = [];
  String selectedCategory = 'Semua';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filterExpenses();
  }

  @override
  Widget build(BuildContext context) {
    // selalu ambil data terbaru dari manager
    final expenses = ExpenseManager.expenses;

    // list kategori terbaru
    final categories = [
      'Semua',
      ...CategoryManager.categories.map((cat) => cat.name),
    ];

    return Scaffold(
      backgroundColor: pinkBg,
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'Advanced Expenses',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            fontSize: 20,
          ),
        ),
        backgroundColor: maroon,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      // ✅ SEMUA DIJADIIN 1 SCROLL
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ===== SEARCH BAR =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: maroon.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (_) => _filterExpenses(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari pengeluaran...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: darkText.withOpacity(0.45),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: maroon.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // ===== CATEGORY FILTER CHIPS =====
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final selected = selectedCategory == cat;

                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? white : darkText,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = cat;
                      _filterExpenses();
                    });
                  },
                  selectedColor: maroon,
                  backgroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: selected ? maroon : maroon.withOpacity(0.12),
                    ),
                  ),
                  elevation: selected ? 2 : 0,
                  shadowColor: maroon.withOpacity(0.25),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // ===== CONTENT =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Summary"),
                const SizedBox(height: 8),
                _buildHeroSummaryCard(),

                const SizedBox(height: 16),

                _buildSectionHeader("Total per Kategori"),
                const SizedBox(height: 8),
                _buildCategoryTotals(),

                const SizedBox(height: 16),

                _buildSectionHeader("Expenses"),
                const SizedBox(height: 8),
                _buildExpenseList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== UI COMPONENTS =====================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: darkText,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ===== HERO SUMMARY =====
  Widget _buildHeroSummaryCard() {
    final total = _calculateTotal(filteredExpenses);
    final avg = _calculateAverage(filteredExpenses);
    final count = "${filteredExpenses.length} item";
    final daily =
        "Rp ${ExpenseManager.getAverageDaily(filteredExpenses).toStringAsFixed(0)}";
    final highest =
        ExpenseManager.getHighestExpense(filteredExpenses) != null
            ? ExpenseManager.getHighestExpense(
              filteredExpenses,
            )!.formattedAmount
            : "Rp 0";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [maroon, roseDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.4),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _heroStat(
                  title: "Total",
                  value: total,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat(
                  title: "Tertinggi",
                  value: highest,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _heroMiniStat(
                  title: "Jumlah",
                  value: count,
                  icon: Icons.list_alt_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _heroMiniStat(
                  title: "Rata-rata",
                  value: avg,
                  icon: Icons.bar_chart_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _heroMiniStat(
                  title: "Harian",
                  value: daily,
                  icon: Icons.calendar_month_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: white.withOpacity(0.25), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroMiniStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: white.withOpacity(0.22), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: white.withOpacity(0.95), size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===== TOTAL PER KATEGORI =====
  Widget _buildCategoryTotals() {
    final totals = ExpenseManager.getTotalByCategory(filteredExpenses);
    final maxVal =
        totals.isEmpty ? 1.0 : totals.values.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
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
        border: Border.all(color: maroon.withOpacity(0.06)),
      ),
      child:
          totals.isEmpty
              ? Text(
                "Belum ada data",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: darkText.withOpacity(0.6),
                ),
              )
              : Column(
                children:
                    totals.entries.map((entry) {
                      final color = _getCategoryColor(entry.key);
                      final ratio = (entry.value / maxVal).clamp(0.0, 1.0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(entry.key),
                                    color: color,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: darkText,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Rp ${entry.value.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: maroon,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 6,
                                backgroundColor: color.withOpacity(0.12),
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
    );
  }

  // ===== LIST EXPENSES =====
  Widget _buildExpenseList() {
    if (filteredExpenses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: pinkSoft.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 34,
                color: maroon.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tidak ada pengeluaran",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Coba ganti filter di atas",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: darkText.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          filteredExpenses.map((expense) {
            final c = _getCategoryColor(expense.category);
            final icon = _getCategoryIcon(expense.category);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: maroon.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                leading: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [c.withOpacity(0.18), c.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: c, size: 22),
                ),
                title: Text(
                  expense.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                subtitle: Text(
                  '${expense.category} • ${expense.formattedDate}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: darkText.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: maroon.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    expense.formattedAmount,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: maroon,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                onTap: () => _showExpenseDetail(context, expense),
              ),
            );
          }).toList(),
    );
  }

  // ===================== LOGIC =====================

  void _filterExpenses() {
    final expenses = ExpenseManager.expenses;

    setState(() {
      filteredExpenses = ExpenseManager.searchExpenses(
        expenses,
        searchController.text,
      );

      filteredExpenses =
          filteredExpenses.where((expense) {
            final matchesCategory =
                selectedCategory == 'Semua' ||
                expense.category == selectedCategory;
            return matchesCategory;
          }).toList();
    });
  }

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
      default:
        return Icons.attach_money;
    }
  }

  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0, (sum, item) => sum + item.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  String _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 'Rp 0';
    double avg =
        expenses.fold(0.0, (sum, item) => sum + item.amount) / expenses.length;
    return 'Rp ${avg.toStringAsFixed(0)}';
  }

  void _showExpenseDetail(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              expense.title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jumlah: ${expense.formattedAmount}'),
                const SizedBox(height: 8),
                Text('Kategori: ${expense.category}'),
                const SizedBox(height: 8),
                Text('Tanggal: ${expense.formattedDate}'),
                const SizedBox(height: 8),
                Text('Deskripsi: ${expense.description}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: maroon,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
