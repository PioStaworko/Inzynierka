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

// Lightweight in-file representation of a savings goal row (avoids depending on generated types)
class SimpleSavingsGoal {
  final int id;
  final String title;
  final double targetAmount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  SimpleSavingsGoal({required this.id, required this.title, required this.targetAmount, required this.startDate, required this.endDate, required this.createdAt});
}

class GoalWithProgress {
  final SimpleSavingsGoal goal;
  final double incomes;
  final double spent;

  GoalWithProgress(this.goal, this.incomes, this.spent);

  // === NOWA LOGIKA ===
  // Oszczędzone = Przychody w tym okresie MINUS Wydatki w tym okresie
  double get savedAmount => incomes - spent;

  // Postęp to Oszczędzone / Cel
  double get progress {
    if (goal.targetAmount == 0) return 0.0;
    // clamp(0.0, 1.0) zapewnia, że pasek nie wyjdzie poza zakres 
    // (nawet jak jesteśmy na minusie lub przekroczyliśmy cel)
    return (savedAmount / goal.targetAmount).clamp(0.0, 1.0);
  }

  double get percent => (progress * 100);
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
    Budgets,
    SavingsGoals,
  ],
  daos: [ExpensesDao, IncomesDao, CategoriesDao, RecurringDao, BudgetsDao]
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 5; // bumped to apply new column migrations

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
            // Add new nullable FK columns for normalization (non-destructive)
            try {
              await customStatement('ALTER TABLE budgets ADD COLUMN category_id INTEGER');
            } catch (_) {}
            try {
              await customStatement('ALTER TABLE recurring_expenses ADD COLUMN category_id INTEGER');
            } catch (_) {}
            try {
              await customStatement('ALTER TABLE product_mappings ADD COLUMN default_category_id INTEGER');
            } catch (_) {}
            // Ensure expenses and expense_items have category_id column for normalization
            try {
              await customStatement('ALTER TABLE expenses ADD COLUMN category_id INTEGER');
            } catch (_) {}
            try {
              await customStatement('ALTER TABLE expense_items ADD COLUMN category_id INTEGER');
            } catch (_) {}

            // Backfill newly added category_id columns from textual category fields
            try {
              await customStatement('UPDATE budgets SET category_id = (SELECT id FROM categories WHERE categories.name = budgets.category) WHERE category_id IS NULL');
            } catch (_) {}
            try {
              await customStatement('UPDATE recurring_expenses SET category_id = (SELECT id FROM categories WHERE categories.name = recurring_expenses.category) WHERE category_id IS NULL');
            } catch (_) {}
            try {
              await customStatement('UPDATE product_mappings SET default_category_id = (SELECT id FROM categories WHERE categories.name = product_mappings.default_category) WHERE default_category_id IS NULL');
            } catch (_) {}
            // Backfill expenses.category_id from possible textual category columns
            try {
              await customStatement('UPDATE expenses SET category_id = (SELECT id FROM categories WHERE categories.name = expenses.category) WHERE category_id IS NULL');
            } catch (_) {}
            try {
              await customStatement('UPDATE expenses SET category_id = (SELECT id FROM categories WHERE categories.name = expenses.category_name) WHERE category_id IS NULL');
            } catch (_) {}
            // Backfill expense_items.category_id from possible textual columns
            try {
              await customStatement('UPDATE expense_items SET category_id = (SELECT id FROM categories WHERE categories.name = expense_items.category) WHERE category_id IS NULL');
            } catch (_) {}
            try {
              await customStatement('UPDATE expense_items SET category_id = (SELECT id FROM categories WHERE categories.name = expense_items.category_name) WHERE category_id IS NULL');
            } catch (_) {}

            // Some older DB versions kept a non-null `category_name` text column
            // which causes INSERTs to fail if new code doesn't provide it.
            // Detect that situation and recreate the table with the
            // normalized schema (only `category_id`) while preserving data.
            try {
              final pragma = await customSelect('PRAGMA table_info(expenses)').get();
              final hasCategoryName = pragma.any((r) {
                final n = r.read<String>('name');
                return n == 'category_name';
              });

              if (hasCategoryName) {
                final col = pragma.firstWhere((r) => r.read<String>('name') == 'category_name');
                final notnull = col.read<int>('notnull');
                final dflt = col.read<Object?>('dflt_value');

                // If the column is NOT NULL and has no default, existing INSERTs
                // (which don't specify category_name) will fail. Rebuild.
                if (notnull == 1 && dflt == null) {
                  await customStatement('ALTER TABLE expenses RENAME TO expenses_old');
                  await customStatement('CREATE TABLE expenses_new (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, amount REAL NOT NULL, date INTEGER NOT NULL, category_id INTEGER REFERENCES categories (id))');
                  await customStatement(
                      'INSERT INTO expenses_new (id, title, amount, date, category_id) '
                      'SELECT id, title, amount, date, '
                      "COALESCE(category_id, (SELECT id FROM categories WHERE categories.name = expenses_old.category), (SELECT id FROM categories WHERE categories.name = expenses_old.category_name))"
                      ' FROM expenses_old');
                  await customStatement('DROP TABLE IF EXISTS expenses_old');
                  await customStatement('ALTER TABLE expenses_new RENAME TO expenses');
                }
              }
            } catch (_) {}

            // Repeat same defensive table-rebuild for expense_items
            try {
              final pragma2 = await customSelect('PRAGMA table_info(expense_items)').get();
              final hasCatName2 = pragma2.any((r) => r.read<String>('name') == 'category_name');
              if (hasCatName2) {
                final col2 = pragma2.firstWhere((r) => r.read<String>('name') == 'category_name');
                final notnull2 = col2.read<int>('notnull');
                final dflt2 = col2.read<Object?>('dflt_value');
                if (notnull2 == 1 && dflt2 == null) {
                  await customStatement('ALTER TABLE expense_items RENAME TO expense_items_old');
                  await customStatement('CREATE TABLE expense_items_new (id INTEGER PRIMARY KEY AUTOINCREMENT, expense_id INTEGER NOT NULL, name TEXT NOT NULL, amount REAL NOT NULL, category_id INTEGER)');
                  await customStatement(
                      'INSERT INTO expense_items_new (id, expense_id, name, amount, category_id) '
                      'SELECT id, expense_id, name, amount, '
                      "COALESCE(category_id, (SELECT id FROM categories WHERE categories.name = expense_items_old.category), (SELECT id FROM categories WHERE categories.name = expense_items_old.category_name))"
                      ' FROM expense_items_old');
                  await customStatement('DROP TABLE IF EXISTS expense_items_old');
                  await customStatement('ALTER TABLE expense_items_new RENAME TO expense_items');
                }
              }
            } catch (_) {}

            // Create helpful indices
            try {
              await customStatement('CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date)');
            } catch (_) {}
            try {
              await customStatement('CREATE INDEX IF NOT EXISTS idx_expenseitems_expenseId ON expense_items(expense_id)');
            } catch (_) {}
            try {
              await customStatement('CREATE INDEX IF NOT EXISTS idx_incomes_date ON incomes(date)');
            } catch (_) {}
          }
        },
      );
  
  // Fabryka do tworzenia instancji (przydatna w main.dart)
  static Future<AppDb> create() async {
    return AppDb();
  }

  // --- Helpers for Savings Goals (non-generated API so provider can use without build_runner) ---
  Stream<List<GoalWithProgress>> watchAllGoalsStream() async* {
    // 1. Definiujemy zapytanie o cele
    final query = customSelect(
      'SELECT id, title, target_amount, start_date, end_date, created_at FROM savings_goals ORDER BY created_at DESC',
      // WAŻNE: Tutaj mówimy Driftowi, jakie tabele mają wpływ na ten widok
      readsFrom: {
        savingsGoals, 
        incomes, 
        expenses, 
        expenseItems
      }, 
    );

    // 2. Mapujemy wyniki
    final rowsStream = query.map((row) {
      final id = row.read<int>('id');
      final title = row.read<String>('title');
      final target = row.read<double>('target_amount');
      final startMs = row.read<int>('start_date');
      final endMs = row.read<int>('end_date');
      final createdMs = row.read<int>('created_at');
      return SimpleSavingsGoal(
        id: id,
        title: title,
        targetAmount: target.toDouble(),
        startDate: DateTime.fromMillisecondsSinceEpoch(startMs),
        endDate: DateTime.fromMillisecondsSinceEpoch(endMs),
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdMs),
      );
    }).watch();

    // 3. Przeliczamy postęp dla każdego celu (to się uruchomi przy każdej zmianie w w/w tabelach)
    await for (final goals in rowsStream) {
      final list = <GoalWithProgress>[];
      for (final g in goals) {
        try {
          // Pobieramy sumy dla danego zakresu dat
          final incomesSum = await _getIncomesForPeriod(g.startDate, g.endDate);
          final spentSum = await _getSpendingForPeriod(g.startDate, g.endDate);
          
          list.add(GoalWithProgress(g, incomesSum, spentSum));
        } catch (e) {
          // W razie błędu dodajemy pusty postęp, żeby nie wywalić UI
          list.add(GoalWithProgress(g, 0.0, 0.0));
        }
      }
      yield list;
    }
  }

  Future<void> addGoalRaw(String title, double target, DateTime start, DateTime end) async {
    // Insert using raw statement to avoid depending on generated Companion classes.
    // Wrap in try/catch and print to help debugging when the table or types are missing.
    try {
      await customStatement(
        'INSERT INTO savings_goals (title, target_amount, start_date, end_date, created_at) VALUES (?, ?, ?, ?, ?)',
        [
          title,
          target,
          start.millisecondsSinceEpoch,
          end.millisecondsSinceEpoch,
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        // ignore: avoid_print
        print('[AppDb] addGoalRaw: inserted goal "$title" target=$target start=$start end=$end');
      }
    } catch (e, st) {
      // Bubble up after logging so caller can show feedback
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        // ignore: avoid_print
        print('[AppDb] addGoalRaw ERROR: $e\n$st');
      }
      rethrow;
    }
  }

  Future<void> deleteGoalRaw(int id) async {
    await customStatement('DELETE FROM savings_goals WHERE id = ?', [id]);
  }

  Future<double> _getIncomesForPeriod(DateTime start, DateTime end) async {
    final q = select(incomes)..where((t) => t.date.isBetweenValues(start, end));
    final rows = await q.get();
    double total = 0.0;
    for (final r in rows) total += r.amount;
    return total;
  }

  Future<double> _getSpendingForPeriod(DateTime start, DateTime end) async {
    double itemsTotal = 0.0;
    final itemsQuery = select(expenseItems).join([
      innerJoin(expenses, expenses.id.equalsExp(expenseItems.expenseId))
    ]);
    itemsQuery.where(expenses.date.isBetweenValues(start, end));
    final itemAmounts = await itemsQuery.map((row) => row.read(expenseItems.amount)).get();
    for (final a in itemAmounts) itemsTotal += a ?? 0.0;

    final expensesQuery = select(expenses)..where((t) => t.date.isBetweenValues(start, end));
    final expenseRows = await expensesQuery.get();
    double expensesTotal = 0.0;
    for (final e in expenseRows) {
      expensesTotal += e.amount;
    }

    return itemsTotal + expensesTotal;
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

    if (budget.categoryId != null) {
      itemsQuery.where(
        expenseItems.categoryId.equals(budget.categoryId!) &
            expenses.date.isBiggerOrEqualValue(start),
      );
    } else {
      // No categoryId present; match nothing for items
      itemsQuery.where(expenseItems.id.equals(-1));
      itemsQuery.where(expenses.date.isBiggerOrEqualValue(start));
    }

    final itemAmounts = await itemsQuery.map((row) => row.read(expenseItems.amount)).get();
    double itemsTotal = 0.0;
    for (final a in itemAmounts) {
      itemsTotal += a ?? 0.0;
    }

    // 2) Suma z nagłówków wydatków (Expenses) które nie mają pozycji
    final expensesQuery = select(expenses);
    if (budget.categoryId != null) {
      expensesQuery.where((t) => t.categoryId.equals(budget.categoryId!) & t.date.isBiggerOrEqualValue(start));
    } else {
      // No categoryId -> match nothing for expenses
      expensesQuery.where((t) => t.id.equals(-1));
    }

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
  
  Future<List<Budget>> getBudgetsForCategory(String category) async {
    // Try to resolve category name to id first
    final cats = await (select(categories)..where((c) => c.name.equals(category))).get();
    if (cats.isNotEmpty) {
      final id = cats.first.id;
      return (select(budgets)..where((t) => t.categoryId.equals(id))).get();
    }
    // No matching category name -> return empty list (no budgets for that name)
    return <Budget>[];
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