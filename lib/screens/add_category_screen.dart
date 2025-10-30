import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/category_manager.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category;

  const AddEditCategoryScreen({this.category, super.key});

  @override
  _AddEditCategoryScreenState createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  // List warna dan icon yang available
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category != null ? 'Edit Category' : 'Add New Category',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Color(0xFF6C63FF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.save, size: 24),
            onPressed: _saveCategory,
            tooltip: 'Save Category',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              // ← TAMBAHKAN INI
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card untuk Form Input
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Field Nama Kategori
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Category Name',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.category_rounded,
                                color: Colors.grey[600],
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
                          ),
                          SizedBox(height: 32),

                          // Pilih Warna
                          _buildSectionHeader('Choose Color'),
                          SizedBox(height: 16),
                          _buildColorGrid(),
                          SizedBox(height: 32),

                          // Pilih Icon
                          _buildSectionHeader('Choose Icon'),
                          SizedBox(height: 16),
                          _buildIconGrid(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Preview Card
                  _buildSectionHeader('Preview'),
                  SizedBox(height: 12),
                  _buildPreviewCard(),
                  SizedBox(height: 24),

                  // Tombol Simpan
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // ← KURANGI DARI 8 MENJADI 6
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _availableColors.length,
      itemBuilder: (context, index) {
        final color = _availableColors[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 40, // ← TAMBAHKAN FIXED WIDTH
            height: 40, // ← TAMBAHKAN FIXED HEIGHT
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border:
                  _selectedColor == color
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child:
                _selectedColor == color
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildIconGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // ← KURANGI DARI 6 MENJADI 5
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _availableIcons.length,
      itemBuilder: (context, index) {
        final icon = _availableIcons[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIcon = icon;
            });
          },
          child: Container(
            width: 40, // ← TAMBAHKAN FIXED WIDTH
            height: 40, // ← TAMBAHKAN FIXED HEIGHT
            decoration: BoxDecoration(
              color:
                  _selectedIcon == icon
                      ? _selectedColor.withOpacity(0.15)
                      : Colors.grey[100],
              shape: BoxShape.circle,
              border:
                  _selectedIcon == icon
                      ? Border.all(color: _selectedColor, width: 2)
                      : Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              icon,
              color: _selectedIcon == icon ? _selectedColor : Colors.grey[600],
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_selectedColor.withOpacity(0.8), _selectedColor],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(_selectedIcon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _nameController.text.isEmpty
                        ? 'Category Name'
                        : _nameController.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveCategory,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              widget.category != null ? 'UPDATE CATEGORY' : 'SAVE CATEGORY',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
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
            style: TextStyle(fontWeight: FontWeight.w500),
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
