import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/category_manager.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  // ===== THEME =====
  static const Color pinkBg = Color(0xFFF8D7DA);
  static const Color pinkSoft = Color(0xFFF3B8C2);
  static const Color roseDark = Color(0xFFD87A87);
  static const Color maroon = Color(0xFF451A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D1B2E);
  static const Color patternBg = Color(0xFFFEF7F8);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Makanan';
  DateTime _selectedDate = DateTime.now();

  List<String> get _categories {
    if (CategoryManager.categories.isEmpty) return ['Makanan'];
    return CategoryManager.categories.map((cat) => cat.name).toList();
  }

  @override
  void initState() {
    super.initState();
    if (CategoryManager.categories.isNotEmpty) {
      _selectedCategory = CategoryManager.categories.first.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';

    return Scaffold(
      backgroundColor: pinkBg,
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            fontSize: 19,
          ),
        ),
        backgroundColor: maroon,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _saveExpense,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.save_rounded, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            children: [
              _headerCard(),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: maroon.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: maroon.withOpacity(0.06)),
                ),
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _sectionTitle("Judul Pengeluaran"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration(
                          hint: "Contoh: Makan siang",
                          icon: Icons.title_rounded,
                        ),
                        style: _inputTextStyle(),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty)
                                    ? "Judul tidak boleh kosong"
                                    : null,
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle("Jumlah (Rp)"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          hint: "Contoh: 25000",
                          icon: Icons.payments_rounded,
                        ),
                        style: _inputTextStyle(),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Jumlah tidak boleh kosong";
                          }
                          if (double.tryParse(v) == null) {
                            return "Masukkan angka valid";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle("Kategori"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: _inputDecoration(
                          hint: "Pilih kategori",
                          icon: Icons.category_rounded,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        dropdownColor: white,
                        items:
                            _categories.map((category) {
                              final categoryObj = CategoryManager.categories
                                  .firstWhere(
                                    (cat) => cat.name == category,
                                    orElse:
                                        () => Category(
                                          id: '',
                                          name: category,
                                          color: Colors.grey,
                                          icon: Icons.attach_money,
                                          createdAt: DateTime.now(),
                                        ),
                                  );

                              return DropdownMenuItem<String>(
                                value: category,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: categoryObj.color.withOpacity(
                                          0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        categoryObj.icon,
                                        color: categoryObj.color,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: darkText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _selectedCategory = v);
                        },
                      ),
                      const SizedBox(height: 14),
                      _sectionTitle("Tanggal"),
                      const SizedBox(height: 8),
                      _dateField(dateText),
                      const SizedBox(height: 14),
                      _sectionTitle("Deskripsi (Opsional)"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          hint: "Tambahkan catatan",
                          icon: Icons.description_rounded,
                        ),
                        style: _inputTextStyle(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [roseDark, maroon],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: maroon.withOpacity(0.30),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _saveExpense,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'SIMPAN PENGELUARAN',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.2,
                                fontWeight: FontWeight.w700,
                                color: white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: patternBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.add_chart_rounded, color: maroon),
          SizedBox(width: 8),
          Text("Tambah Pengeluaran"),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  TextStyle _inputTextStyle() => const TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    color: darkText,
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: patternBg,
      prefixIcon: Icon(icon, color: maroon, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _dateField(String dateText) {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: _inputDecoration(
          hint: "Pilih tanggal",
          icon: Icons.calendar_today_rounded,
        ),
        child: Text(dateText),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // LOGIC aman
  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedAmount = double.tryParse(_amountController.text.trim());
    if (parsedAmount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Jumlah tidak valid")));
      return;
    }

    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: parsedAmount,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
    );

    await ExpenseService.addExpense(newExpense);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pengeluaran berhasil ditambahkan!")),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
