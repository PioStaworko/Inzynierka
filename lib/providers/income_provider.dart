// lib/providers/income_provider.dart

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/income_model.dart';

class IncomeProvider extends ChangeNotifier {
  final Isar isar;
  List<Income> _incomes = [];

  IncomeProvider(this.isar) {
    _loadIncomes();
  }

  void _loadIncomes() {
    _incomes = isar.incomes.where().findAllSync();
  }

  List<Income> get allIncomes => List.unmodifiable(_incomes);
  
  // Prosty getter do obliczania sumy przychodów
  double get totalIncome {
    return _incomes.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> addIncome(Income income) async {
    await isar.writeTxn(() async {
      await isar.incomes.put(income);
    });
    _incomes.add(income);
    notifyListeners();
  }
}