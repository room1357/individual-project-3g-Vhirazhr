import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/category_manager.dart';
import '../services/expense_manager.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  // ===== THEME SAMA HOME =====
  static const Color pinkBg = Color(0xFFF8D7DA);
  static const Color pinkSoft = Color(0xFFF3B8C2);
  static const Color roseDark = Color(0xFFD87A87);
  static const Color maroon = Color(0xFF451A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D1B2E);
  static const Color patternBg = Color(0xFFFEF7F8); // soft bg, bukan pattern

  // Controller untuk form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Makanan';
  DateTime _selectedDate = DateTime.now();

  // List kategori dari manager
  List<String> get _categories {
    if (CategoryManager.categories.isEmpty) {
      return ['Makanan'];
    }
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
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    return Scaffold(
      backgroundColor: pinkBg,
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'Add Expense',
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: "Save",
              icon: const Icon(Icons.save_rounded, size: 22),
              onPressed: _saveExpense,
            ),
          ),
        ],
      ),

      // ✅ BODY TANPA PATTERN
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
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
                  icon: Icons.attach_money_rounded,
                ),
                style: _inputTextStyle(),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return "Jumlah tidak boleh kosong";
                  if (double.tryParse(v) == null) return "Masukkan angka valid";
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _sectionTitle("Kategori"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration(
                  hint: "Pilih kategori",
                  icon: Icons.category_rounded,
                ),
                items:
                    _categories.map((category) {
                      final categoryObj = CategoryManager.categories.firstWhere(
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
                            Icon(categoryObj.icon, color: categoryObj.color),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
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
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: patternBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: maroon.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: maroon.withOpacity(0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dateText,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: darkText,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: maroon.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),
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
              const SizedBox(height: 22),

              // BUTTON SAVE
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [roseDark, maroon],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: maroon.withOpacity(0.35),
                        blurRadius: 18,
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
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'SIMPAN PENGELUARAN',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.5,
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
    );
  }

  // ================== UI HELPERS ==================

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: darkText,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  TextStyle _inputTextStyle() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: darkText,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Poppins',
        color: darkText.withOpacity(0.45),
        fontSize: 13,
      ),
      filled: true,
      fillColor: patternBg,
      prefixIcon: Icon(icon, color: maroon.withOpacity(0.65), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: roseDark.withOpacity(0.9), width: 1.4),
      ),
    );
  }

  // ================== LOGIC ==================

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: maroon,
              onPrimary: white,
              onSurface: darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final newExpense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text,
      );

      ExpenseManager.addExpense(newExpense);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Pengeluaran berhasil ditambahkan!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
