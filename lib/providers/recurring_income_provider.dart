import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../data/app_database.dart';

class RecurringIncomeProvider extends ChangeNotifier {
  final RecurringDao dao;
  List<RecurringIncome> _templates = [];

  RecurringIncomeProvider(this.dao) {
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    _templates = await dao.getRecurringIncomes();
    notifyListeners();
  }

  List<RecurringIncome> get allTemplates => List.unmodifiable(_templates);

  Future<void> addRecurringIncome(String title, double amount, String source, String frequency, DateTime nextDate) async {
    final entry = RecurringIncomesCompanion.insert(
      title: title,
      amount: amount,
      source: source,
      frequency: frequency,
      nextDueDate: nextDate,
    );
    await dao.addRecurringIncome(entry);
    _loadTemplates();
  }

  Future<void> deleteRecurringIncome(int templateId) async {
    await dao.deleteRecurringIncome(templateId);
    _loadTemplates();
  }

  Future<void> updateRecurringIncome(RecurringIncome item) async {
    final entry = RecurringIncomesCompanion(
      id: drift.Value(item.id),
      title: drift.Value(item.title),
      amount: drift.Value(item.amount),
      source: drift.Value(item.source),
      frequency: drift.Value(item.frequency),
      nextDueDate: drift.Value(item.nextDueDate),
    );
    await dao.updateRecurringIncome(entry);
    _loadTemplates();
  }
}