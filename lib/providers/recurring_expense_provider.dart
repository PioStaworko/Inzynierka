import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../data/app_database.dart';

class RecurringExpenseProvider extends ChangeNotifier {
  final RecurringDao dao;
  List<RecurringExpense> _templates = [];

  RecurringExpenseProvider(this.dao) {
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    _templates = await dao.getRecurringExpenses();
    notifyListeners();
  }

  List<RecurringExpense> get allTemplates => List.unmodifiable(_templates);

  // Dodawanie
  Future<void> addRecurringExpense(String title, double amount, String category, String frequency, DateTime nextDate) async {
    final entry = RecurringExpensesCompanion.insert(
      title: title,
      amount: amount,
      category: category,
      frequency: frequency,
      nextDueDate: nextDate,
    );
    await dao.addRecurringExpense(entry);
    _loadTemplates();
  }

  // Usuwanie
  Future<void> deleteRecurringExpense(int templateId) async {
    await dao.deleteRecurringExpense(templateId);
    _loadTemplates();
  }

  // Aktualizacja
  Future<void> updateRecurringExpense(RecurringExpense item) async {
    final entry = RecurringExpensesCompanion(
      id: drift.Value(item.id),
      title: drift.Value(item.title),
      amount: drift.Value(item.amount),
      category: drift.Value(item.category),
      frequency: drift.Value(item.frequency),
      nextDueDate: drift.Value(item.nextDueDate),
    );
    await dao.updateRecurringExpense(entry);
    _loadTemplates();
  }
}