import 'package:flutter/material.dart';

import '../models/category.dart';
import 'storage_service.dart';

class CategoryService {
  static List<Category> categories = [];

  static final List<Category> _defaultCategories = [
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

  static Future<void> load() async {
    final raw = await StorageService.loadCategories();

    if (raw.isEmpty) {
      categories = [..._defaultCategories];
      await save(); // simpan default biar next launch ga kosong
    } else {
      categories = raw.map((e) => Category.fromMap(e)).toList();
    }
  }

  static Future<void> save() async {
    await StorageService.saveCategories(
      categories.map((c) => c.toMap()).toList(),
    );
  }

  static Future<void> addCategory(Category c) async {
    categories.add(c);
    await save();
  }

  static Future<void> updateCategory(String id, Category c) async {
    final index = categories.indexWhere((x) => x.id == id);
    if (index != -1) {
      categories[index] = c;
      await save();
    }
  }

  static Future<void> removeCategory(String id) async {
    categories.removeWhere((x) => x.id == id);
    await save();
  }

  static Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((x) => x.id == id);
    } catch (_) {
      return null;
    }
  }

  static bool isCategoryNameExists(String name, {String? exceptId}) {
    return categories.any((c) {
      final sameName = c.name.toLowerCase() == name.toLowerCase();
      final notExcept = exceptId == null || c.id != exceptId;
      return sameName && notExcept;
    });
  }
}
