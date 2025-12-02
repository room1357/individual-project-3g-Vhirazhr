import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/category_manager.dart';
import 'add_category_screen.dart'; // pastikan file ini memang berisi AddEditCategoryScreen

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // ===== THEME SAMA HOME =====
  static const Color pinkBg = Color(0xFFF8D7DA);
  static const Color pinkSoft = Color(0xFFF3B8C2);
  static const Color roseDark = Color(0xFFD87A87);
  static const Color maroon = Color(0xFF451A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D1B2E);

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final allCategories = CategoryManager.categories;

    final categories =
        allCategories
            .where(
              (c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      backgroundColor: pinkBg,
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          "Categories",
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

      // ✅ BODY TANPA PATTERN / STACK
      body: Column(
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
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: darkText,
                ),
                decoration: InputDecoration(
                  hintText: "Search category...",
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

          // ===== GRID LIST =====
          Expanded(
            child:
                categories.isEmpty
                    ? _buildEmptyState(context, allCategories.isEmpty)
                    : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.92,
                          ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryGridCard(categories[index]);
                      },
                    ),
          ),
        ],
      ),

      // ===== FAB THEME HOME =====
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [roseDark, maroon],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: white.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(-3, -3),
              spreadRadius: 1,
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: null,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _navigateToAddCategory(context),
          child: const Icon(Icons.add_rounded, size: 32, color: white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ===== GRID CARD CATEGORY =====
  Widget _buildCategoryGridCard(Category category) {
    final c = category.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToEditCategory(context, category),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.withOpacity(0.95), c.withOpacity(0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: c.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // icon bubble
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: white.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(category.icon, color: white, size: 26),
                ),
              ),

              // actions (edit/delete)
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _miniAction(
                      icon: Icons.edit_rounded,
                      onTap: () => _navigateToEditCategory(context, category),
                    ),
                    const SizedBox(width: 6),
                    _miniAction(
                      icon: Icons.delete_rounded,
                      onTap: () => _showDeleteConfirmation(context, category),
                    ),
                  ],
                ),
              ),

              // title + date
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Created ${_formatDate(category.createdAt)}",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniAction({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: white.withOpacity(0.35), width: 1),
        ),
        child: Icon(icon, size: 16, color: white),
      ),
    );
  }

  // ===== EMPTY STATE =====
  Widget _buildEmptyState(BuildContext context, bool reallyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: maroon.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: pinkSoft.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  reallyEmpty
                      ? Icons.category_rounded
                      : Icons.search_off_rounded,
                  size: 40,
                  color: maroon.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                reallyEmpty ? "No categories yet" : "No match found",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                reallyEmpty
                    ? "Tap + to create your first category"
                    : "Try another keyword",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: darkText.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditCategoryScreen()),
    ).then((_) => setState(() {}));
  }

  void _navigateToEditCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCategoryScreen(category: category),
      ),
    ).then((_) => setState(() {}));
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Delete Category?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            content: Text(
              'Are you sure want to delete "${category.name}"?\nCategory that already used might not be deletable.',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: darkText.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: darkText.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  CategoryManager.removeCategory(category.id);
                  setState(() {});
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Category "${category.name}" deleted!',
                        style: const TextStyle(
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
                },
                child: const Text(
                  'Delete',
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
}
