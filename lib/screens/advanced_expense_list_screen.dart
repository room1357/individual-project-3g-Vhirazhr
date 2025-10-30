import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_manager.dart';
import 'add_expense_screen.dart'; // IMPORT INI
import 'edit_expense_screen.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  _AdvancedExpenseListScreenState createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  List<Expense> expenses = ExpenseManager.expenses;
  List<Expense> filteredExpenses = [];
  String selectedCategory = 'Semua';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredExpenses = expenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengeluaran Advanced'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengeluaran...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filterExpenses();
              },
            ),
          ),

          // Category filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children:
                  [
                        'Semua',
                        'Makanan',
                        'Transportasi',
                        'Utilitas',
                        'Hiburan',
                        'Pendidikan',
                      ]
                      .map(
                        (category) => Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = category;
                                _filterExpenses();
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

          // Statistics summary
          Expanded(
            child: ListView(
              children: [
                // Statistik umum - DIUBAH
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    children: [
                      // Baris pertama
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildEnhancedStatItem(
                            'Total',
                            _calculateTotal(filteredExpenses),
                            Icons.account_balance_wallet,
                            Colors.blue,
                          ),
                          _buildEnhancedStatItem(
                            'Jumlah',
                            '${filteredExpenses.length} item',
                            Icons.list_alt,
                            Colors.green,
                          ),
                          _buildEnhancedStatItem(
                            'Rata-rata',
                            _calculateAverage(filteredExpenses),
                            Icons.bar_chart,
                            Colors.orange,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Baris kedua
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildEnhancedStatItem(
                            'Harian (Avg)',
                            'Rp ${ExpenseManager.getAverageDaily(filteredExpenses).toStringAsFixed(0)}',
                            Icons.calendar_today,
                            Colors.purple,
                          ),
                          _buildEnhancedStatItem(
                            'Tertinggi',
                            ExpenseManager.getHighestExpense(
                                      filteredExpenses,
                                    ) !=
                                    null
                                ? ExpenseManager.getHighestExpense(
                                  filteredExpenses,
                                )!.formattedAmount
                                : 'Rp 0',
                            Icons.arrow_upward,
                            Colors.red,
                          ),
                          Container(width: 100),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(),

                // 1. Total per kategori
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total per Kategori:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      ...ExpenseManager.getTotalByCategory(
                        filteredExpenses,
                      ).entries.map(
                        (entry) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                "Rp ${entry.value.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 16,
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

                Divider(),

                // List pengeluaran - DIUBAH onTap-nya
                filteredExpenses.isEmpty
                    ? Center(child: Text('Tidak ada pengeluaran ditemukan'))
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(
                                expense.category,
                              ),
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(expense.title),
                            subtitle: Text(
                              '${expense.category} • ${expense.formattedDate}',
                            ),
                            trailing: Text(
                              expense.formattedAmount,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                            ),
                            onTap:
                                () => _showExpenseOptions(
                                  context,
                                  expense,
                                ), // DIUBAH
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
      // TAMBAHKAN FLOATING ACTION BUTTON INI
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate ke AddExpenseScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          ).then((_) {
            // Refresh data setelah kembali dari add screen
            setState(() {
              _filterExpenses();
            });
          });
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  void _filterExpenses() {
    setState(() {
      filteredExpenses = ExpenseManager.searchExpenses(
        expenses,
        searchController.text,
      );

      // Filter kategori juga
      filteredExpenses =
          filteredExpenses.where((expense) {
            bool matchesCategory =
                selectedCategory == 'Semua' ||
                expense.category == selectedCategory;
            return matchesCategory;
          }).toList();
    });
  }

  // Widget statistik yang ditingkatkan - DIUBAH
  Widget _buildEnhancedStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Warna kategori - TIDAK DIUBAH
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

  // Icon kategori - TIDAK DIUBAH
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

  // Hitung total semua pengeluaran - TIDAK DIUBAH
  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0, (sum, item) => sum + item.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  // Hitung rata-rata pengeluaran - TIDAK DIUBAH
  String _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 'Rp 0';
    double avg =
        expenses.fold(0.0, (sum, item) => sum + item.amount) / expenses.length;
    return 'Rp ${avg.toStringAsFixed(0)}';
  }

  // Method untuk menampilkan opsi (Edit/Hapus) dalam dialog - METHOD BARU
  void _showExpenseOptions(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(expense.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jumlah: ${expense.formattedAmount}'),
                SizedBox(height: 8),
                Text('Kategori: ${expense.category}'),
                SizedBox(height: 8),
                Text('Tanggal: ${expense.formattedDate}'),
                SizedBox(height: 8),
                Text('Deskripsi: ${expense.description}'),
              ],
            ),
            actions: [
              // Tombol Hapus
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  _showDeleteConfirmation(
                    context,
                    expense,
                  ); // Tampilkan konfirmasi hapus
                },
                child: Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
              // Tombol Edit
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  // Navigate ke EditExpenseScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditExpenseScreen(expense: expense),
                    ),
                  ).then((_) {
                    // Refresh data setelah kembali dari edit screen
                    setState(() {
                      _filterExpenses();
                    });
                  });
                },
                child: Text('Edit', style: TextStyle(color: Colors.blue)),
              ),
              // Tombol Tutup
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
            ],
          ),
    );
  }

  // Method untuk konfirmasi hapus - METHOD BARU
  void _showDeleteConfirmation(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Hapus Pengeluaran?'),
            content: Text(
              'Apakah Anda yakin ingin menghapus "${expense.title}"? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  // Hapus dari ExpenseManager
                  ExpenseManager.removeExpense(expense.id);

                  // Refresh filtered expenses
                  setState(() {
                    _filterExpenses();
                  });

                  // Tampilkan snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${expense.title}" berhasil dihapus!'),
                      backgroundColor: Colors.red,
                    ),
                  );

                  // Kembali ke previous screen
                  Navigator.pop(context); // Tutup dialog konfirmasi
                },
                child: Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
