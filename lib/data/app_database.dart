// lib/data/app_database.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Importujemy Twoje tabele
import 'tables.dart'; 

part 'app_database.g.dart';

// Definiujemy klasę łączącą wydatek z jego pozycjami (tak jak robiłeś w ExpensesProvider)
class ExpenseWithItems {
  final Expense expense; // To klasa wygenerowana przez Drift
  final List<ExpenseItem> items; // To klasa wygenerowana przez Drift
  ExpenseWithItems(this.expense, this.items);
}

@DriftDatabase(
  tables: [
    Expenses, 
    ExpenseItems, 
    Categories, 
    Incomes, 
    ProductMappings, 
    RecurringExpenses, 
    RecurringIncomes
  ],
  daos: [ExpensesDao, IncomesDao, CategoriesDao, RecurringDao] // Dodajemy nowe DAO
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// --- DAO DLA WYDATKÓW (Już masz, lekko dostosowane) ---
@DriftAccessor(tables: [Expenses, ExpenseItems])
class ExpensesDao extends DatabaseAccessor<AppDb> with _$ExpensesDaoMixin {
  ExpensesDao(AppDb db) : super(db);

  // ... (Twoje istniejące inserty itp.)

  Future<int> insertExpenseWithItems(ExpensesCompanion expense, List<ExpenseItemsCompanion> items) async {
    return await transaction(() async {
      final id = await into(expenses).insert(expense);
      for (final item in items) {
        await into(expenseItems).insert(item.copyWith(expenseId: Value(id)));
      }
      return id;
    });
  }

  // === TO JEST METODA, KTÓREJ BRAKOWAŁO ===
  Stream<List<ExpenseWithItems>> watchRecentExpenses() {
    // 1. Definiujemy zapytanie (sortowanie po dacie)
    final query = select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)]);

    // 2. Zamieniamy na stream (.watch())
    return query.watch().asyncMap((rows) async {
      final result = <ExpenseWithItems>[];
      
      // 3. Dla każdego wydatku dociągamy jego produkty (N+1 query, ale przy SQLite lokalnym jest to bardzo szybkie)
      for (final row in rows) {
        final itemsList = await (select(expenseItems)..where((t) => t.expenseId.equals(row.id))).get();
        result.add(ExpenseWithItems(row, itemsList));
      }
      return result;
    });
  }
  // =========================================

  // Ta metoda też może zostać (do jednorazowego pobrania)
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

// --- DAO DLA PRZYCHODÓW ---
@DriftAccessor(tables: [Incomes])
class IncomesDao extends DatabaseAccessor<AppDb> with _$IncomesDaoMixin {
  IncomesDao(AppDb db) : super(db);

  Future<List<Income>> getAllIncomes() => 
      (select(incomes)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  Future<int> addIncome(IncomesCompanion entry) => into(incomes).insert(entry);
  
  Future<void> deleteIncome(int id) => (delete(incomes)..where((t) => t.id.equals(id))).go();

  Future<void> addBatchIncomes(List<IncomesCompanion> list) async {
    await batch((batch) {
      batch.insertAll(incomes, list);
    });
  }
}

// --- DAO DLA KATEGORII ---
@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDb> with _$CategoriesDaoMixin {
  CategoriesDao(AppDb db) : super(db);

  Future<List<Category>> getAllCategories() => select(categories).get();
  
  Future<int> countCategories() async {
    final result = await select(categories).get();
    return result.length;
  }

  Future<void> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);
  Future<void> deleteCategory(int id) => (delete(categories)..where((t) => t.id.equals(id))).go();
  
  Future<void> insertAll(List<CategoriesCompanion> list) async {
    await batch((batch) {
      batch.insertAll(categories, list);
    });
  }
}

// --- DAO DLA CYKLICZNYCH ---
@DriftAccessor(tables: [RecurringExpenses, RecurringIncomes, ProductMappings])
class RecurringDao extends DatabaseAccessor<AppDb> with _$RecurringDaoMixin {
  RecurringDao(AppDb db) : super(db);

  // Recurring Expenses
  Future<List<RecurringExpense>> getRecurringExpenses() => 
      (select(recurringExpenses)..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)])).get();
  Future<int> addRecurringExpense(RecurringExpensesCompanion entry) => into(recurringExpenses).insert(entry);
  Future<void> updateRecurringExpense(RecurringExpensesCompanion entry) => update(recurringExpenses).replace(entry);
  Future<void> deleteRecurringExpense(int id) => (delete(recurringExpenses)..where((t) => t.id.equals(id))).go();
  Future<void> updateRecurringExpenseDate(int id, DateTime newDate) async {
    await (update(recurringExpenses)..where((t) => t.id.equals(id))).write(
      RecurringExpensesCompanion(nextDueDate: Value(newDate))
    );
  }

  // Recurring Incomes
  Future<List<RecurringIncome>> getRecurringIncomes() => 
      (select(recurringIncomes)..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)])).get();
  Future<int> addRecurringIncome(RecurringIncomesCompanion entry) => into(recurringIncomes).insert(entry);
  Future<void> updateRecurringIncome(RecurringIncomesCompanion entry) => update(recurringIncomes).replace(entry);
  Future<void> deleteRecurringIncome(int id) => (delete(recurringIncomes)..where((t) => t.id.equals(id))).go();
  Future<void> updateRecurringIncomeDate(int id, DateTime newDate) async {
    await (update(recurringIncomes)..where((t) => t.id.equals(id))).write(
      RecurringIncomesCompanion(nextDueDate: Value(newDate))
    );
  }

  // Product Mappings
  Future<List<ProductMapping>> getAllMappings() => select(productMappings).get();
  Future<void> addMapping(ProductMappingsCompanion entry) => into(productMappings).insert(entry, mode: InsertMode.insertOrReplace);
}