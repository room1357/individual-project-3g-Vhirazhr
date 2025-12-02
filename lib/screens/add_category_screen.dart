import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/category_manager.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category;

  const AddEditCategoryScreen({this.category, super.key});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  // ===== COLOR THEME (SAMA HOME) =====
  static const Color pinkBg = Color(0xFFF8D7DA);
  static const Color pinkSoft = Color(0xFFF3B8C2);
  static const Color roseDark = Color(0xFFD87A87);
  static const Color maroon = Color(0xFF451A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D1B2E);
  static const Color patternBg = Color(0xFFFEF7F8);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  Color _selectedColor = roseDark;
  IconData _selectedIcon = Icons.category_rounded;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.home,
    Icons.movie,
    Icons.school,
    Icons.shopping_cart,
    Icons.medical_services,
    Icons.fitness_center,
    Icons.spa,
    Icons.card_giftcard,
    Icons.flight,
    Icons.hotel,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.music_note,
    Icons.sports_esports,
    Icons.book,
    Icons.computer,
    Icons.phone,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.local_gas_station,
    Icons.directions_bus,
    Icons.directions_subway,
    Icons.train,
    Icons.bike_scooter,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedColor = widget.category!.color;
      _selectedIcon = widget.category!.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Scaffold(
      backgroundColor: pinkBg,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Category' : 'Add Category',
          style: const TextStyle(
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
              onPressed: _saveCategory,
            ),
          ),
        ],
      ),

      // ✅ BODY TANPA PATTERN / STACK
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== FORM CARD =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: maroon.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Category Name"),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "e.g. Food, Transport...",
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: darkText.withOpacity(0.4),
                        ),
                        filled: true,
                        fillColor: patternBg,
                        prefixIcon: Icon(
                          Icons.category_rounded,
                          color: maroon.withOpacity(0.6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: roseDark.withOpacity(0.8),
                            width: 1.3,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category name is required';
                        }
                        if (widget.category == null &&
                            CategoryManager.isCategoryNameExists(value)) {
                          return 'Category name already exists';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 22),

                    _sectionTitle("Choose Color"),
                    const SizedBox(height: 10),
                    Text(
                      "Tap one to select",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: darkText.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildColorGrid(),

                    const SizedBox(height: 22),

                    _sectionTitle("Choose Icon"),
                    const SizedBox(height: 10),
                    Text(
                      "Pick an icon for your category",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: darkText.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildIconGrid(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            _sectionTitle("Preview"),
            const SizedBox(height: 10),
            _buildPreviewCard(),

            const SizedBox(height: 18),

            _buildSaveButton(isEdit),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: darkText,
        letterSpacing: 0.2,
      ),
    );
  }

  // ===== COLOR GRID =====
  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _availableColors.length,
      itemBuilder: (context, index) {
        final color = _availableColors[index];
        final selected = _selectedColor == color;

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => setState(() => _selectedColor = color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? white : white.withOpacity(0.7),
                width: selected ? 3 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(selected ? 0.5 : 0.25),
                  blurRadius: selected ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child:
                selected
                    ? const Center(
                      child: Icon(Icons.check, color: white, size: 16),
                    )
                    : null,
          ),
        );
      },
    );
  }

  // ===== ICON GRID =====
  Widget _buildIconGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _availableIcons.length,
      itemBuilder: (context, index) {
        final icon = _availableIcons[index];
        final selected = _selectedIcon == icon;

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => setState(() => _selectedIcon = icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected ? _selectedColor.withOpacity(0.18) : patternBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? _selectedColor : Colors.grey.shade300,
                width: selected ? 2.2 : 1,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: _selectedColor.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Icon(
              icon,
              color: selected ? _selectedColor : darkText.withOpacity(0.6),
              size: 20,
            ),
          ),
        );
      },
    );
  }

  // ===== PREVIEW CARD =====
  Widget _buildPreviewCard() {
    final previewName =
        _nameController.text.isEmpty ? "Category Name" : _nameController.text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_selectedColor.withOpacity(0.85), _selectedColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: white.withOpacity(0.35), width: 2),
            ),
            child: Icon(_selectedIcon, color: white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Preview",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  previewName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== SAVE BUTTON =====
  Widget _buildSaveButton(bool isEdit) {
    return SizedBox(
      width: double.infinity,
      height: 58,
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
          onPressed: _saveCategory,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save_rounded, color: white, size: 20),
              const SizedBox(width: 8),
              Text(
                isEdit ? "UPDATE CATEGORY" : "SAVE CATEGORY",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
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

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final newCategory = Category(
        id:
            widget.category?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        color: _selectedColor,
        icon: _selectedIcon,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
      );

      if (widget.category != null) {
        CategoryManager.updateCategory(widget.category!.id, newCategory);
      } else {
        CategoryManager.addCategory(newCategory);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.category != null
                ? 'Category updated successfully!'
                : 'Category added successfully!',
            style: const TextStyle(
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
    _nameController.dispose();
    super.dispose();
  }
}
