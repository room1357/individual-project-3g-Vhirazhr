import 'package:intl/intl.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'],
    title: map['title'],
    amount: (map['amount'] as num).toDouble(),
    category: map['category'],
    date: DateTime.parse(map['date']),
    description: map['description'] ?? '',
  );

  String get formattedAmount => "Rp ${amount.toStringAsFixed(0)}";
  String get formattedDate => DateFormat("dd/MM/yyyy").format(date);
}
