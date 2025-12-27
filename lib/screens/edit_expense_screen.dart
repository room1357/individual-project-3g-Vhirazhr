import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/category_manager.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  // ===== THEME SAMA HOME =====
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
    if (CategoryManager.categories.isEmpty) {
      return ['Makanan'];
    }
    return CategoryManager.categories.map((c) => c.name).toList();
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.expense.title;
    _amountController.text = widget.expense.amount.toStringAsFixed(0);
    _descriptionController.text = widget.expense.description;
    _selectedCategory = widget.expense.category;
    _selectedDate = widget.expense.date;

    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory =
          _categories.isNotEmpty ? _categories.first : 'Makanan';
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
          'Edit Expense',
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
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: "Save",
              icon: const Icon(Icons.save_rounded, size: 22),
              onPressed: _updateExpense,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: "Delete",
              icon: const Icon(Icons.delete_rounded, size: 22),
              onPressed: _deleteExpense,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeroHeader(),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                  border: Border.all(color: maroon.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  ? "Judul wajib diisi"
                                  : null,
                      onChanged: (_) => setState(() {}),
                    ),

                    _softDivider(),

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
                        if (v == null || v.isEmpty) return "Jumlah wajib diisi";
                        if (double.tryParse(v) == null) {
                          return "Masukkan angka valid";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    _softDivider(),

                    _sectionTitle("Kategori"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: _inputDecoration(
                        hint: "Pilih kategori",
                        icon: Icons.category_rounded,
                      ),
                      items:
                          _categories.map((category) {
                            final categoryObj = CategoryManager.categories
                                .firstWhere(
                                  (c) => c.name == category,
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
                                  Icon(
                                    categoryObj.icon,
                                    color: categoryObj.color,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        if (newValue == null) return;
                        setState(() => _selectedCategory = newValue);
                      },
                    ),

                    _softDivider(),

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
                                  fontSize: 14,
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

                    _softDivider(),

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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildUpdateButton(),
              const SizedBox(height: 10),
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI SECTIONS =================

  Widget _buildHeroHeader() {
    final categoryColor = _getCategoryColor(_selectedCategory);
    final icon = _getCategoryIcon(_selectedCategory);
    final title =
        _titleController.text.isEmpty
            ? widget.expense.title
            : _titleController.text;
    final amount =
        _amountController.text.isEmpty
            ? widget.expense.formattedAmount
            : "Rp ${_amountController.text}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [categoryColor.withOpacity(0.95), maroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: white.withOpacity(0.35), width: 1.6),
            ),
            child: Icon(icon, color: white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedCategory,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _softDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, thickness: 1, color: maroon.withOpacity(0.06)),
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: darkText,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
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
          onPressed: _updateExpense,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, size: 20, color: white),
              SizedBox(width: 8),
              Text(
                'UPDATE PENGELUARAN',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: white,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _deleteExpense,
        icon: const Icon(Icons.delete_rounded, size: 18),
        label: const Text(
          "HAPUS PENGELUARAN",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            fontSize: 13.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: white,
        ),
      ),
    );
  }

  // =================== LOGIC (SERVICE) ===================

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

  Future<void> _updateExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Jumlah tidak valid")));
      return;
    }

    final updatedExpense = Expense(
      id: widget.expense.id,
      title: _titleController.text.trim(),
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
    );

    await ExpenseService.updateExpense(widget.expense.id, updatedExpense);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Pengeluaran berhasil diupdate!',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context, true);
  }

  Future<void> _deleteExpense() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Hapus Pengeluaran?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus "${widget.expense.title}"?\nTindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: darkText.withOpacity(0.8),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: darkText.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await ExpenseService.removeExpense(widget.expense.id);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Pengeluaran berhasil dihapus!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );

                  Navigator.pop(context); // tutup dialog
                  Navigator.pop(context, true); // balik + refresh
                },
                child: const Text(
                  'Hapus',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
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

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
