import '../models/expense.dart';
import 'storage_service.dart';

class ExpenseService {
  static List<Expense> expenses = [];

  static Future<void> load() async {
    final raw = await StorageService.loadExpenses();
    expenses = raw.map((e) => Expense.fromMap(e)).toList();
  }

  static Future<void> save() async {
    await StorageService.saveExpenses(expenses.map((e) => e.toMap()).toList());
  }

  static Future<void> addExpense(Expense e) async {
    expenses.add(e);
    await save();
  }

  static Future<void> updateExpense(String id, Expense updated) async {
    final index = expenses.indexWhere((x) => x.id == id);
    if (index != -1) {
      expenses[index] = updated;
      await save();
    }
  }

  static Future<void> removeExpense(String id) async {
    expenses.removeWhere((x) => x.id == id);
    await save();
  }
}
