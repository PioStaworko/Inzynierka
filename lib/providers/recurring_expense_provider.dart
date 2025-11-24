import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../data/app_database.dart' as db;

class RecurringExpenseProvider extends ChangeNotifier {
  final db.RecurringDao dao;
  final db.CategoriesDao categoriesDao;
  List<db.RecurringExpense> _templates = [];

  RecurringExpenseProvider(this.dao, this.categoriesDao) {
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    _templates = await dao.getRecurringExpenses();
    notifyListeners();
  }

  List<db.RecurringExpense> get allTemplates => List.unmodifiable(_templates);

  // Dodawanie
  Future<void> addRecurringExpense(String title, double amount, String category, String frequency, DateTime nextDate) async {
    // Resolve category name -> id (create if missing)
    final allCats = await categoriesDao.getAllCategories();
    db.Category? existing;
    try {
      existing = allCats.firstWhere((c) => c.name == category);
    } catch (_) {
      existing = null;
    }
    int? catId = existing?.id;
    if (catId == null) {
      await categoriesDao.insertCategory(db.CategoriesCompanion.insert(name: category, type: 'expense', colorValue: 4286578816));
      final refreshed = await categoriesDao.getAllCategories();
      try {
        catId = refreshed.firstWhere((c) => c.name == category).id;
      } catch (_) {
        catId = null;
      }
    }

    final entry = db.RecurringExpensesCompanion.insert(
      title: title,
      amount: amount,
      categoryId: drift.Value(catId),
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
  Future<void> updateRecurringExpenseByFields(int id, String title, double amount, String category, String frequency, DateTime nextDate) async {
    final allCats = await categoriesDao.getAllCategories();
    db.Category? existing;
    try {
      existing = allCats.firstWhere((c) => c.name == category);
    } catch (_) {
      existing = null;
    }
    int? catId = existing?.id;
    if (catId == null) {
      await categoriesDao.insertCategory(db.CategoriesCompanion.insert(name: category, type: 'expense', colorValue: 4286578816));
      final refreshed = await categoriesDao.getAllCategories();
      try {
        catId = refreshed.firstWhere((c) => c.name == category).id;
      } catch (_) {
        catId = null;
      }
    }

    final entry = db.RecurringExpensesCompanion(
      id: drift.Value(id),
      title: drift.Value(title),
      amount: drift.Value(amount),
      categoryId: drift.Value(catId),
      frequency: drift.Value(frequency),
      nextDueDate: drift.Value(nextDate),
    );
    await dao.updateRecurringExpense(entry);
    _loadTemplates();
  }
}