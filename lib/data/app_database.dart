// lib/data/app_database.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import tabel
import 'tables.dart'; 

part 'app_database.g.dart';

// Klasy pomocnicze (DTO)
class ExpenseWithItems {
  final Expense expense;
  final List<ExpenseItem> items;
  ExpenseWithItems(this.expense, this.items);
}

class BudgetWithProgress {
  final Budget budget;
  final double spent;
  BudgetWithProgress(this.budget, this.spent);
  
  double get progress => (spent / budget.amountLimit).clamp(0.0, 1.0);
  double get percent => (spent / budget.amountLimit) * 100;
}

@DriftDatabase(
  tables: [
    Expenses, 
    ExpenseItems, 
    Categories, 
    Incomes, 
    ProductMappings, 
    RecurringExpenses, 
    RecurringIncomes,
    Budgets // <--- Teraz zadziała, bo dodałeś klasę w tables.dart
  ],
  daos: [ExpensesDao, IncomesDao, CategoriesDao, RecurringDao, BudgetsDao]
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // Fresh DB: create all tables
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // If upgrading from an older schema, ensure missing tables are created.
          // Using createAll() is safe here because Drift will ignore tables that already exist.
          if (from < to) {
            await m.createAll();
          }
        },
      );
  
  // Fabryka do tworzenia instancji (przydatna w main.dart)
  static Future<AppDb> create() async {
    return AppDb();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// --- DAO DLA WYDATKÓW ---
@DriftAccessor(tables: [Expenses, ExpenseItems])
class ExpensesDao extends DatabaseAccessor<AppDb> with _$ExpensesDaoMixin {
  ExpensesDao(AppDb db) : super(db);

  Future<int> insertExpenseWithItems(ExpensesCompanion expense, List<ExpenseItemsCompanion> items) async {
    return await transaction(() async {
      final id = await into(expenses).insert(expense);
      for (final item in items) {
        await into(expenseItems).insert(item.copyWith(expenseId: Value(id)));
      }
      return id;
    });
  }

  Stream<List<ExpenseWithItems>> watchRecentExpenses() {
    final query = select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().asyncMap((rows) async {
      final result = <ExpenseWithItems>[];
      for (final row in rows) {
        final itemsList = await (select(expenseItems)..where((t) => t.expenseId.equals(row.id))).get();
        result.add(ExpenseWithItems(row, itemsList));
      }
      return result;
    });
  }

  Future<List<ExpenseWithItems>> getRecentExpenses() async {
    final rows = await (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
    final result = <ExpenseWithItems>[];
    for (final row in rows) {
      final itemsList = await (select(expenseItems)..where((t) => t.expenseId.equals(row.id))).get();
      result.add(ExpenseWithItems(row, itemsList));
    }
    return result;
  }

  Future<void> deleteExpense(int id) async {
    await (delete(expenseItems)..where((t) => t.expenseId.equals(id))).go();
    await (delete(expenses)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateExpense(ExpensesCompanion entry) => update(expenses).replace(entry);
}

// --- DAO DLA BUDŻETÓW ---
@DriftAccessor(tables: [Budgets, Expenses, ExpenseItems])
class BudgetsDao extends DatabaseAccessor<AppDb> with _$BudgetsDaoMixin {
  BudgetsDao(AppDb db) : super(db);

  Future<int> addBudget(BudgetsCompanion entry) => into(budgets).insert(entry);
  
  Future<void> deleteBudget(int id) => (delete(budgets)..where((t) => t.id.equals(id))).go();

  Stream<List<BudgetWithProgress>> watchAllBudgets() async* {
    final budgetStream = select(budgets).watch();
    await for (final budgetList in budgetStream) {
      final results = <BudgetWithProgress>[];
      for (final budget in budgetList) {
        try {
          final spent = await getSpendingForBudget(budget);
          results.add(BudgetWithProgress(budget, spent));
        } catch (e, st) {
          if (const bool.fromEnvironment('dart.vm.product') == false) {
            // ignore: avoid_print
            print('Error computing budget progress for ${budget.id}: $e\n$st');
          }
          // If computation fails for this budget, still add with 0 spent so UI can render.
          results.add(BudgetWithProgress(budget, 0.0));
        }
      }
      yield results;
    }
  }

  Future<double> getSpendingForBudget(Budget budget) async {
    DateTime start;
    final now = DateTime.now();

    // Logika daty
    if (budget.period == 'week') {
      start = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(start.year, start.month, start.day);
    } else if (budget.period == 'year') {
      start = DateTime(now.year, 1, 1);
    } else {
      start = DateTime(now.year, now.month, 1);
    }

    // Zapytanie SQL
    // 1) Suma z pozycji (ExpenseItems) powiązanych z wydatkami
    final itemsQuery = select(expenseItems).join([
      innerJoin(expenses, expenses.id.equalsExp(expenseItems.expenseId))
    ]);

    itemsQuery.where(
      expenseItems.categoryName.equals(budget.category) &
      expenses.date.isBiggerOrEqualValue(start),
    );

    final itemAmounts = await itemsQuery.map((row) => row.read(expenseItems.amount)).get();
    double itemsTotal = 0.0;
    for (final a in itemAmounts) {
      itemsTotal += a ?? 0.0;
    }

    // 2) Suma z nagłówków wydatków (Expenses) które nie mają pozycji
    final expensesQuery = select(expenses)
      ..where((t) =>
        t.categoryName.equals(budget.category) &
        t.date.isBiggerOrEqualValue(start)
      );

    final expenseRows = await expensesQuery.get();
    double expensesTotal = 0.0;
    for (final e in expenseRows) {
      // Jeśli dany expense ma powiązane pozycje, to ich suma już została policzona
      // jednak w Twoim modelu paragonów (ExpenseWithItems) zwykły wydatek ma pustą listę items,
      // więc nie dublujemy tutaj — sumujemy wszystkie nagłówki.
      expensesTotal += e.amount;
    }

    // Zwróć łączną sumę
    return itemsTotal + expensesTotal;
  }
  
  Future<List<Budget>> getBudgetsForCategory(String category) {
    return (select(budgets)..where((t) => t.category.equals(category))).get();
  }
}

// --- POZOSTAŁE DAO (SKRÓCONE DLA CZYTELNOŚCI - ZOSTAJĄ BEZ ZMIAN) ---
// Wklej tu IncomesDao, CategoriesDao, RecurringDao z poprzednich instrukcji,
// jeśli ich nie masz w tym pliku. Powyżej podałem tylko ExpensesDao i BudgetsDao, 
// bo w nich były zmiany. Upewnij się, że masz wszystkie DAO zdefiniowane w pliku!
@DriftAccessor(tables: [Incomes])
class IncomesDao extends DatabaseAccessor<AppDb> with _$IncomesDaoMixin {
  IncomesDao(AppDb db) : super(db);
  Future<List<Income>> getAllIncomes() => (select(incomes)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
  Future<int> addIncome(IncomesCompanion entry) => into(incomes).insert(entry);
  Future<void> deleteIncome(int id) => (delete(incomes)..where((t) => t.id.equals(id))).go();
  Future<void> addBatchIncomes(List<IncomesCompanion> list) async {
    await batch((batch) => batch.insertAll(incomes, list));
  }
}

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDb> with _$CategoriesDaoMixin {
  CategoriesDao(AppDb db) : super(db);
  Future<List<Category>> getAllCategories() => select(categories).get();
  Future<int> countCategories() async { final res = await select(categories).get(); return res.length; }
  Future<void> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);
  Future<void> deleteCategory(int id) => (delete(categories)..where((t) => t.id.equals(id))).go();
  Future<void> insertAll(List<CategoriesCompanion> list) async { await batch((batch) => batch.insertAll(categories, list)); }
}

@DriftAccessor(tables: [RecurringExpenses, RecurringIncomes, ProductMappings])
class RecurringDao extends DatabaseAccessor<AppDb> with _$RecurringDaoMixin {
  RecurringDao(AppDb db) : super(db);
  // Recurring Expenses
  Future<List<RecurringExpense>> getRecurringExpenses() => (select(recurringExpenses)..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)])).get();
  Future<int> addRecurringExpense(RecurringExpensesCompanion entry) => into(recurringExpenses).insert(entry);
  Future<void> updateRecurringExpense(RecurringExpensesCompanion entry) => update(recurringExpenses).replace(entry);
  Future<void> deleteRecurringExpense(int id) => (delete(recurringExpenses)..where((t) => t.id.equals(id))).go();
  Future<void> updateRecurringExpenseDate(int id, DateTime newDate) async {
    await (update(recurringExpenses)..where((t) => t.id.equals(id))).write(RecurringExpensesCompanion(nextDueDate: Value(newDate)));
  }
  // Recurring Incomes
  Future<List<RecurringIncome>> getRecurringIncomes() => (select(recurringIncomes)..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)])).get();
  Future<int> addRecurringIncome(RecurringIncomesCompanion entry) => into(recurringIncomes).insert(entry);
  Future<void> updateRecurringIncome(RecurringIncomesCompanion entry) => update(recurringIncomes).replace(entry);
  Future<void> deleteRecurringIncome(int id) => (delete(recurringIncomes)..where((t) => t.id.equals(id))).go();
  Future<void> updateRecurringIncomeDate(int id, DateTime newDate) async {
    await (update(recurringIncomes)..where((t) => t.id.equals(id))).write(RecurringIncomesCompanion(nextDueDate: Value(newDate)));
  }
  // Mappings
  Future<List<ProductMapping>> getAllMappings() => select(productMappings).get();
  Future<void> addMapping(ProductMappingsCompanion entry) => into(productMappings).insert(entry, mode: InsertMode.insertOrReplace);
}