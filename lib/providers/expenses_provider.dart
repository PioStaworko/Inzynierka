import 'package:flutter/foundation.dart' show ChangeNotifier, kDebugMode;
import 'package:drift/drift.dart' as drift;
import '../data/app_database.dart'; 
import '../services/notification_service.dart'; // Dodaj import serwisu

class ExpensesState extends ChangeNotifier {
  final ExpensesDao dao;
  final BudgetsDao budgetsDao;
  final CategoriesDao categoriesDao;
  

  List<ExpenseWithItems> _expenses = [];

  final Map<String, double> _pendingBudgetDeltas = {};

  ExpensesState(this.dao, this.budgetsDao, this.categoriesDao, {bool startListening = true}) {
    if (startListening) {
      _init();
      _loadCategoryCache();
    } else {
      _loadCategoryCache();
    }
  }

  void start() {
    _init();
    _loadCategoryCache();
  }
  final Map<int, String> _categoryCache = {};

  Future<void> _loadCategoryCache() async {
    final all = await categoriesDao.getAllCategories();
    _categoryCache.clear();
    for (final c in all) {
      _categoryCache[c.id] = c.name;
    }
  }

  void _init() {
    dao.watchRecentExpenses().listen((data) {
      _expenses = data;
      notifyListeners();
    });
  }

  List<ExpenseWithItems> get recent => _expenses;
  Map<String, double> get totalsByCategory {
    final map = <String, double>{};
    
    for (var entry in _expenses) {
      if (entry.items.isNotEmpty) {
        for (var item in entry.items) {
          String catName;
          if (item.categoryId != null) {
            catName = _categoryCache[item.categoryId] ?? 'Inne';
          } else if (entry.expense.categoryId != null) {
            catName = _categoryCache[entry.expense.categoryId] ?? 'Inne';
          } else {
            catName = 'Inne';
          }
          map[catName] = (map[catName] ?? 0) + item.amount;
        }
      } else {
        final catName = entry.expense.categoryId != null
            ? (_categoryCache[entry.expense.categoryId] ?? 'Inne')
            : 'Inne';
        map[catName] = (map[catName] ?? 0) + entry.expense.amount;
      }
    }
    return map;
  }

  Future<void> addExpense({
    required String title, 
    required double amount, 
    required DateTime date, 
    required String category,
    List<ExpenseItemsCompanion>? items,
  }) async {
    final allCats = await categoriesDao.getAllCategories();
    Category? existing;
    try {
      existing = allCats.firstWhere((c) => c.name == category);
    } catch (_) {
      existing = null;
    }
    int? catId = existing?.id;
    if (catId == null) {
      await categoriesDao.insertCategory(CategoriesCompanion.insert(name: category, type: 'expense', colorValue: 4286578816));
      final refreshed = await categoriesDao.getAllCategories();
      try {
        catId = refreshed.firstWhere((c) => c.name == category).id;
      } catch (_) {
        catId = null;
      }
      
      if (catId != null) _categoryCache[catId] = category;
    }

    final expenseCompanion = ExpensesCompanion.insert(
      title: title,
      amount: amount,
      date: date,
      categoryId: drift.Value(catId),
    );
    await dao.insertExpenseWithItems(expenseCompanion, items ?? []);
    _pendingBudgetDeltas[category] = (_pendingBudgetDeltas[category] ?? 0) + amount;
  }

  Future<void> _checkBudgets(String category, double addedAmount) async {
    try {
      
      final budgets = await budgetsDao.getBudgetsForCategory(category);

      for (final budget in budgets) {
        try {
          
          final currentSpent = await budgetsDao.getSpendingForBudget(budget);
          final previousSpent = currentSpent - addedAmount; 

          final limit = budget.amountLimit;

          
          _checkThreshold(50, previousSpent, currentSpent, limit, budget);
          _checkThreshold(80, previousSpent, currentSpent, limit, budget);
          _checkThreshold(100, previousSpent, currentSpent, limit, budget);
        } catch (e, st) {
          
          if (kDebugMode) {
            
            print('Błąd podczas sprawdzania budżetu ${budget.id}: $e\n$st');
          }
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        
        print('Błąd podczas pobierania budżetów dla kategorii $category: $e\n$st');
      }
    }
  }

  void _checkThreshold(int percent, double oldSpent, double newSpent, double limit, Budget budget) {
    final thresholdAmount = limit * (percent / 100);
    
   
    if (oldSpent < thresholdAmount && newSpent >= thresholdAmount) {
      final catName = budget.categoryId != null ? (_categoryCache[budget.categoryId] ?? 'Inne') : 'Inne';
      NotificationService().showNotification(
        budget.id * 100 + percent,
        'Uwaga! Budżet: $catName',
        'Wykorzystano $percent% budżetu (${budget.period}). Wydano: ${newSpent.toStringAsFixed(2)} zł z ${limit.toStringAsFixed(2)} zł.',
      );
    }
  }

  
  Future<void> processPendingBudgetChecks() async {
    if (_pendingBudgetDeltas.isEmpty) return;
    final work = Map<String, double>.from(_pendingBudgetDeltas);
    _pendingBudgetDeltas.clear();
    for (final entry in work.entries) {
      try {
        await _checkBudgets(entry.key, entry.value);
      } catch (e, st) {
        if (kDebugMode) {
         
          print('Error processing pending budget for ${entry.key}: $e\n$st');
        }
      }
    }
  }


  Future<void> deleteExpense(int id) async {
    await dao.deleteExpense(id);
  }

  Future<void> updateExpense(Expense expense) async {

    final companion = ExpensesCompanion(
      id: drift.Value(expense.id),
      title: drift.Value(expense.title),
      amount: drift.Value(expense.amount),
      categoryId: drift.Value(expense.categoryId),
      date: drift.Value(expense.date),
    );
    await dao.updateExpense(companion);
  }

  Future<void> updateExpenseWithItems(Expense expense, List<ExpenseItemsCompanion> items) async {
    await dao.db.transaction(() async {
      await updateExpense(expense);

      await (dao.db.delete(dao.db.expenseItems)..where((t) => t.expenseId.equals(expense.id))).go();

      for (final it in items) {
        final companion = ExpenseItemsCompanion(
          id: drift.Value.absent(),
          expenseId: drift.Value(expense.id),
          name: it.name,
          amount: it.amount,
          categoryId: it.categoryId,
        );
        await dao.db.into(dao.db.expenseItems).insert(companion);
      }
    });
  }
}
