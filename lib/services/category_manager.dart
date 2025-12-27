import '../models/category.dart';
import 'category_service.dart';

class CategoryManager {
  static List<Category> get categories => CategoryService.categories;

  static Future<void> load() => CategoryService.load();
  static Future<void> save() => CategoryService.save();

  static Future<void> addCategory(Category c) => CategoryService.addCategory(c);

  static Future<void> updateCategory(String id, Category c) =>
      CategoryService.updateCategory(id, c);

  static Future<void> removeCategory(String id) =>
      CategoryService.removeCategory(id);

  static Category? getCategoryById(String id) =>
      CategoryService.getCategoryById(id);

  static bool isCategoryNameExists(String name, {String? exceptId}) =>
      CategoryService.isCategoryNameExists(name, exceptId: exceptId);
}
