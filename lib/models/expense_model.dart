// lib/models/expense_model.dart

import 'package:isar/isar.dart';

part 'expense_model.g.dart';

@embedded
class ExpenseItem {
  String? name;       // Nazwa edytowalna, np. "Mleko"
  String? rawId;      // Oryginalny tekst z paragonu, np. "MLEKO 3.2 UHT"
  double amount = 0.0;
  String category = 'Other'; // Kategoria tego konkretnego produktu
}

@collection
class Expense {
  Id id = Isar.autoIncrement;

  final String title;     // np. "Zakupy Biedronka"
  final double amount;    // Suma całkowita paragonu
  final String category;  // Kategoria główna paragonu (np. "Zakupy")

  @Index()
  final DateTime date;

  // Lista pozycji na paragonie. Może być null dla zwykłych wydatków.
  List<ExpenseItem>? items;

  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.items,
  });
}