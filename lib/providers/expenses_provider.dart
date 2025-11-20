import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../data/app_database.dart'; // Tu są klasy ExpenseWithItems, ExpensesDao, itp.

class ExpensesState extends ChangeNotifier {
  final ExpensesDao dao;
  
  // Przechowujemy listę połączonych obiektów (Wydatek + Lista Produktów)
  List<ExpenseWithItems> _expenses = [];

  ExpensesState(this.dao) {
    _init();
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
          // Używamy pola 'categoryName' zgodnie z Twoim plikiem tables.dart
          map[item.categoryName] = (map[item.categoryName] ?? 0) + item.amount;
        }
      } else {
        // Jeśli to zwykły wydatek - bierzemy kategorię główną
        // entry.expense to nagłówek (z tabeli Expenses)
        map[entry.expense.categoryName] = (map[entry.expense.categoryName] ?? 0) + entry.expense.amount;
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
    List<ExpenseItemsCompanion>? items, // Opcjonalna lista produktów
  }) async {
    
    // Tworzymy obiekt do wstawienia (Companion)
    final expenseCompanion = ExpensesCompanion.insert(
      title: title,
      amount: amount,
      date: date,
      categoryName: category, // Zgodnie z tables.dart
    );

    // Przekazujemy do DAO, które obsłuży transakcję
    await dao.insertExpenseWithItems(expenseCompanion, items ?? []);
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
      categoryName: drift.Value(expense.categoryName),
      date: drift.Value(expense.date),
    );
    await dao.updateExpense(companion);
  }
}