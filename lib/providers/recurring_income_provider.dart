// lib/providers/recurring_expense_provider.dart

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/recurring_income_model.dart';

class RecurringIncomeProvider extends ChangeNotifier {
  final Isar isar;
  List<RecurringIncome> _templates = [];
  // Konstruktor od razu ładuje szablony
  RecurringIncomeProvider(this.isar) {
    _loadTemplates();
  }

  // Prywatna metoda ładowania
  void _loadTemplates() {
    // Sortujemy po dacie następnej płatności
    _templates = isar.recurringIncomes
        .where()
        .sortByNextDueDate()
        .findAllSync();
  }

  // Publiczny getter do odczytu przez UI
  List<RecurringIncome> get allTemplates => List.unmodifiable(_templates);

  // Metoda dodawania (już ją mamy, ale upewniamy się, że odświeży listę)
  Future<void> addRecurringIncome(RecurringIncome ri) async {
    await isar.writeTxn(() async {
      await isar.recurringIncomes.put(ri);
    });
    // Przeładuj listę i powiadom słuchaczy
    _loadTemplates();
    notifyListeners();
  }

  // NOWA METODA: Usuwanie szablonu
  Future<void> deleteRecurringIncome(int templateId) async {
    await isar.writeTxn(() async {
      await isar.recurringIncomes.delete(templateId);
    });
    // Przeładuj listę i powiadom słuchaczy
    _loadTemplates();
    notifyListeners();
  }

  Future<void> updateRecurringIncome(RecurringIncome updatedTemplate) async {
    await isar.writeTxn(() async {
      await isar.recurringIncomes.put(updatedTemplate);
    });
    _loadTemplates();
    notifyListeners();
  }
}