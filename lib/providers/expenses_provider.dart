// lib/providers/expenses_provider.dart

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/expense_model.dart';

class ExpensesState extends ChangeNotifier {
  final Isar isar;
  List<Expense> _expenses = []; // Lista nie jest już 'final'

  // Konstruktor przyjmuje Isar i od razu ładuje dane
  ExpensesState(this.isar) {
    _loadExpenses();
  }

  // PRYWATNA METODA DO WCZYTYWANIA DANYCH
  // Używamy .findAllSync() - to operacja synchroniczna,
  // idealna do załadowania stanu przy starcie providera.
  void _loadExpenses() {
    _expenses = isar.expenses.where().findAllSync();
    // Nie trzeba 'notifyListeners()', bo to się dzieje w konstruktorze
  }

  // PUBLICZNE GETTERY (działają tak jak wcześniej)
  List<Expense> get recent => List.unmodifiable(_expenses.reversed);

  Map<String, double> get totalsByCategory {
    final map = <String, double>{};
    for (var e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  // PUBLICZNA METODA DO DODAWANIA (TERAZ ASYNCHRONICZNA)
  Future<void> addExpense(Expense e) async {
    // 1. Zapisz do bazy danych (operacja asynchroniczna)
    await isar.writeTxn(() async {
      await isar.expenses.put(e);
    });

    // 2. Zaktualizuj stan lokalny
    _expenses.add(e);

    // 3. Powiadom widżety o zmianie
    notifyListeners();
  }

  Future<void> deleteExpense(int expenseId) async {
    // 1. Usuń z bazy danych
    await isar.writeTxn(() async {
      await isar.expenses.delete(expenseId);
    });

    // 2. Zaktualizuj stan lokalny (przeładuj z bazy)
    _loadExpenses();
    notifyListeners();
  }
  // ======================================
}