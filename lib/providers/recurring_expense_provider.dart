// lib/providers/recurring_expense_provider.dart

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/recurring_expense_model.dart';

class RecurringExpenseProvider extends ChangeNotifier {
  final Isar isar;
  List<RecurringExpense> _templates = [];

  // Konstruktor od razu ładuje szablony
  RecurringExpenseProvider(this.isar) {
    _loadTemplates();
  }

  // Prywatna metoda ładowania
  void _loadTemplates() {
    // Sortujemy po dacie następnej płatności
    _templates = isar.recurringExpenses
        .where()
        .sortByNextDueDate()
        .findAllSync();
  }

  // Publiczny getter do odczytu przez UI
  List<RecurringExpense> get allTemplates => List.unmodifiable(_templates);

  // Metoda dodawania (już ją mamy, ale upewniamy się, że odświeży listę)
  Future<void> addRecurringExpense(RecurringExpense re) async {
    await isar.writeTxn(() async {
      await isar.recurringExpenses.put(re);
    });
    // Przeładuj listę i powiadom słuchaczy
    _loadTemplates();
    notifyListeners();
  }

  // NOWA METODA: Usuwanie szablonu
  Future<void> deleteRecurringExpense(int templateId) async {
    await isar.writeTxn(() async {
      await isar.recurringExpenses.delete(templateId);
    });
    // Przeładuj listę i powiadom słuchaczy
    _loadTemplates();
    notifyListeners();
  }
}