import 'package:flutter/foundation.dart' show ChangeNotifier, kDebugMode;
import 'package:drift/drift.dart' as drift;
import '../data/app_database.dart'; 
import '../services/notification_service.dart'; // Dodaj import serwisu

class ExpensesState extends ChangeNotifier {
  final ExpensesDao dao;
  final BudgetsDao budgetsDao;
  final CategoriesDao categoriesDao;
  
  // Przechowujemy listę połączonych obiektów (Wydatek + Lista Produktów)
  List<ExpenseWithItems> _expenses = [];
  // Pending budget deltas collected while the app is active.
  final Map<String, double> _pendingBudgetDeltas = {};

  // If [startListening] is false, the instance won't subscribe to the DAO stream
  // immediately. Tests can create the object with startListening: false and
  // call [start] later after performing initial DB operations so the stream
  // emits the current DB state without racing against other async cleanup.
  ExpensesState(this.dao, this.budgetsDao, this.categoriesDao, {bool startListening = true}) {
    if (startListening) {
      _init();
      _loadCategoryCache();
    } else {
      _loadCategoryCache();
    }
  }

  /// Start listening to DAO streams and load the category cache.
  /// Useful in tests to delay subscription until after setup.
  void start() {
    _init();
    _loadCategoryCache();
  }

  // Simple in-memory cache of category id -> name to avoid async calls in getters
  final Map<int, String> _categoryCache = {};

  Future<void> _loadCategoryCache() async {
    final all = await categoriesDao.getAllCategories();
    _categoryCache.clear();
    for (final c in all) {
      _categoryCache[c.id] = c.name;
    }
  }

  void _init() {
    // Drift oferuje streamy (watch), które same informują o zmianach w bazie.
    // Dzięki temu UI odświeży się automatycznie po każdym insercie/delete.
    dao.watchRecentExpenses().listen((data) {
      _expenses = data;
      notifyListeners();
    });
  }

  // Getter dla listy
  List<ExpenseWithItems> get recent => _expenses;

  // Logika obliczania sum (inteligentna: sprawdza czy są pod-produkty)
  Map<String, double> get totalsByCategory {
    final map = <String, double>{};
    
    for (var entry in _expenses) {
      // entry.items to lista produktów (z tabeli ExpenseItems)
      if (entry.items.isNotEmpty) {
        // Jeśli to paragon z pozycjami - sumujemy kategorie pozycji
        for (var item in entry.items) {
          // Prefer categoryId if present, otherwise fallback to parent expense category or 'Inne'
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
        // Jeśli to zwykły wydatek - bierzemy kategorię główną
        // entry.expense to nagłówek (z tabeli Expenses)
        final catName = entry.expense.categoryId != null
            ? (_categoryCache[entry.expense.categoryId] ?? 'Inne')
            : 'Inne';
        map[catName] = (map[catName] ?? 0) + entry.expense.amount;
      }
    }
    return map;
  }

  // DODAWANIE (Obsługuje i zwykły wydatek, i paragon)
  Future<void> addExpense({
    required String title, 
    required double amount, 
    required DateTime date, 
    required String category,
    List<ExpenseItemsCompanion>? items,
  }) async {
    
    // 1. Dodaj wydatek (Standardowo)
    // Resolve category name to id (create category if missing)
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
      // refresh cache
      if (catId != null) _categoryCache[catId] = category;
    }

    final expenseCompanion = ExpensesCompanion.insert(
      title: title,
      amount: amount,
      date: date,
      categoryId: drift.Value(catId),
    );
    await dao.insertExpenseWithItems(expenseCompanion, items ?? []);

    // 2. Zbieramy delta dla budżetu — wykonamy rzeczywiste sprawdzenie
    // dopiero gdy aplikacja zostanie opuszczona (lub gdy ręcznie wywołamy proces).
    _pendingBudgetDeltas[category] = (_pendingBudgetDeltas[category] ?? 0) + amount;
    // Jeśli paragon ma wiele kategorii, wypadałoby sprawdzić każdą z nich (pętla po items),
    // ale dla uproszczenia sprawdzamy tu kategorię główną lub trzeba rozbudować logikę.
  }

  Future<void> _checkBudgets(String category, double addedAmount) async {
    try {
      // Pobierz budżety dla tej kategorii
      final budgets = await budgetsDao.getBudgetsForCategory(category);

      for (final budget in budgets) {
        try {
          // Pobierz ile wydano ŁĄCZNIE (wliczając to co przed chwilą dodaliśmy)
          final currentSpent = await budgetsDao.getSpendingForBudget(budget);
          final previousSpent = currentSpent - addedAmount; // Ile było przed chwilą

          final limit = budget.amountLimit;

          // Sprawdzamy progi (Crossed Threshold Logic)
          _checkThreshold(50, previousSpent, currentSpent, limit, budget);
          _checkThreshold(80, previousSpent, currentSpent, limit, budget);
          _checkThreshold(100, previousSpent, currentSpent, limit, budget);
        } catch (e, st) {
          // Nie przerywamy pętli dla jednego budżetu
          // Logowanie może być tu dodane, np. print(e)
          if (kDebugMode) {
            // ignore: avoid_print
            print('Błąd podczas sprawdzania budżetu ${budget.id}: $e\n$st');
          }
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Błąd podczas pobierania budżetów dla kategorii $category: $e\n$st');
      }
    }
  }

  void _checkThreshold(int percent, double oldSpent, double newSpent, double limit, Budget budget) {
    final thresholdAmount = limit * (percent / 100);
    
    // Jeśli wcześniej było poniżej progu, a teraz jest powyżej (lub równo)
    if (oldSpent < thresholdAmount && newSpent >= thresholdAmount) {
      final catName = budget.categoryId != null ? (_categoryCache[budget.categoryId] ?? 'Inne') : 'Inne';
      NotificationService().showNotification(
        budget.id * 100 + percent, // Unikalne ID powiadomienia
        'Uwaga! Budżet: $catName',
        'Wykorzystano $percent% budżetu (${budget.period}). Wydano: ${newSpent.toStringAsFixed(2)} zł z ${limit.toStringAsFixed(2)} zł.',
      );
    }
  }

  /// Process pending budget deltas collected while the app was active.
  /// This is intended to be called from a lifecycle handler (e.g. when app is paused)
  /// so notifications are shown after the user leaves the app.
  Future<void> processPendingBudgetChecks() async {
    if (_pendingBudgetDeltas.isEmpty) return;
    final work = Map<String, double>.from(_pendingBudgetDeltas);
    _pendingBudgetDeltas.clear();
    for (final entry in work.entries) {
      try {
        await _checkBudgets(entry.key, entry.value);
      } catch (e, st) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Error processing pending budget for ${entry.key}: $e\n$st');
        }
      }
    }
  }


  // USUWANIE
  Future<void> deleteExpense(int id) async {
    await dao.deleteExpense(id);
  }

  // AKTUALIZACJA (Nagłówka)
  Future<void> updateExpense(Expense expense) async {
    // Konwertujemy obiekt danych z powrotem na Companion, aby móc go edytować
    final companion = ExpensesCompanion(
      id: drift.Value(expense.id),
      title: drift.Value(expense.title),
      amount: drift.Value(expense.amount),
      categoryId: drift.Value(expense.categoryId),
      date: drift.Value(expense.date),
    );
    await dao.updateExpense(companion);
  }
}
