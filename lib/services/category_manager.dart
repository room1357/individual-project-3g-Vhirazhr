import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryManager {
  static List<Category> categories = [
    Category(
      id: '1',
      name: 'Makanan',
      color: Colors.orange,
      icon: Icons.restaurant,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '2',
      name: 'Transportasi',
      color: Colors.green,
      icon: Icons.directions_car,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '3',
      name: 'Utilitas',
      color: Colors.purple,
      icon: Icons.home,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '4',
      name: 'Hiburan',
      color: Colors.pink,
      icon: Icons.movie,
      createdAt: DateTime.now(),
    ),
    Category(
      id: '5',
      name: 'Pendidikan',
      color: Colors.blue,
      icon: Icons.school,
      createdAt: DateTime.now(),
    ),
  ];

  // Tambah kategori baru
  static void addCategory(Category newCategory) {
    categories.add(newCategory);
  }

  // Update kategori
  static void updateCategory(String id, Category updatedCategory) {
    int index = categories.indexWhere((category) => category.id == id);
    if (index != -1) {
      categories[index] = updatedCategory;
    }
  }

  // Hapus kategori
  static void removeCategory(String id) {
    categories.removeWhere((category) => category.id == id);
  }

  // Cari kategori by ID
  static Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Cek apakah nama kategori sudah ada
  static bool isCategoryNameExists(String name) {
    return categories.any(
      (category) => category.name.toLowerCase() == name.toLowerCase(),
    );
  }
}
