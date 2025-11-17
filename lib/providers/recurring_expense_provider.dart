// lib/providers/recurring_expense_provider.dart

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/recurring_expense_model.dart';

class RecurringExpenseProvider extends ChangeNotifier {
  final Isar isar;

  RecurringExpenseProvider(this.isar);

  // Na razie ten provider będzie miał tylko jedną funkcję: dodawanie
  Future<void> addRecurringExpense(RecurringExpense re) async {
    await isar.writeTxn(() async {
      await isar.recurringExpenses.put(re);
    });
    // Nie musimy tu robić notifyListeners, bo to tylko szablon,
    // nie wpływa od razu na UI (zrobi to ExpensesState)
  }
}