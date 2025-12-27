import '../models/expense.dart';
import 'expense_service.dart';

class ExpenseManager {
  static List<Expense> get expenses => ExpenseService.expenses;

  static Future<void> load() => ExpenseService.load();
  static Future<void> save() => ExpenseService.save();

  static Future<void> addExpense(Expense e) => ExpenseService.addExpense(e);

  static Future<void> updateExpense(String id, Expense e) =>
      ExpenseService.updateExpense(id, e);

  static Future<void> removeExpense(String id) =>
      ExpenseService.removeExpense(id);

  // ===== helpers advanced =====
  static List<Expense> searchExpenses(List<Expense> expenses, String query) {
    if (query.trim().isEmpty) return expenses;
    final q = query.toLowerCase();
    return expenses.where((e) {
      return e.title.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q);
    }).toList();
  }

  static Map<String, double> getTotalByCategory(List<Expense> expenses) {
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  static double getAverageDaily(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    final dates = expenses.map((e) => e.date).toList()..sort();
    final days = dates.last.difference(dates.first).inDays + 1;
    final total = expenses.fold<double>(0, (s, e) => s + e.amount);
    return total / days;
  }

  static Expense? getHighestExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    expenses.sort((a, b) => b.amount.compareTo(a.amount));
    return expenses.first;
  }
}
